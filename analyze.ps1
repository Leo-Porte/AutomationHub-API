#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =====================
# Segredos locais
# =====================
Write-Host "?? Loading local secrets..." -ForegroundColor DarkCyan
if (Test-Path ".\secrets.ps1") {
    . .\secrets.ps1
    Write-Host "? Secrets loaded successfully." -ForegroundColor Green
} else {
    Write-Warning "??  secrets.ps1 not found. Please create it with your SonarQube token."
    exit 1
}

# =====================
# Configura��es
# =====================
$ProjectKey          = 'AutomationHub'               # Nome do projeto no SonarQube (project key)
$SonarUrl            = 'http://localhost:9000'       # URL do SonarQube
$SonarToken          = $Token                        # Token do SonarQube importado de secrets.ps1
$SonarContainerName  = 'sonarqube'                   # Nome do container Docker
$SonarImage          = 'sonarqube:lts-community'     # Imagem do SonarQube
$TimeoutSeconds      = 120                           # Timeout para o health check

# =====================
# Fun��es auxiliares
# =====================
function Write-Info($Message)   { Write-Host "[INFO]  $Message" -ForegroundColor Cyan }
function Write-Ok($Message)     { Write-Host "[OK]    $Message" -ForegroundColor Green }
function Write-Warn($Message)   { Write-Host "[WARN]  $Message" -ForegroundColor Yellow }
function Write-ErrMsg($Message) { Write-Host "[ERROR] $Message" -ForegroundColor Red }

function Assert-Tool {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [string] $CheckArgs = '--version'
    )
    Write-Info "Verificando ferramenta: $Name"
    try {
        $null = & $Name $CheckArgs
        Write-Ok "$Name encontrado."
    }
    catch {
        throw "Ferramenta '$Name' n�o encontrada ou inacess�vel. Adicione ao PATH ou instale-a."
    }
}

function Assert-DotNetSonarScanner {
    Write-Info 'Verificando dotnet-sonarscanner'
    try {
        $null = & dotnet sonarscanner --version
        Write-Ok 'dotnet-sonarscanner encontrado.'
    }
    catch {
        throw "'dotnet sonarscanner' n�o est� dispon�vel. Instale com: dotnet tool update -g dotnet-sonarscanner"
    }
}

function Ensure-SonarContainer {
    param(
        [Parameter(Mandatory)] [string] $ContainerName,
        [Parameter(Mandatory)] [string] $Image
    )

    Write-Info "Garantindo container '$ContainerName' com imagem '$Image'"

    $exists = $false
    try {
        $id = (docker ps -a --filter "name=^/$ContainerName$" --format '{{.ID}}')
        if (![string]::IsNullOrWhiteSpace($id)) { $exists = $true }
    }
    catch { throw "Falha ao consultar containers Docker. Verifique o Docker Desktop/Engine." }

    if (-not $exists) {
        Write-Info "Container n�o encontrado. Baixando imagem e criando container..."
        & docker pull $Image | Out-Host

        # Porta padr�o 9000
        & docker run -d --name $ContainerName -p 9000:9000 $Image | Out-Host
        Write-Ok "Container '$ContainerName' criado."
    }
    else {
        # Verifica se est� rodando
        $isRunning = (docker inspect -f '{{.State.Running}}' $ContainerName) -eq 'true'
        if (-not $isRunning) {
            Write-Info "Container existe, mas est� parado. Iniciando..."
            & docker start $ContainerName | Out-Host
            Write-Ok "Container iniciado."
        }
        else {
            Write-Ok "Container j� est� em execu��o."
        }
    }
}

