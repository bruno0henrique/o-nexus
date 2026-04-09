---
id: "squads/inventory-intelligence-squad/steps/step-03-audit"
execution: subagent
agent: "squads/inventory-intelligence-squad/agents/elias-economia"
inputFile: "squads/inventory-intelligence-squad/output/sanitized_data.json"
outputFile: "squads/inventory-intelligence-squad/output/audit_results.json"
---

# Step 03: Auditoria Financeira de Estoque

## Context Loading
- `squads/inventory-intelligence-squad/output/sanitized_data.json`
- `_opensquad/_memory/company.md` (Para conferir as regras de auditoria).

## Instructions
1. Calcule o **Capital Travado** (Custo x Quantidade) por item e categoria.
2. Identifique **Riscos de Perda** (Vencimento próximo ou estoque acima do giro recomendado).
3. Classifique os itens em **Prioridade ABC** (Classe A: Alto valor, Giro moderado; Classe B: Médio; Classe C: Baixo).
4. Gere recomendações específicas de ação (ex: "Promover item X para evitar perda", "Reduzir compra de item Y").

## Output Format
Um arquivo `audit_results.json` contendo KPIs de capital e alertas estratégicos.
