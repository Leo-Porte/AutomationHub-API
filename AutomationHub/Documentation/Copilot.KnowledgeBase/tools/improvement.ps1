#requires -Version 5.1
param(
    [Parameter(Position=0,Mandatory=$true)][ValidateSet('open','close','cancel')]$Command,
    [Parameter(Position=1,ValueFromRemainingArguments=$true)]$Message
)

$ErrorActionPreference = 'Stop'

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Gray','Green','Yellow','Red','Cyan','Magenta','White','DarkGray')][string]$Color = 'Gray'
    )
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    Write-Host "[$ts] $Message" -ForegroundColor $Color
}

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        $null = New-Item -ItemType Directory -Path $Path -Force
    }
}

function Get-KbRoot {
    # tools folder -> knowledge base root
    return (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

function Get-StateFile { Join-Path (Get-KbRoot) '.current-improvement' }

function Save-State {
    param([hashtable]$State)
    $stateFile = Get-StateFile
    $State | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $stateFile -Encoding UTF8
}

function Load-State {
    $stateFile = Get-StateFile
    if (Test-Path -LiteralPath $stateFile) {
        try { return Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json } catch { return $null }
    }
    return $null
}

function Remove-State {
    $stateFile = Get-StateFile
    if (Test-Path -LiteralPath $stateFile) { Remove-Item -LiteralPath $stateFile -Force }
}

function New-Slug {
    param([string]$Text)
    if (-not $Text) { return "improvement" }
    $norm = $Text.ToLowerInvariant()
    # replace accents by removing non ASCII letters
    $norm = [System.Text.Encoding]::ASCII.GetString([System.Text.Encoding]::GetEncoding('Cyrillic').GetBytes($norm))
    $norm = ($norm -replace '[^a-z0-9\s-]', '')
    $norm = ($norm -replace '\s+', '-')
    $norm = ($norm -replace '-+', '-')
    return $norm.Trim('-')
}

function Git {
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
    $out = & git @Args 2>&1
    $code = $LASTEXITCODE
    $text = ($out -join "`n").Trim()
    if ($code -ne 0) { throw "git $($Args -join ' ') failed: $text" }
    return $text
}

function Update-ImprovementsReadme {
    $kb = Get-KbRoot
    $imprDir = Join-Path $kb '05_HISTORY/Improvements'
    $readme = Join-Path $imprDir 'README.md'
    Ensure-Dir $imprDir
    $files = Get-ChildItem -LiteralPath $imprDir -Filter '*.md' | Where-Object { $_.Name -ne 'README.md' } | Sort-Object Name
    $table = @()
    $table += '| Data | Arquivo | Título |'
    $table += '|---|---|---|'
    foreach ($f in $files) {
        $name = $f.BaseName
        $date = $name.Split('_')[0]
        $title = (Get-Content -LiteralPath $f.FullName -First 1)
        if ($title -match '^#\s*(.+)$') { $title = $Matches[1] } else { $title = $name }
        $rel = "./$($f.Name)"
        $table += "| $date | [$($f.Name)]($rel) | $title |"
    }
    $content = @(
        '# Melhorias (Histórico)',
        '',
        '> Lista gerada automaticamente. Edite os arquivos individuais para alterar os detalhes.',
        '',
        '<!-- IMPROVEMENTS-TABLE:START -->',
        ($table -join "`n"),
        '<!-- IMPROVEMENTS-TABLE:END -->',
        ''
    ) -join "`n"
    Set-Content -LiteralPath $readme -Value $content -Encoding UTF8
}

function Append-To-WeeklySummary {
    param([string]$Line)
    $kb = Get-KbRoot
    $weekly = Join-Path $kb '05_HISTORY/WeeklySummary.md'
    if (-not (Test-Path -LiteralPath $weekly)) {
        Set-Content -LiteralPath $weekly -Encoding UTF8 -Value "# Resumo Semanal`n`n"
    }
    $date = (Get-Date).ToString('yyyy-MM-dd')
    $header = "## Semana $date"
    $text = Get-Content -LiteralPath $weekly -Raw
    if ($text -notmatch [Regex]::Escape($header)) {
        $text = ($text.TrimEnd() + "`n`n$header`n")
    }
    $text = ($text.TrimEnd() + "`n- $Line`n")
    Set-Content -LiteralPath $weekly -Encoding UTF8 -Value $text
}

function Append-To-Refactors {
    param([string]$Title,[string[]]$Areas)
    $kb = Get-KbRoot
    $refactors = Join-Path $kb '02_DECISIONS/Refactors.md'
    if (-not (Test-Path -LiteralPath $refactors)) {
        Set-Content -LiteralPath $refactors -Encoding UTF8 -Value "# Refatorações e Motivações`n`n"
    }
    $ym = (Get-Date).ToString('yyyy-MM')
    $sectionHeader = "## $ym — $Title"
    $body = @($sectionHeader)
    if ($Areas -and $Areas.Count -gt 0) {
        $body += ($Areas | Sort-Object -Unique | ForEach-Object { "- Área: $_" })
    } else {
        $body += "- Áreas: N/D"
    }
    Add-Content -LiteralPath $refactors -Encoding UTF8 -Value ("`n" + ($body -join "`n") + "`n")
}

switch ($Command) {
    'open' {
        if (-not $Message) { throw 'Forneça a descrição da melhoria: improvement.ps1 open "Descrição..."' }
        if (Load-State) { throw "Já existe uma melhoria ativa. Use 'close' ou 'cancel'." }

        $kb = Get-KbRoot
        $imprDir = Join-Path $kb '05_HISTORY/Improvements'
        Ensure-Dir $imprDir

        $slug = New-Slug -Text ($Message -join ' ')
        $date = (Get-Date).ToString('yyyyMMdd')
        $fileName = "${date}_${slug}.md"
        $filePath = Join-Path $imprDir $fileName

        $userName = ''
        try { $userName = (Git config user.name) } catch { $userName = $env:UserName }
        $branch = ''
        try { $branch = (Git rev-parse --abbrev-ref HEAD) } catch { $branch = '' }
        $head = ''
        try { $head = (Git rev-parse HEAD) } catch { $head = '' }

        $content = @(
            "# $($Message -join ' ')",
            '',
            "- Aberta em: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
            "- Autor: $userName",
            "- Branch: $branch",
            '',
            '## Contexto',
            '- Descreva o problema, impacto e motivação.',
            '',
            '## Alterações propostas',
            '- Itens principais a serem implementados.',
            '',
            '## Resultados esperados',
            '- Métricas e critérios de aceite.',
            '',
            '## Execução',
            '```',
            'Comandos, links ou notas de execução',
            '```',
            ''
        ) -join "`n"
        Set-Content -LiteralPath $filePath -Value $content -Encoding UTF8

        $state = @{ title = ($Message -join ' '); file = $filePath; slug = $slug; openedAt = (Get-Date); headAtOpen = $head; branch = $branch }
        Save-State -State $state

        Update-ImprovementsReadme
        Write-Log "Melhoria aberta: $fileName" Green
        Write-Log "Arquivo: $filePath" DarkGray
    }
    'close' {
        $state = Load-State
        if (-not $state) { throw 'Nenhuma melhoria ativa para fechar.' }
        $kb = Get-KbRoot
        $relPath = (Resolve-Path -LiteralPath $state.file).Path
        $relLink = (Resolve-Path -LiteralPath $state.file).Path
        $fileName = Split-Path -Leaf $state.file

        $range = ''
        if ($state.headAtOpen) { $range = "$($state.headAtOpen)..HEAD" }
        $changed = @()
        $stat = ''
        try {
            if ($range) {
                $changed = (Git diff --name-only $range) -split "`n" | Where-Object { $_ }
                $stat = (Git diff --stat $range)
            } else {
                $changed = (Git diff --name-only) -split "`n" | Where-Object { $_ }
                $stat = (Git diff --stat)
            }
        } catch { $changed = @(); $stat = '' }

        $areas = $changed | ForEach-Object { ($_ -split '[\\/]')[0] } | Where-Object { $_ }
        $filesCount = @($changed | Where-Object { $_ }).Count

        $closeBlock = @(
            '---',
            "Fechada em: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
            "Arquivos alterados: $filesCount",
            '',
            'Resumo (git diff --stat):',
            '```',
            ($stat ? $stat : 'Sem alterações detectadas'),
            '```',
            ''
        ) -join "`n"
        Add-Content -LiteralPath $state.file -Encoding UTF8 -Value $closeBlock

        $line = "[$fileName](05_HISTORY/Improvements/$fileName) — $($state.title) — $filesCount arquivos alterados"
        Append-To-WeeklySummary -Line $line
        Append-To-Refactors -Title $state.title -Areas $areas

        Remove-State
        Update-ImprovementsReadme
        Write-Log "Melhoria fechada: $fileName" Green
    }
    'cancel' {
        $state = Load-State
        if (-not $state) { throw 'Nenhuma melhoria ativa para cancelar.' }
        if (Test-Path -LiteralPath $state.file) {
            Remove-Item -LiteralPath $state.file -Force
            Write-Log "Arquivo removido: $($state.file)" Yellow
        }
        Remove-State
        Update-ImprovementsReadme
        Write-Log 'Melhoria cancelada.' Yellow
    }
}
