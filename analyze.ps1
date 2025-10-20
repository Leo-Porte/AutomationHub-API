#requires -Version 7.0
param(
    [switch] $EnableVerbose
)
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# =====================
# Variáveis principais
# =====================
$ProjectKey = 'AutomationHub'
$Url        = 'http://localhost:9000'
$Container  = 'sonarqube'
$Image      = 'sonarqube:lts-community'
$TimeoutSec = 420  # 7 minutos

# =====================
# Carregar segredos locais
# =====================
Write-Host "?? Carregando segredos locais..." -ForegroundColor DarkCyan
if (Test-Path ".\secrets.ps1") {
    . .\secrets.ps1
    if ([string]::IsNullOrWhiteSpace($Token)) {
        Write-Warning '??  O arquivo secrets.ps1 foi carregado mas a variável Token não está definida.'
        exit 1
    }
    Write-Host "? Segredos carregados com sucesso." -ForegroundColor Green
} else {
    Write-Warning '??  secrets.ps1 não encontrado. Crie-o com a linha: $Token = ''sqp_SEU_TOKEN_AQUI'''
    exit 1
}

# =====================
# Spinner (estado e funções)
# =====================
$script:SpinnerFrames = @('|','/','-','\')
$script:SpinnerIndex  = 0
$script:SpinnerTimer  = $null
$global:SpinnerStop   = $false

<#
.SYNOPSIS
 Mostra uma animação de loading no terminal usando um Timer, até $global:SpinnerStop ser verdadeiro.
#>
function Show-Spinner {
    param(
        [Parameter(Mandatory)] [string] $Message,
        [int] $IntervalMs = 300
    )
    $global:SpinnerStop = $false
    Write-Host $Message -ForegroundColor DarkCyan

    $script:SpinnerTimer = [System.Timers.Timer]::new($IntervalMs)
    $script:SpinnerTimer.AutoReset = $true

    $elapsedHandler = [System.Timers.ElapsedEventHandler] {
        if ($global:SpinnerStop -or -not $script:SpinnerTimer) { return }
        $frame = $script:SpinnerFrames[$script:SpinnerIndex % $script:SpinnerFrames.Count]
        $script:SpinnerIndex++
        # Limpa linha anterior e reescreve o frame
        Write-Host "`r   `r" -NoNewline
        Write-Host ("{0} " -f $frame) -NoNewline -ForegroundColor DarkCyan
    }

    $script:SpinnerTimer.add_Elapsed($elapsedHandler)
    $script:SpinnerTimer.Start()
}

<#
.SYNOPSIS
 Interrompe o spinner e limpa a linha do terminal.
#>
function Stop-Spinner {
    if ($script:SpinnerTimer -ne $null) {
        $global:SpinnerStop = $true
        $script:SpinnerTimer.Stop()
        $script:SpinnerTimer.Dispose()
        $script:SpinnerTimer = $null
        # Limpa o spinner da linha
        Write-Host "`r   `r" -NoNewline
    }
}

<#
.SYNOPSIS
 Aguarda o SonarQube ficar saudável (GREEN), imprimindo o status a cada ciclo.
 Se detectar falta de privilégios (login), abre o navegador e aguarda o login manual.
#>
function Wait-ForSonar {
    param(
        [Parameter(Mandatory)] [string] $BaseUrl,
        [int] $Timeout = 420,
        [switch] $EnableVerbose
    )

    $healthEndpoint = "$BaseUrl/api/system/health"
    $openedBrowser  = $false
    $startTime = Get-Date

    Stop-Spinner
    Write-Host "? Tentando conectar ao SonarQube..." -ForegroundColor DarkCyan

    try {
        $deadline = (Get-Date).AddSeconds($Timeout)
        $attempt = 1

        while ((Get-Date) -lt $deadline) {
            $elapsed = (Get-Date) - $startTime
            $elapsedFormatted = "{0:mm\:ss}" -f $elapsed

            try {
                $resp = Invoke-RestMethod -Uri $healthEndpoint -Method Get -TimeoutSec 5 -ErrorAction Stop
                $status = $resp.health
                if (-not $status) { $status = $resp.status }
                if ([string]::IsNullOrWhiteSpace($status)) { $status = "..." }

                Write-Host ("`r? Tentando conectar ao SonarQube... ({0}) Status atual: {1}   " -f $elapsedFormatted, $status) -NoNewline -ForegroundColor DarkCyan

                if ($EnableVerbose) {
                    Write-Host "`n?? Tentativa #$attempt ? status bruto: $($resp | ConvertTo-Json -Compress)" -ForegroundColor DarkGray
                }

                if ($status -eq 'GREEN') {
                    Write-Host ("`n? SonarQube está operacional (GREEN) em {0}" -f $elapsedFormatted) -ForegroundColor Green
                    return $true
                }

                Start-Sleep -Seconds 2
                $attempt++
            }
            catch {
                $msg = $_.Exception.Message

                if ($EnableVerbose) { Write-Host "`n??  Erro detectado: $msg" -ForegroundColor Yellow }

                if ($msg -match 'Insufficient privileges' -or $msg -match '401' -or $msg -match 'Unauthorized') {
                    if (-not $openedBrowser) {
                        Write-Host "`n?? Login necessário — abrindo painel do SonarQube..." -ForegroundColor Yellow
                        Start-Process $BaseUrl | Out-Null
                        $openedBrowser = $true
                        Write-Host "?? Aguardando login manual..." -ForegroundColor Yellow
                    }
                    Start-Sleep -Seconds 4
                }
                else {
                    Start-Sleep -Seconds 2
                }
            }
        }

        Write-Host ("`n? Tempo esgotado ({0}s) aguardando o SonarQube ficar GREEN." -f $Timeout) -ForegroundColor Red
        return $false
    }
    finally {
        Stop-Spinner
    }
}

<#
.SYNOPSIS
 Verifica ferramentas básicas.
#>
function Assert-Tool {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [string] $CheckArgs = '--version'
    )
    Write-Host "?? Verificando ferramenta: $Name" -ForegroundColor Cyan
    try {
        $null = & $Name $CheckArgs
        Write-Host "? $Name encontrado." -ForegroundColor Green
    }
    catch {
        throw "? Ferramenta '$Name' não encontrada ou inacessível. Adicione ao PATH ou instale-a."
    }
}

