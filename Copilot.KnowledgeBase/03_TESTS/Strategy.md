# Estratégia de Testes

## Objetivos
- Garantir a qualidade e estabilidade da API
- Viabilizar refatorações com segurança

## Tipos de teste
- Unitários: serviços e validações
- Integração: controllers (testando pipeline mínimo, sem dependências externas reais)

## Diretrizes
- Mockar SDKs externos (ex.: provedor de IA)
- Garantir cobertura mínima por camada (ex.: 70% Application/Services)
- Executar localmente via `dotnet test` com Fine Code Coverage
