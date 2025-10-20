# SonarQube Local � Guia de Execu��o

A automa��o local � feita via `analyze.ps1` na raiz.

## Pr�-requisitos
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

## Execu��o
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
