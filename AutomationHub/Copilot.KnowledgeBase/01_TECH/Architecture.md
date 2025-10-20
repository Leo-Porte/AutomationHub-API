# Arquitetura

A solução segue uma arquitetura simples e evolutiva baseada em camadas, com princípios de Clean Code e Clean Architecture aplicados progressivamente.

## Camadas atuais
- API (Web): Controllers expõem endpoints REST
- Application/Services: lógica de orquestração (ex.: `OpenAIService`)
- Domain Models (Models): contratos de entrada/saída (`ChatRequest`, `ChatResponse`)
- Infrastructure: configurações e integrações técnicas (ex.: `SwaggerConfiguration`)

## Fluxo de dependências (intenção)
```
Presentation (API)
    ?
Application (Services)
    ?
Domain (Models)
    ? Infrastructure (técnico: Swagger, futuramente DB, cache, etc.)
```

## Pontos de extensão planejados
- Persistência: PostgreSQL (provavelmente EF Core ou Dapper)
- Observabilidade: logs estruturados, métricas e tracing
- Módulos: Auth, Finance, Storage, Notifications com boundaries definidos

## Decisões recentes
- Extração da configuração de Swagger para `Infrastructure/Swagger/SwaggerConfiguration` via métodos de extensão
- Ativação de geração de comentários XML para documentação no Swagger
