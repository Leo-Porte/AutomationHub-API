#requires -Version 5.1
[CmdletBinding()]param()
$ErrorActionPreference = 'Stop'

function Write-Log {
  param([string]$Message,[ConsoleColor]$Color=[ConsoleColor]::Gray)
  $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  Write-Host "[$ts] $Message" -ForegroundColor $Color
}

function Get-KbRoot { (Resolve-Path (Join-Path $PSScriptRoot '..')).Path }

function Reindex-KnowledgeBase {
  $kb = Get-KbRoot
  $files = Get-ChildItem -Path $kb -Recurse -File -Include *.md | Sort-Object FullName
  $indexPath = Join-Path $kb 'INDEX.json'
  $index = @()
  foreach ($f in $files) {
    $rel = Resolve-Path -Relative $f.FullName
    $index += [pscustomobject]@{
      Path = $rel
      Name = $f.Name
      Size = $f.Length
      UpdatedAt = $f.LastWriteTimeUtc.ToString('o')
    }
  }
  $index | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $indexPath -Encoding UTF8
  Write-Log "Index gerado: $indexPath" Green
}

function Update-RootReadme {
  $kb = Get-KbRoot
  $readme = Join-Path $kb '00_CORE/README.md'
  $files = Get-ChildItem -Path $kb -Recurse -File -Include *.md
  $count = @($files).Count
  $date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  $badge = "Arquivos: $count | Atualizado: $date"
  $content = Get-Content -LiteralPath $readme -Raw
  if ($content -match '<!-- META:START -->[\s\S]*<!-- META:END -->') {
    $content = $content -replace '<!-- META:START -->[\s\S]*<!-- META:END -->', "<!-- META:START -->`n$badge`n<!-- META:END -->"
  } else {
    $content = ($content.TrimEnd() + "`n`n<!-- META:START -->`n$badge`n<!-- META:END -->`n")
  }
  Set-Content -LiteralPath $readme -Encoding UTF8 -Value $content
  Write-Log "README atualizado" Green
}

function Generate-IncrementalSummary {
  $kb = Get-KbRoot
  $summaryPath = Join-Path $kb '05_HISTORY/WeeklySummary.md'
  $stat = ''
  try { $stat = git diff --stat } catch { $stat = '' }
  $block = @(
    "", "### Sync $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')", '',
    '```', ($stat ? $stat : 'Sem alterações pendentes'), '```', ''
  ) -join "`n"
  Add-Content -LiteralPath $summaryPath -Encoding UTF8 -Value $block
  Write-Log "Resumo incremental anexado ao WeeklySummary" Cyan
}

Reindex-KnowledgeBase
Update-RootReadme
Generate-IncrementalSummary
