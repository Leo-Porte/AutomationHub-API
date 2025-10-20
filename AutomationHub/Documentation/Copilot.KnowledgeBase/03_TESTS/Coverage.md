# Cobertura e An�lise de C�digo

## Fine Code Coverage
- Instale a extens�o no IDE ou configure no pipeline.
- Configure a sa�da para a pasta `Reports` na raiz do reposit�rio (ou do projeto).
- Execute `dotnet test` normalmente. Os relat�rios ficar�o dispon�veis em `Reports`.

Estrutura esperada (exemplo):
- `Reports/Coverage/index.htm` (dashboard)
- `Reports/Coverage/Report.xml` (Cobertura)
- `Reports/Coverage/Report.html` (HTML detalhado)

Dicas:
- Garanta que a pasta `Reports` esteja inclu�da no `.gitignore` caso os relat�rios sejam volumosos.
- Para multi-projetos, consolide configurando a vari�vel de ambiente `FineCodeCoverage` ou usando `Directory.Build.props` com:
```
<Project>
  <PropertyGroup>
    <FineCodeCoverage>true</FineCodeCoverage>
    <FineCodeCoverageOutputDirectory>$(SolutionDir)Reports\Coverage</FineCodeCoverageOutputDirectory>
    <CollectCoverage>true</CollectCoverage>
  </PropertyGroup>
</Project>
```

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
- O script sobe o container Docker (`sonarqube:lts-community`), aguarda `GREEN`, roda `begin > build > end` e abre o painel autom�tico

## Indicadores recomendados
- Duplica��o: < 3%
- Code Smells: zero cr�ticos
- Vulnerabilidades: zero
