# AutomationHub-API � Vis�o Geral

Este reposit�rio cont�m a API AutomationHub-API, constru�da em .NET 8 (ASP.NET Core). A API centraliza automa��es internas e exp�e integra��es para automa��es externas, oferecendo uma camada simples de orquestra��o via HTTP.

## Objetivos do sistema
- Automatizar fluxos internos e preparar integra��es com automa��es externas
- Fornecer um ponto central de comunica��o ass�ncrona com servi�os de IA e, futuramente, servi�os de dom�nio (Auth, Finance, Storage, Notifications)

## Tecnologias principais
- Linguagem: C# (.NET 8)
- Framework: ASP.NET Core Web API
- Documenta��o: Swagger (Swashbuckle)
- Observabilidade de qualidade: SonarQube (execu��o local via script PowerShell)
- Banco de dados: PostgreSQL (planejado)

## Estrutura atual (alto n�vel)
- `AutomationHub/Controllers` � Controllers HTTP (ex.: `ChatController`)
- `AutomationHub/Services` � Servi�os de aplica��o (ex.: `OpenAIService`)
- `AutomationHub/Models` � Modelos/DTOs (ex.: `ChatRequest`, `ChatResponse`)
- `AutomationHub/Infrastructure/Swagger` � Configura��es de Swagger via m�todos de extens�o (`SwaggerConfiguration`)
- `Program.cs` � Composition root (DI, middlewares e pipeline minimalista)

## Fluxo t�pico de requisi��o
1. Cliente envia requisi��o HTTP ? Controller (`ChatController`)
2. Controller valida entrada (`ChatRequest`) e delega ao servi�o (`OpenAIService`)
3. Servi�o integra com o provedor de IA (SDK a definir/instalar) e retorna `ChatResponse`
4. Controller transforma em `200 OK` com `ChatResponse` (ou `400 Bad Request` em caso de valida��o)

## Pr�ximos passos
- Adicionar persist�ncia real (PostgreSQL + EF Core ou Dapper)
- Implementar testes (unit�rios e de integra��o) com cobertura monitorada (Fine Code Coverage) e an�lise no SonarQube
- Evoluir m�dulos (Auth, Finance, Storage, Notifications)

<!-- META:START -->
Arquivos: 22 | Atualizado: 2025-10-20 02:00:03
<!-- META:END -->

