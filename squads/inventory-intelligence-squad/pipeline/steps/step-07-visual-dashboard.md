---
id: "squads/inventory-intelligence-squad/steps/step-07-visual-dashboard"
execution: subagent
agent: "squads/inventory-intelligence-squad/agents/sergio-frontend"
inputFile: "squads/inventory-intelligence-squad/output/inventory_analysis.json"
outputFiles: 
  - "squads/inventory-intelligence-squad/output/{folder_name}/index.html"
  - "squads/inventory-intelligence-squad/output/{folder_name}/style.css"
  - "squads/inventory-intelligence-squad/output/{folder_name}/script.js"
---

# Step 07: Visual Dashboard - Nexus Estoque Pro

## Context Loading
- `squads/inventory-intelligence-squad/output/inventory_analysis.json` (Contendo as listas inventory, errors e suspiciousIds).
- `/resumo/index.html`, `/resumo/styles.css`, `/resumo/scripts.js` (Arquivos de modelo visual).

## Instructions
1. **Clonagem de Design:** 
   - Utilize a estrutura HTML e as classes de CSS (Tailwind + Custom) de `/resumo/index.html`.
   - Mantenha a estética **Glassmorphism + Glow Animations**.
   - Use o logo circular com a letra 'N'.
2. **Injeção Dinâmica:**
   - O gráfico de **Saldo por Item** deve apresentar os saldos consolidados.
   - O gráfico de **Entrada vs Saída** deve comparar os fluxos.
   - Popule as tabelas de `Movimentação Consolidada`, `Erros de Auditoria` e `IDs Suspeitos`.
3. **Resumo Final:** 
   - Preencha as seções de `Recomendações`, `Auditoria` e `Próximos Passos` baseadas na análise do Elias Economia do Passo 03.

## Output Format
- Web Interface completa (HTML/CSS/JS) no diretório de saída solicitado pelo usuário.

## Veto Conditions
1. O design foge do padrão Glassmorphism/Glow de `/resumo`.
2. As tabelas secundárias (Erros/Suspeitos) não estão visíveis ou populadas.
3. Gráficos não carregam ou não são interativos via Chart.js.
