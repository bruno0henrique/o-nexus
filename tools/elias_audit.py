#!/usr/bin/env python3
"""Step 03 — Elias Economia: Auditoria Financeira de Estoque."""
import json
import os
from datetime import date

RUN_ID = "2026-04-08-040742"
TODAY = date(2026, 4, 8)
SQUAD = "squads/inventory-intelligence-squad"
INPUT = f"{SQUAD}/output/sanitized_data.json"
OUT_DIR = f"{SQUAD}/output/{RUN_ID}"
OUTPUT = f"{OUT_DIR}/audit_results.json"

os.makedirs(OUT_DIR, exist_ok=True)

with open(INPUT, "r", encoding="utf-8") as f:
    items = json.load(f)

CUSTO = "Custo (R$)"
VENDA = "Venda (R$)"

for item in items:
    item["capital_travado"] = round(item[CUSTO] * item["Estoque"], 2)

total_capital = sum(i["capital_travado"] for i in items)

capital_morto = [i for i in items if i["Giro (30d)"] == 0.0]
total_capital_morto = sum(i["capital_travado"] for i in capital_morto)

prejuizos = []
for i in items:
    if i[VENDA] < i[CUSTO]:
        p = dict(i)
        p["prejuizo_unit"] = round(i[CUSTO] - i[VENDA], 2)
        prejuizos.append(p)

rupturas = [i for i in items if i["Estoque"] == 0.0]

vencimentos_criticos = []
for i in items:
    venc = i.get("Vencimento", "")
    if not venc:
        continue
    y, m, d = map(int, venc.split("-"))
    diff = (date(y, m, d) - TODAY).days
    if diff <= 3:
        p = dict(i)
        p["dias_para_vencer"] = diff
        vencimentos_criticos.append(p)

sorted_items = sorted(items, key=lambda x: x["capital_travado"], reverse=True)
for idx, item in enumerate(sorted_items):
    pct = (idx + 1) / len(sorted_items)
    item["prioridade"] = "A" if pct <= 0.2 else ("B" if pct <= 0.5 else "C")

recomendacoes = []
for item in vencimentos_criticos:
    dias = item["dias_para_vencer"]
    urgencia = "CRITICO" if dias <= 0 else "ALTO"
    acao = "REMOVER DO ESTOQUE — produto vencido" if dias <= 0 else f"PROMOVER VENDA IMEDIATA — vence em {dias}d"
    recomendacoes.append({"sku": item["SKU_ID"], "produto": item["Produto"], "acao": acao, "urgencia": urgencia})
for item in capital_morto:
    if item["capital_travado"] > 0:
        recomendacoes.append({
            "sku": item["SKU_ID"],
            "produto": item["Produto"],
            "acao": f"QUEIMA DE ESTOQUE — giro zero, capital preso de R$ {item['capital_travado']}",
            "urgencia": "ALTO"
        })
for item in rupturas:
    if item["Giro (30d)"] > 50:
        recomendacoes.append({
            "sku": item["SKU_ID"],
            "produto": item["Produto"],
            "acao": "REABASTECIMENTO URGENTE — Ruptura de Gondola com giro alto",
            "urgencia": "CRITICO"
        })
for item in prejuizos:
    recomendacoes.append({
        "sku": item["SKU_ID"],
        "produto": item["Produto"],
        "acao": f"RENEGOCIAR PRECIFICACAO — venda abaixo do custo (R$ {item['prejuizo_unit']}/un de prejuizo)",
        "urgencia": "MEDIO"
    })

audit = {
    "run_id": RUN_ID,
    "data_auditoria": str(TODAY),
    "kpis": {
        "total_skus": len(items),
        "capital_total_em_estoque_R$": round(total_capital, 2),
        "capital_morto_R$": round(total_capital_morto, 2),
        "pct_capital_morto": round(total_capital_morto / total_capital * 100, 1) if total_capital else 0,
        "skus_prejuizo": len(prejuizos),
        "skus_ruptura": len(rupturas),
        "skus_vencimento_critico": len(vencimentos_criticos),
    },
    "itens_prioridade_a": [i for i in sorted_items if i.get("prioridade") == "A"],
    "vencimentos_criticos": vencimentos_criticos,
    "capital_morto": capital_morto,
    "rupturas": rupturas,
    "prejuizos": prejuizos,
    "recomendacoes": recomendacoes,
    "todos_os_itens": sorted_items,
}

with open(OUTPUT, "w", encoding="utf-8") as f:
    json.dump(audit, f, ensure_ascii=False, indent=2)
print(f"Auditoria salva em: {OUTPUT}")
print()
print("=== KPIs ===")
for k, v in audit["kpis"].items():
    print(f"  {k}: {v}")
print()
print(f"=== VENCIMENTOS CRITICOS ({len(vencimentos_criticos)}) ===")
for v in vencimentos_criticos:
    print(f"  {v['SKU_ID']} {v['Produto']} — {v['dias_para_vencer']}d")
print()
print("=== CAPITAL MORTO TOP 3 ===")
for c in sorted(capital_morto, key=lambda x: x["capital_travado"], reverse=True)[:3]:
    print(f"  {c['SKU_ID']} {c['Produto']} — R$ {c['capital_travado']}")
print()
print("=== RUPTURAS CRITICAS ===")
for r in sorted(rupturas, key=lambda x: x["Giro (30d)"], reverse=True):
    print(f"  {r['SKU_ID']} {r['Produto']} — Giro {r['Giro (30d)']}/30d — Vence {r['Vencimento']}")
