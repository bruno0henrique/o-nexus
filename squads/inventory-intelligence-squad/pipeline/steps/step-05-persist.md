---
id: "squads/inventory-intelligence-squad/steps/step-05-persist"
execution: subagent
agent: "squads/inventory-intelligence-squad/agents/igor-integracao"
inputFile: "squads/inventory-intelligence-squad/output/audit_results.json"
checkpointFile: "squads/inventory-intelligence-squad/output/checkpoint_input.md"
outputFile: "squads/inventory-intelligence-squad/output/sync_log.md"
---

# Step 05: Persistência no Supabase

## Context Loading
- `squads/inventory-intelligence-squad/output/audit_results.json`
- `squads/inventory-intelligence-squad/output/checkpoint_input.md` (contém `loja_id` definido no checkpoint)
- Arquivo `.env` (Para credenciais do banco).

## Instructions
1. Leia o `loja_id` do arquivo `checkpoint_input.md`.
2. Mapeie os registros de auditoria para as tabelas do Supabase/PostgreSQL, **utilizando o valor `loja_id` do checkpoint para o campo `loja_id`** na tabela `tabela_nexus` para vincular à loja correta.
3. Verifique se a tabela de estoque existe ou deve ser criada/atualizada.
4. Realize o `UPSERT` dos dados usando `(sku_id, loja_id)` como chave composta para garantir que o mesmo SKU de lojas diferentes não colida.
5. Gere um log detalhado da operação, registrando o `loja_id` utilizado.

## Output Format
Um arquivo `sync_log.md` confirmando a sincronização com a nuvem.
