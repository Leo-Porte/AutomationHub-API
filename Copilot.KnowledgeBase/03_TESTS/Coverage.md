# Cobertura e An�lise de C�digo

## Fine Code Coverage
- Instalar a extens�o no IDE (ou habilitar nos pipelines)
- Executar `dotnet test` e verificar hist�rico de cobertura

## SonarQube Local
- O reposit�rio cont�m `analyze.ps1` para automa��o local
- Crie um arquivo `secrets.ps1` na raiz com:
```
$Token = "sqp_SEU_TOKEN_AQUI"
```
- Execute:
```
pwsh -ExecutionPolicy Bypass -File .\analyze.ps1
```
- O script sobe o container Docker (`sonarqube:lts-community`), aguarda `GREEN`, roda `begin ? build ? end` e abre o painel autom�tico

## Indicadores recomendados
- Duplica��o: < 3%
- Code Smells: zero cr�ticos
- Vulnerabilidades: zero
