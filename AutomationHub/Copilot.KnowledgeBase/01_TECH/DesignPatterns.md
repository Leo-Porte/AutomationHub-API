# Padrões e Práticas Utilizados

## Inversão de Controle / Injeção de Dependência (DI)
- Configurada no `Program.cs` via `builder.Services.Add...`
- `OpenAIService` registrado como singleton recebendo a API key via `IConfiguration`

## DTOs / Request-Response Models
- `ChatRequest` e `ChatResponse` modelam entradas e saídas de endpoints

## Controller-Service Separation
- `ChatController` delega a lógica para `OpenAIService`

## Extension Methods para infraestrutura
- `SwaggerConfiguration` expõe `AddSwaggerDocumentation()` e `UseSwaggerDocumentation()` para manter o `Program.cs` enxuto

## Convenções REST e Documentação Swagger
- Anotações e comentários XML em controllers e modelos para enriquecer o Swagger

## Padrões planejados
- Repository/Unit of Work (para PostgreSQL)
- Mediator (ex.: MediatR) para desacoplamento de casos de uso
- Strategy/Factory para múltiplos provedores de IA, se necessário