<#
.SYNOPSIS
 Verifica dotnet-sonarscanner.
#>
function Assert-DotNetSonarScanner {
    Write-Host '?? Verificando dotnet-sonarscanner' -ForegroundColor Cyan
    try {
        $null = & dotnet sonarscanner --version
        Write-Host '? dotnet-sonarscanner encontrado.' -ForegroundColor Green
    }
    catch {
        throw "? 'dotnet sonarscanner' não está disponível. Instale com: dotnet tool install -g dotnet-sonarscanner"
    }
}

<#
.SYNOPSIS
 Garante que o container do SonarQube exista e esteja em execução.
#>
function Ensure-SonarContainer {
    param(
        [Parameter(Mandatory)] [string] $ContainerName,
        [Parameter(Mandatory)] [string] $Image
    )

    Write-Host "?? Garantindo container '$ContainerName' com imagem '$Image'" -ForegroundColor Cyan

    $exists = $false
    try {
        $id = (docker ps -a --filter "name=^/$ContainerName$" --format '{{.ID}}')
        if (![string]::IsNullOrWhiteSpace($id)) { $exists = $true }
    }
    catch { throw "? Falha ao consultar Docker. Verifique o Docker Desktop/Engine." }

    if (-not $exists) {
        Write-Host "??  Baixando imagem e criando container..." -ForegroundColor Yellow
        & docker pull $Image | Out-Host
        & docker run -d --name $ContainerName -p 9000:9000 $Image | Out-Host
        Write-Host "? Container '$ContainerName' criado." -ForegroundColor Green
    }
    else {
        $isRunning = (docker inspect -f '{{.State.Running}}' $ContainerName) -eq 'true'
        if (-not $isRunning) {
            Write-Host "??  Iniciando container existente..." -ForegroundColor Yellow
            & docker start $ContainerName | Out-Host
            Write-Host "? Container iniciado." -ForegroundColor Green
        }
        else {
            Write-Host "? Container já está em execução." -ForegroundColor Green
        }
    }
}

<#
.SYNOPSIS
 Tenta identificar a pasta do projeto (.csproj) onde o script foi executado.
