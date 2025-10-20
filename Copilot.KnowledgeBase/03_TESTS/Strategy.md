# Estrat�gia de Testes

## Objetivos
- Garantir a qualidade e estabilidade da API
- Viabilizar refatora��es com seguran�a

## Tipos de teste
- Unit�rios: servi�os e valida��es
- Integra��o: controllers (testando pipeline m�nimo, sem depend�ncias externas reais)

## Diretrizes
- Mockar SDKs externos (ex.: provedor de IA)
- Garantir cobertura m�nima por camada (ex.: 70% Application/Services)
- Executar localmente via `dotnet test` com Fine Code Coverage