function Wait-ForSonarReady {
    param(
        [Parameter(Mandatory)] [string] $BaseUrl,
        [int] $Timeout = 120
    )

    $healthEndpoint = "$BaseUrl/api/system/health"
    Write-Info "Aguardando SonarQube em: $healthEndpoint (timeout ${Timeout}s)"

    $deadline = (Get-Date).AddSeconds($Timeout)
    while ((Get-Date) -lt $deadline) {
        try {
            $resp = Invoke-RestMethod -Uri $healthEndpoint -Method Get -TimeoutSec 5
            $status = $resp.health
            if (-not $status) { $status = $resp.status }

            if ($status -eq 'GREEN') {
                Write-Ok 'SonarQube est� saud�vel (GREEN).'
                return $true
            }
            else {
                Write-Info "Status atual: $status. Tentando novamente..."
            }
        }
        catch {
            Write-Info 'Aguardando servi�o iniciar...'
        }
        Start-Sleep -Seconds 3
    }

    throw "SonarQube n�o ficou dispon�vel (GREEN) dentro de $Timeout segundos."
}

function Get-ProjectDirectory {
    # Garante que estamos na pasta que cont�m um �nico .csproj
    $here = Get-Location
    $csprojs = Get-ChildItem -Path $here -Filter *.csproj -File -ErrorAction SilentlyContinue

    if ($csprojs.Count -eq 1) {
        return $here
    }
    elseif ($csprojs.Count -gt 1) {
        throw 'Mais de um .csproj encontrado na pasta atual. Execute o script dentro da pasta do projeto (que cont�m apenas um .csproj).'
    }
    else {
        # Tenta localizar recursivamente um �nico .csproj (fallback amig�vel)
        $all = Get-ChildItem -Path $here -Filter *.csproj -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' }
        if ($all.Count -eq 1) {
            Write-Warn "Nenhum .csproj na pasta atual. Usando: $($all.FullName)"
            return $all.Directory
        }
        elseif ($all.Count -gt 1) {
            throw 'V�rios .csproj encontrados na �rvore. Execute o script dentro da pasta do projeto correto.'
        }
        else {
            throw 'Nenhum .csproj encontrado. Execute o script na pasta do projeto (.csproj).'
        }
    }
}

function Run-SonarAnalysis {
    param(
        [Parameter(Mandatory)] [string] $ProjectKey,
        [Parameter(Mandatory)] [string] $SonarUrl,
        [Parameter(Mandatory)] [string] $SonarToken
    )

    Write-Info 'Iniciando an�lise com SonarScanner...'

    & dotnet sonarscanner begin "/k:$ProjectKey" "/d:sonar.host.url=$SonarUrl" "/d:sonar.login=$SonarToken" | Out-Host

    Write-Info 'Executando build do projeto...'
    & dotnet build | Out-Host

    Write-Info 'Finalizando an�lise com SonarScanner...'
    & dotnet sonarscanner end "/d:sonar.login=$SonarToken" | Out-Host

    Write-Ok 'An�lise conclu�da com sucesso.'
}

# =====================
# Fluxo principal
# =====================
try {
    Write-Host '============================================================' -ForegroundColor DarkGray
    Write-Host '      Automa��o de An�lise Local com SonarQube (Docker)      ' -ForegroundColor DarkGray
    Write-Host '============================================================' -ForegroundColor DarkGray

    # 1) Verifica��es de ferramentas
    Assert-Tool -Name 'docker'
    Assert-Tool -Name 'dotnet'
    Assert-DotNetSonarScanner

    # 2) Container SonarQube
    Ensure-SonarContainer -ContainerName $SonarContainerName -Image $SonarImage

    # 3) Espera ficar saud�vel
    Wait-ForSonarReady -BaseUrl $SonarUrl -Timeout $TimeoutSeconds

    # 4) Ir para a pasta do projeto (.csproj)
    $projectDir = Get-ProjectDirectory
    Push-Location $projectDir
    Write-Info "Diret�rio do projeto: $((Get-Location).Path)"

    try {
        # 5) Executar an�lise
        Run-SonarAnalysis -ProjectKey $ProjectKey -SonarUrl $SonarUrl -SonarToken $SonarToken
    }
    finally {
        Pop-Location
    }

    # 6) Abrir painel do SonarQube
    Write-Info "Abrindo painel do SonarQube: $SonarUrl"
    Start-Process $SonarUrl | Out-Null

    Write-Ok 'Processo finalizado.'
}
catch {
    Write-ErrMsg $_
    exit 1
}
