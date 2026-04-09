---
id: "squads/inventory-intelligence-squad/steps/step-02-sanitize"
execution: subagent
agent: "squads/inventory-intelligence-squad/agents/dora-dados"
inputFile: "squads/inventory-intelligence-squad/output/raw_ingested_data.json"
outputFile: "squads/inventory-intelligence-squad/output/sanitized_data.json"
---

# Step 02: Sanitização e Normalização

## Context Loading
- `squads/inventory-intelligence-squad/output/raw_ingested_data.json`

## Instructions
1. Remova duplicatas e linhas vazias.
2. Formate as colunas de preço e custo para números reais (float).
3. Padronize as categorias de produtos e datas.
4. Identifique e trate valores nulos (ex: estoques negativos que viram zero).

## Output Format
Um arquivo `sanitized_data.json` limpo e pronto para análise financeira.
