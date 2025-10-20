# User Stories (Casos de Uso)

## Enviar mensagem e obter resposta da IA
Como usu�rio do sistema,
quero enviar uma mensagem para a API
para receber uma resposta gerada pela IA.

- Dado que eu envio `POST /api/Chat/send` com `{ "message": "Ol�" }`
- Quando o `ChatController` validar a mensagem
- Ent�o o `OpenAIService` processar� a requisi��o e retornar� `ChatResponse`

## Mensagem inv�lida
Como usu�rio do sistema,
quero receber um erro claro quando enviar uma mensagem vazia,
para corrigir a entrada.

- Dado que eu envio `POST /api/Chat/send` com `{ "message": "" }`
- Ent�o devo receber `400 Bad Request` com a mensagem: `Message cannot be empty.`

## Futuras hist�rias
- Autentica��o e autoriza��o de endpoints
- Persist�ncia de hist�rico de conversas e auditoria
- Notifica��es e integra��es com servi�os externos
