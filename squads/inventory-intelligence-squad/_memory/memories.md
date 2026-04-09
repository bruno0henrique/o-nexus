# Squad Memory: Inventory Intelligence Squad

## Estilo de Escrita
- Uso de termos financeiros técnicos (Liquidez, Capital Travado, Ruptura).
- Tom executivo e focado em lucro imediato.

## Design Visual
- **Padrão Nexus Estoque Pro:** Utilizar estritamente o modelo visual em `/resumo`.
- **Estética:** Glassmorphism + Glow Animations.
- **Identidade:** Fundo profundo (#0a0c10), cards (#111827), e acentos Blue (#3b82f6).
- **Tipografia:** 'Inter' para corpo e 'Space Grotesk' para títulos/KPIs.

## Estrutura de Conteúdo
- KPIs primeiro, detalhes depois.
- Propor ações imediatas para cada anomalia identificada.

## Proibições Explícitas
- Uso de Streamlit (proibido para este squad em favor de HTML/CSS/JS).
- Design "Light Mode" (proibido).
- Termos amadores (gráfico bonitinho, planilha arrumada).

## Técnico (específico do squad)
- Persistência obrigatória em Supabase/PostgreSQL.
- Normalização rigorosa via Pandas antes da auditoria.
- **Estrutura de Dashboard:** Seguir o layout de `/resumo/index.html` (Header com logo 'N', KPI Grid, Charts, Erros de Auditoria, IDs Suspeitos e Blocos de Resumo final).
- **Portabilidade:** Copiar o `inventory_analysis.json` final para dentro da pasta do dashboard para carregamento relativo.
- **Resumo Executivo:** O Passo 06 deve gerar um relatório no estilo `/resumo/resumo.txt`.

## Estrutura Obrigatória de Output (IMUTÁVEL)

**MODELO DE REFERÊNCIA:** `squads/inventory-intelligence-squad/output/2026-04-06-133728/`
NÃO alterar este modelo. NÃO alterar a estrutura de pastas. NÃO alterar o padrão visual do dashboard.

Toda execução DEVE gerar exatamente esta estrutura dentro de `squads/inventory-intelligence-squad/output/{run_id}/`:

```
{run_id}/                         ← pasta da execução atual
  index.html                      ← dashboard visual (IDÊNTICO ao modelo)
  styles.css                      ← estilos (IDÊNTICO ao modelo)
  scripts.js                      ← scripts (IDÊNTICO ao modelo)
  inventory_analysis.json         ← JSON final copiado para carga relativa pelo dashboard
  v1/                             ← pasta de artefatos intermediários
    raw_ingested_data.json
    sanitized_data.json
    audit_results.json
    inventory_analysis.json
    sync_log.md
```

**Regras:**
- `index.html`, `styles.css`, `scripts.js` ficam na raiz de `{run_id}/` para carregamento relativo.
- O `inventory_analysis.json` na raiz de `{run_id}/` é uma cópia do gerado em `v1/`, para que o `scripts.js` o carregue via Fetch API sem caminhos absolutos.
- O dashboard deve poder ser aberto diretamente no navegador clicando em `index.html`.
- O design Glassmorphism + Glow Animations de `2026-04-06-133728/index.html` é o padrão definitivo — não modificar cores, layout ou estrutura HTML.
- `resumo.txt` vai dentro de `v1/` junto com os demais artefatos (não na raiz).
 
## Última Execução
- Run `2026-04-08-110609` executada e validada: dashboard e artefatos gerados seguindo o modelo `2026-04-06-133728`.
  - `loja_id` usado: `289cfb8e-2554-4185-91ad7-84bc242493d0`
  - `sync_log.md`: 0 erros (ver `output/2026-04-08-110609/v1/sync_log.md`).

## Versão do Projeto
- Versão atual do repositório: `1.0.1` (tag `v1.0.1`).
  - `package.json` atualizado para `1.0.1`.
  - `pubspec.yaml` atualizado para `1.0.1+2`.


# Execução: Inventory Intelligence Squad

- Data: 2026-04-08
- Executado: passo de ingestão (CSV → JSON)
- Entrada: `squads/inventory-intelligence-squad/input/auditoria_nexus_1.csv`
- Saída gerada: `squads/inventory-intelligence-squad/output/raw_ingested_data.json`

Observações rápidas:
- Ingestão completada sem erros.
- Arquivo JSON preserva todos os campos originais das colunas do CSV.

Próximos passos recomendados:
1. Rodar sanitização (`step-02-sanitize.md`) para normalizar tipos e colunas.
2. Executar auditoria (step-03) e revisar checkpoint (step-04) antes de persistir.

Status: `ingest` concluído.

## Execução interrompida

- Data: 2026-04-08
- Ação do usuário: Cancelar persistência no checkpoint (opção 3).
- Estado atual: Pipeline pausado no passo 04 (checkpoint). Nenhuma persistência foi executada.

Próximos passos sugeridos:
- `1` Revisar `squads/inventory-intelligence-squad/output/audit_results.json` e `sanitized_data.json`.
- `2` Persistir resultados no banco (executar passo-05 `persist`).
- `3` Cancelar totalmente e arquivar os resultados localmente.
