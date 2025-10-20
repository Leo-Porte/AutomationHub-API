# Cobertura e Análise de Código

## Fine Code Coverage
- Instale a extensão no IDE ou configure no pipeline.
- Configure a saída para a pasta `Reports` na raiz do repositório (ou do projeto).
- Execute `dotnet test` normalmente. Os relatórios ficarão disponíveis em `Reports`.

Estrutura esperada (exemplo):
- `Reports/Coverage/index.htm` (dashboard)
- `Reports/Coverage/Report.xml` (Cobertura)
- `Reports/Coverage/Report.html` (HTML detalhado)

Dicas:
- Garanta que a pasta `Reports` esteja incluída no `.gitignore` caso os relatórios sejam volumosos.
- Para multi-projetos, consolide configurando a variável de ambiente `FineCodeCoverage` ou usando `Directory.Build.props` com:
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
- O repositório contém `analyze.ps1` para automação local
- Crie um arquivo `secrets.ps1` na raiz com:
```
$Token = "sqp_SEU_TOKEN_AQUI"
```
- Execute:
```
pwsh -ExecutionPolicy Bypass -File .\analyze.ps1
```
- O script sobe o container Docker (`sonarqube:lts-community`), aguarda `GREEN`, roda `begin > build > end` e abre o painel automático

## Indicadores recomendados
- Duplicação: < 3%
- Code Smells: zero críticos
- Vulnerabilidades: zero
