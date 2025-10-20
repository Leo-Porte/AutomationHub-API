# Visão de Domínio (Domain Overview)

Este documento descreve as entidades (modelos) atuais, serviços e os relacionamentos existentes na API.

## Entidades (Models / DTOs)

### `ChatRequest`
- Propriedades:
  - `string? Message` — mensagem enviada pelo cliente.
- Observações:
  - Validação no controller: não pode ser nula ou vazia.

### `ChatResponse`
- Propriedades:
  - `string? Reply` — resposta gerada pelo serviço de IA
  - `DateTime Timestamp` — data/hora da geração da resposta

## Serviços

### `OpenAIService`
- Método principal:
  - `Task<ChatResponse> SendMessageAsync(ChatRequest request)`
- Responsabilidade:
  - Preparar a entrada para o provedor de IA, enviar a mensagem e formatar a resposta em `ChatResponse`.
- Dependências:
  - Um cliente de IA (ex.: `OpenAIClient`) — a implementação exata do SDK ainda precisa ser instalada/ajustada no projeto.

## Controllers

### `ChatController`
- Endpoint: `POST api/Chat/send`
- Fluxo:
  1. Valida `ChatRequest.Message`
  2. Chama `OpenAIService.SendMessageAsync`
  3. Retorna `200 OK` com `ChatResponse` ou `400 Bad Request` quando inválido

## Relacionamentos
- `ChatController` ? depende de ? `OpenAIService`
- `OpenAIService` ? depende de ? Provável SDK de IA (a definir/instalar)

## Futuro próximo
- Introdução de camada de persistência (PostgreSQL) para armazenar histórico de conversas, auditoria e configurações
- Estruturação de módulos (Auth, Finance, Storage, Notifications) com entidades específicas
