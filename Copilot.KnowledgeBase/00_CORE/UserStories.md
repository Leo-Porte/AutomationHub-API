# User Stories (Casos de Uso)

## Enviar mensagem e obter resposta da IA
Como usuário do sistema,
quero enviar uma mensagem para a API
para receber uma resposta gerada pela IA.

- Dado que eu envio `POST /api/Chat/send` com `{ "message": "Olá" }`
- Quando o `ChatController` validar a mensagem
- Então o `OpenAIService` processará a requisição e retornará `ChatResponse`

## Mensagem inválida
Como usuário do sistema,
quero receber um erro claro quando enviar uma mensagem vazia,
para corrigir a entrada.

- Dado que eu envio `POST /api/Chat/send` com `{ "message": "" }`
- Então devo receber `400 Bad Request` com a mensagem: `Message cannot be empty.`

## Futuras histórias
- Autenticação e autorização de endpoints
- Persistência de histórico de conversas e auditoria
- Notificações e integrações com serviços externos
