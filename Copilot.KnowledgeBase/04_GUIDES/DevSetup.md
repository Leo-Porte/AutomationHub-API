# Guia de Ambiente de Desenvolvimento (Dev Setup)

## Requisitos
- .NET 8 SDK
- Docker Desktop (opcional, para SonarQube local)
- PostgreSQL (planejado; ainda n�o requerido no c�digo atual)

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
