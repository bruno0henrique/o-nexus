---
id: "squads/inventory-intelligence-squad/steps/step-04-checkpoint"
type: checkpoint
outputFile: "squads/inventory-intelligence-squad/output/checkpoint_input.md"
message: |
  A auditoria de estoque foi concluída. Elias Economia identificou as oportunidades de capital.
  
  Antes de persistirmos no banco e gerarmos o dashboard, preciso de uma informação:
  
  **Qual é o ID da loja** para vincular corretamente os dados desta auditoria?
  (Ex: loja-001, store_sp_01, etc.)
  
  Após informar o ID, escolha como prosseguir:
  
  1. Confirmar ID e continuar (persistir no Supabase + gerar dashboard)
  2. Revisar `audit_results.json` antes de continuar
  3. Cancelar pipeline
---
# Step 04: Checkpoint de Revisão do Usuário

## Instruções do Pipeline Runner

1. Pergunte ao usuário o **ID da loja** que receberá os dados (campo de texto livre).
2. Após receber o ID, apresente as 3 opções numeradas acima.
3. Salve no `outputFile` tanto o ID da loja quanto a escolha do usuário no formato:
  ```
  loja_id: <valor informado pelo usuário>
  choice: <1, 2 ou 3>
  ```
4. Repasse `loja_id` para o Step 05 (Igor Integração) como contexto obrigatório para o UPSERT no Supabase.
