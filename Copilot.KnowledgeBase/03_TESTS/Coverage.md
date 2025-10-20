# Cobertura e Análise de Código

## Fine Code Coverage
- Instalar a extensão no IDE (ou habilitar nos pipelines)
- Executar `dotnet test` e verificar histórico de cobertura

## SonarQube Local
- O repositório contém `analyze.ps1` para automação local
- Crie um arquivo `secrets.ps1` na raiz com:
```
$Token = "sqp_SEU_TOKEN_AQUI"
```
- Execute:
```
pwsh -ExecutionPolicy Bypass -File .\analyze.ps1
```
- O script sobe o container Docker (`sonarqube:lts-community`), aguarda `GREEN`, roda `begin ? build ? end` e abre o painel automático

## Indicadores recomendados
- Duplicação: < 3%
- Code Smells: zero críticos
- Vulnerabilidades: zero
