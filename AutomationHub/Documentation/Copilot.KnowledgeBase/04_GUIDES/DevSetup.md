# Guia de Ambiente de Desenvolvimento (Dev Setup)

## Requisitos
- .NET 8 SDK
- Docker Desktop (opcional, para SonarQube local)
- PowerShell 5.1+ ou PowerShell 7+

## Passos
1. Clonar o reposit�rio
2. Restaurar e compilar:
```
dotnet restore
dotnet build
```
3. Executar a API (perfil padr�o):
```
dotnet run --project AutomationHub/AutomationHub.csproj
```
4. Acessar documenta��o Swagger:
- `https://localhost:5001/swagger` (ou porta configurada)

## Configura��o de segredos (OpenAI)
- Configurar `OpenAI:ApiKey` via `appsettings.json`, `dotnet user-secrets` ou vari�vel de ambiente
- Exemplo via User Secrets (recomendado para desenvolvimento):
```
dotnet user-secrets init --project AutomationHub/AutomationHub.csproj
dotnet user-secrets set "OpenAI:ApiKey" "SEU_TOKEN_AQUI" --project AutomationHub/AutomationHub.csproj
```

## SonarQube local (opcional)
- Siga o guia `04_GUIDES/SonarLocal.md`

## Melhorias automatizadas (improvement.ps1)
Local: `Documentation/Copilot.KnowledgeBase/tools/improvement.ps1`

- Abrir uma melhoria:
```
pwsh -ExecutionPolicy Bypass -File Documentation/Copilot.KnowledgeBase/tools/improvement.ps1 open "Descri��o da melhoria"
```
- Fechar a melhoria ativa (gera resumo no WeeklySummary e Refactors):
```
pwsh -ExecutionPolicy Bypass -File Documentation/Copilot.KnowledgeBase/tools/improvement.ps1 close
```
- Cancelar a melhoria ativa (remove o arquivo e o estado):
```
pwsh -ExecutionPolicy Bypass -File Documentation/Copilot.KnowledgeBase/tools/improvement.ps1 cancel
```

## Sincroniza��o manual da base (sync-knowledge.ps1)
Local: `Documentation/Copilot.KnowledgeBase/tools/sync-knowledge.ps1`

- Reindexar, atualizar README e anexar resumo incremental:
```
pwsh -ExecutionPolicy Bypass -File Documentation/Copilot.KnowledgeBase/tools/sync-knowledge.ps1
```

## Copilot Chat como contexto
- Dica: "Use o conte�do da pasta `Documentation/Copilot.KnowledgeBase` como contexto."
- Ao abrir um chat, referencie arquivos por caminho relativo para melhor precis�o.
