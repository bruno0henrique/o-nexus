---
id: "squads/inventory-intelligence-squad/steps/step-06-dashboard"
execution: subagent
agent: "squads/inventory-intelligence-squad/agents/igor-integracao"
inputFile: "squads/inventory-intelligence-squad/output/audit_results.json"
outputFile: "squads/inventory-intelligence-squad/output/inventory_analysis.json"
---

# Step 06: Consolidação Executiva (Padrão Nexus Estoque Pro)

## Context Loading
- `squads/inventory-intelligence-squad/output/audit_results.json`
- `/resumo/resumo.txt` (Como guia de estrutura para o resumo executivo).

## Instructions
1. **Consolidação de Dados:** 
   - Agrupe os itens do `audit_results.json`.
   - Prepare a lista `inventory`: `{ sku, desc, entries, exits, balance, valorTotal, status, originalIds }`.
   - Como não temos 'entradas' e 'saídas' separadas no CSV atual, use 'Estoque' como 'saldo' e 'entradas' (ou mapeie logicamente conforme o contexto do inventário).
2. **Identificação de Erros & Suspeitos:**
   - Crie a lista `errors`: `{ sku, problema, acao: 'INVESTIGAR' }` para itens com status 'CAPITAL MORTO', 'VENCIMENTO' ou 'PREJUÍZO'.
   - Crie a lista `suspiciousIds`: `{ normalized, original, status: 'DIFERENTE' }` para SKUs similares (ex: que contenham 'O' no lugar de '0').
3. **Resumo Executivo:** 
   - Gere um relatório `resumo.txt` em `squads/inventory-intelligence-squad/output/` seguindo o exato modelo de `/resumo/resumo.txt`.

## Output Format
- `inventory_analysis.json` contendo as três listas: `inventory`, `errors`, e `suspiciousIds`.
- `resumo.txt` contendo o resumo executivo textual.
