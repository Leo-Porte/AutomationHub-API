# Arquitetura

A solu��o segue uma arquitetura simples e evolutiva baseada em camadas, com princ�pios de Clean Code e Clean Architecture aplicados progressivamente.

## Camadas atuais
- API (Web): Controllers exp�em endpoints REST
- Application/Services: l�gica de orquestra��o (ex.: `OpenAIService`)
- Domain Models (Models): contratos de entrada/sa�da (`ChatRequest`, `ChatResponse`)
- Infrastructure: configura��es e integra��es t�cnicas (ex.: `SwaggerConfiguration`)

## Fluxo de depend�ncias (inten��o)
```
Presentation (API)
    ?
Application (Services)
    ?
Domain (Models)
    ? Infrastructure (t�cnico: Swagger, futuramente DB, cache, etc.)
```

## Pontos de extens�o planejados
- Persist�ncia: PostgreSQL (provavelmente EF Core ou Dapper)
- Observabilidade: logs estruturados, m�tricas e tracing
- M�dulos: Auth, Finance, Storage, Notifications com boundaries definidos

## Decis�es recentes
- Extra��o da configura��o de Swagger para `Infrastructure/Swagger/SwaggerConfiguration` via m�todos de extens�o
- Ativa��o de gera��o de coment�rios XML para documenta��o no Swagger
