# Vis�o de Dom�nio (Domain Overview)

Este documento descreve as entidades (modelos) atuais, servi�os e os relacionamentos existentes na API.

## Entidades (Models / DTOs)

### `ChatRequest`
- Propriedades:
  - `string? Message` � mensagem enviada pelo cliente.
- Observa��es:
  - Valida��o no controller: n�o pode ser nula ou vazia.

### `ChatResponse`
- Propriedades:
  - `string? Reply` � resposta gerada pelo servi�o de IA
  - `DateTime Timestamp` � data/hora da gera��o da resposta

## Servi�os

### `OpenAIService`
- M�todo principal:
  - `Task<ChatResponse> SendMessageAsync(ChatRequest request)`
- Responsabilidade:
  - Preparar a entrada para o provedor de IA, enviar a mensagem e formatar a resposta em `ChatResponse`.
- Depend�ncias:
  - Um cliente de IA (ex.: `OpenAIClient`) � a implementa��o exata do SDK ainda precisa ser instalada/ajustada no projeto.

## Controllers

### `ChatController`
- Endpoint: `POST api/Chat/send`
- Fluxo:
  1. Valida `ChatRequest.Message`
  2. Chama `OpenAIService.SendMessageAsync`
  3. Retorna `200 OK` com `ChatResponse` ou `400 Bad Request` quando inv�lido

## Relacionamentos
- `ChatController` ? depende de ? `OpenAIService`
- `OpenAIService` ? depende de ? Prov�vel SDK de IA (a definir/instalar)

## Futuro pr�ximo
- Introdu��o de camada de persist�ncia (PostgreSQL) para armazenar hist�rico de conversas, auditoria e configura��es
- Estrutura��o de m�dulos (Auth, Finance, Storage, Notifications) com entidades espec�ficas
