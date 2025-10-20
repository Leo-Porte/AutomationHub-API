# Endpoints da API

A API está documentada via Swagger. Abaixo, uma visão de alto nível dos endpoints existentes no código.

## `POST /api/Chat/send`
- Descrição: Envia uma mensagem para o serviço de IA e retorna uma resposta gerada
- Request body (`application/json`):
```json
{
  "message": "texto da sua pergunta"
}
```
- Responses:
  - `200 OK`
    - Body:
    ```json
    {
      "reply": "resposta gerada",
      "timestamp": "2025-01-01T12:00:00Z"
    }
    ```
  - `400 Bad Request` — quando `message` não for informado ou for vazio

### Exemplo cURL
```
curl -X POST "https://localhost:5001/api/Chat/send" \
  -H "Content-Type: application/json" \
  -d '{"message":"Olá, mundo!"}'
```

## Swagger
- Ambiente de desenvolvimento: `/swagger`
- As configurações ficam em `Infrastructure/Swagger/SwaggerConfiguration.cs`
