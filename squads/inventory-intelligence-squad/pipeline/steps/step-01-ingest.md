---
id: "squads/inventory-intelligence-squad/steps/step-01-ingest"
execution: subagent
agent: "squads/inventory-intelligence-squad/agents/dora-dados"
inputFile: "squads/inventory-intelligence-squad/input/*.csv"
outputFile: "squads/inventory-intelligence-squad/output/raw_ingested_data.json"
---

# Step 01: Ingestão de Dados de Estoque

## Context Loading
- `squads/inventory-intelligence-squad/input/*.csv` (Planilhas brutas enviadas pelo cliente).

## Instructions
1. Escaneie o diretório de `input` em busca do arquivo CSV mais recente.
2. Identifique os nomes das colunas e os prepare para o processamento.
3. Converta o CSV para um formato JSON bruto (`raw_ingested_data.json`), preservando os valores originais, mesmo que "sujos".

## Output Format
Um arquivo JSON estruturado contendo todos os registros da planilha original.
