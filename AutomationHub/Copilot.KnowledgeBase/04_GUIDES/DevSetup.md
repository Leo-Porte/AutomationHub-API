# Guia de Ambiente de Desenvolvimento (Dev Setup)

## Requisitos
- .NET 8 SDK
- Docker Desktop (opcional, para SonarQube local)
- PostgreSQL (planejado; ainda não requerido no código atual)

## Passos
1. Clonar o repositório
2. Restaurar e compilar:
```
dotnet restore
dotnet build
```
3. Executar a API (perfil padrão):
```
dotnet run --project AutomationHub/AutomationHub.csproj
```
4. Acessar documentação Swagger:
- `https://localhost:5001/swagger` (ou porta configurada)

## Configuração de segredos (OpenAI)
- Configurar `OpenAI:ApiKey` via `appsettings.json`, `dotnet user-secrets` ou variável de ambiente
- Exemplo via User Secrets (recomendado para desenvolvimento):
```
dotnet user-secrets init --project AutomationHub/AutomationHub.csproj
dotnet user-secrets set "OpenAI:ApiKey" "SEU_TOKEN_AQUI" --project AutomationHub/AutomationHub.csproj
```

## SonarQube local (opcional)
- Siga o guia `04_GUIDES/SonarLocal.md`
