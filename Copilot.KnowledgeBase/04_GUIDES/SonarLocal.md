# SonarQube Local — Guia de Execução

A automação local é feita via `analyze.ps1` na raiz.

## Pré-requisitos
- Docker Desktop ativo
- `dotnet-sonarscanner` instalado globalmente:
```
dotnet tool install --global dotnet-sonarscanner
```

## Segredos
Crie `secrets.ps1` na raiz com:
```
$Token = "sqp_SEU_TOKEN_AQUI"
```

## Execução
```
pwsh -ExecutionPolicy Bypass -File .\analyze.ps1 -EnableVerbose
```

## O que o script faz
- Garante container `sonarqube:lts-community`
- Aguarda `health: GREEN` com feedback visual
- Executa:
  - `dotnet sonarscanner begin`
  - `dotnet build`
  - `dotnet sonarscanner end`
- Abre o painel: `http://localhost:9000`