#>
function Get-ProjectDirectory {
    $here = Get-Location
    $csprojs = @(Get-ChildItem -Path $here -Filter *.csproj -File -ErrorAction SilentlyContinue)

    if ($csprojs.Count -eq 1) { return $here }
    elseif ($csprojs.Count -gt 1) { throw 'Mais de um .csproj na pasta atual. Execute o script dentro da pasta do projeto (apenas um .csproj).' }
    else {
        $all = @(Get-ChildItem -Path $here -Filter *.csproj -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' })
        if ($all.Count -eq 1) {
            Write-Host "??  Nenhum .csproj na pasta atual. Usando: $($all.FullName)" -ForegroundColor Yellow
            return $all.Directory
        }
        elseif ($all.Count -gt 1) { throw 'Vários .csproj encontrados na árvore. Execute o script dentro da pasta do projeto correto.' }
        else { throw 'Nenhum .csproj encontrado. Execute o script na pasta do projeto (.csproj).' }
    }
}

<#
.SYNOPSIS
 Executa o fluxo de análise: begin ? build ? end com mensagens amigáveis.
#>
function Invoke-SonarAnalysis {
    param(
        [Parameter(Mandatory)] [string] $ProjectKey,
        [Parameter(Mandatory)] [string] $BaseUrl,
        [Parameter(Mandatory)] [string] $Token
    )

    try {
        Write-Host "?? Iniciando análise..." -ForegroundColor Cyan
        & dotnet sonarscanner begin "/k:$ProjectKey" "/d:sonar.host.url=$BaseUrl" "/d:sonar.login=$Token" | Out-Host

        Write-Host "?? Compilando projeto..." -ForegroundColor Cyan
        & dotnet build | Out-Host
        Write-Host "? Build concluído." -ForegroundColor Green

        Write-Host "?? Enviando resultados ao SonarQube..." -ForegroundColor Cyan
        & dotnet sonarscanner end "/d:sonar.login=$Token" | Out-Host
        Write-Host "? Análise concluída! Painel: $BaseUrl" -ForegroundColor Green
    }
    catch {
        Write-Host "? Falha durante a análise: $($_.Exception.Message)" -ForegroundColor Red
    }
}

<#
.SYNOPSIS
 Exibe um menu de ações pós-análise.
#>
function Show-Menu {
    param(
        [Parameter(Mandatory)] [string] $BaseUrl,
        [Parameter(Mandatory)] [string] $ContainerName
    )

    while ($true) {
        Write-Host ""; Write-Host "==============================" -ForegroundColor DarkGray
        Write-Host "??  Menu de Ações SonarQube" -ForegroundColor Magenta
        Write-Host "==============================" -ForegroundColor DarkGray
        Write-Host "1??  Rodar build e análise novamente" -ForegroundColor White
        Write-Host "2??  Somente rodar build" -ForegroundColor White
        Write-Host "3??  Abrir painel SonarQube" -ForegroundColor White
        Write-Host "4??  Parar container SonarQube" -ForegroundColor White
        Write-Host "0??  Sair" -ForegroundColor White
        Write-Host "==============================" -ForegroundColor DarkGray

        $choice = Read-Host "Digite a opção desejada"
        switch ($choice) {
            '1' {
                try {
                    $projDir = Get-ProjectDirectory
                    Push-Location $projDir
                    Invoke-SonarAnalysis -ProjectKey $ProjectKey -BaseUrl $BaseUrl -Token $Token
                }
                finally { Pop-Location }
            }
            '2' {
                try {
                    Write-Host "?? Compilando projeto..." -ForegroundColor Cyan
                    $projDir = Get-ProjectDirectory
                    Push-Location $projDir
                    & dotnet build | Out-Host
                    Write-Host "? Build concluído." -ForegroundColor Green
                }
                catch { Write-Host "? Erro no build: $($_.Exception.Message)" -ForegroundColor Red }
                finally { Pop-Location }
            }
            '3' { Start-Process $BaseUrl | Out-Null }
            '4' {
                try {
                    Write-Host "?? Parando container '$ContainerName'..." -ForegroundColor Yellow
                    & docker stop $ContainerName | Out-Host
                    Write-Host "? Container parado." -ForegroundColor Green
                }
                catch { Write-Host "? Falha ao parar o container: $($_.Exception.Message)" -ForegroundColor Red }
            }
            '0' { Write-Host '?? Encerrando.' -ForegroundColor Cyan; break }
            Default { Write-Host '? Opção inválida.' -ForegroundColor Red }
        }
    }
}

# =====================
# Fluxo principal
# =====================
try {
    Write-Host '============================================================' -ForegroundColor DarkGray
    Write-Host '     Automação de Análise Local com SonarQube (Docker)     ' -ForegroundColor DarkGray
    Write-Host '============================================================' -ForegroundColor DarkGray

    # Verificações de ferramentas
    Assert-Tool -Name 'docker'
    Assert-Tool -Name 'dotnet'
    Assert-DotNetSonarScanner

    # Container SonarQube
    Ensure-SonarContainer -ContainerName $Container -Image $Image

    # Espera ficar saudável (com suporte a login manual)
    if (Wait-ForSonar -BaseUrl $Url -Timeout $TimeoutSec -EnableVerbose:([bool]$EnableVerbose)) {
        # Executa análise
        $projDir = Get-ProjectDirectory
        Push-Location $projDir
        try {
            Invoke-SonarAnalysis -ProjectKey $ProjectKey -BaseUrl $Url -Token $Token
        }
        finally { Pop-Location }

        # Menu pós-análise
        Show-Menu -BaseUrl $Url -ContainerName $Container
    }
}
catch {
    Write-Host "? Erro: $($_.Exception.Message)" -ForegroundColor Red
    # Ainda permite acessar menu para ações manuais
    Show-Menu -BaseUrl $Url -ContainerName $Container
}
