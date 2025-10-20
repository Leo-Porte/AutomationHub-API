# Padr�es e Pr�ticas Utilizados

## Invers�o de Controle / Inje��o de Depend�ncia (DI)
- Configurada no `Program.cs` via `builder.Services.Add...`
- `OpenAIService` registrado como singleton recebendo a API key via `IConfiguration`

## DTOs / Request-Response Models
- `ChatRequest` e `ChatResponse` modelam entradas e sa�das de endpoints

## Controller-Service Separation
- `ChatController` delega a l�gica para `OpenAIService`

## Extension Methods para infraestrutura
- `SwaggerConfiguration` exp�e `AddSwaggerDocumentation()` e `UseSwaggerDocumentation()` para manter o `Program.cs` enxuto

## Conven��es REST e Documenta��o Swagger
- Anota��es e coment�rios XML em controllers e modelos para enriquecer o Swagger

## Padr�es planejados
- Repository/Unit of Work (para PostgreSQL)
- Mediator (ex.: MediatR) para desacoplamento de casos de uso
- Strategy/Factory para m�ltiplos provedores de IA, se necess�rio
