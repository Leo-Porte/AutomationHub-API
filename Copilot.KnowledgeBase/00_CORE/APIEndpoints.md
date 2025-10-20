# Endpoints da API

A API est� documentada via Swagger. Abaixo, uma vis�o de alto n�vel dos endpoints existentes no c�digo.

## `POST /api/Chat/send`
- Descri��o: Envia uma mensagem para o servi�o de IA e retorna uma resposta gerada
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
  - `400 Bad Request` � quando `message` n�o for informado ou for vazio

### Exemplo cURL
```
curl -X POST "https://localhost:5001/api/Chat/send" \
  -H "Content-Type: application/json" \
  -d '{"message":"Ol�, mundo!"}'
```

## Swagger
- Ambiente de desenvolvimento: `/swagger`
- As configura��es ficam em `Infrastructure/Swagger/SwaggerConfiguration.cs`
