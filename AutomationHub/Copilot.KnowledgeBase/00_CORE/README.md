# AutomationHub-API — Visão Geral

Este repositório contém a API AutomationHub-API, construída em .NET 8 (ASP.NET Core). A API centraliza automações internas e expõe integrações para automações externas, oferecendo uma camada simples de orquestração via HTTP.

## Objetivos do sistema
- Automatizar fluxos internos e preparar integrações com automações externas
- Fornecer um ponto central de comunicação assíncrona com serviços de IA e, futuramente, serviços de domínio (Auth, Finance, Storage, Notifications)

## Tecnologias principais
- Linguagem: C# (.NET 8)
- Framework: ASP.NET Core Web API
- Documentação: Swagger (Swashbuckle)
- Observabilidade de qualidade: SonarQube (execução local via script PowerShell)
- Banco de dados: PostgreSQL (planejado)

## Estrutura atual (alto nível)
- `AutomationHub/Controllers` — Controllers HTTP (ex.: `ChatController`)
- `AutomationHub/Services` — Serviços de aplicação (ex.: `OpenAIService`)
- `AutomationHub/Models` — Modelos/DTOs (ex.: `ChatRequest`, `ChatResponse`)
- `AutomationHub/Infrastructure/Swagger` — Configurações de Swagger via métodos de extensão (`SwaggerConfiguration`)
- `Program.cs` — Composition root (DI, middlewares e pipeline minimalista)

## Fluxo típico de requisição
1. Cliente envia requisição HTTP ? Controller (`ChatController`)
2. Controller valida entrada (`ChatRequest`) e delega ao serviço (`OpenAIService`)
3. Serviço integra com o provedor de IA (SDK a definir/instalar) e retorna `ChatResponse`
4. Controller transforma em `200 OK` com `ChatResponse` (ou `400 Bad Request` em caso de validação)

## Próximos passos
- Adicionar persistência real (PostgreSQL + EF Core ou Dapper)
- Implementar testes (unitários e de integração) com cobertura monitorada (Fine Code Coverage) e análise no SonarQube
- Evoluir módulos (Auth, Finance, Storage, Notifications)
