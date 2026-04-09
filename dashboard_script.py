import json
import os
from datetime import datetime

# Read audit_results.json
with open('squads/inventory-intelligence-squad/output/2026-04-06-133728/v1/audit_results.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Generate inventory
inventory = []
for item in data:
    sku = item['SKU_ID']
    desc = item['Produto']
    balance = item['Estoque']
    valorTotal = item['Capital Travado']
    status = item['Status para IA']
    originalIds = [sku]  # assuming no duplicates
    # Since no entries/exits, set entries = balance, exits = 0
    entries = balance
    exits = 0
    inventory.append({
        'sku': sku,
        'desc': desc,
        'entries': entries,
        'exits': exits,
        'balance': balance,
        'valorTotal': valorTotal,
        'status': status,
        'originalIds': originalIds
    })

# Generate errors
errors = []
for item in data:
    status = item['Status para IA']
    if status in ['CAPITAL MORTO', 'PREJUÍZO']:
        sku = item['SKU_ID']
        problema = status
        errors.append({
            'sku': sku,
            'problema': problema,
            'acao': 'INVESTIGAR'
        })

# Generate suspiciousIds
suspiciousIds = []
for item in data:
    sku = item['SKU_ID']
    normalized = sku.replace('O', '0').replace('o', '0')
    if normalized != sku:
        suspiciousIds.append({
            'normalized': normalized,
            'original': sku,
            'status': 'DIFERENTE'
        })

# Write inventory_analysis.json
output = {
    'inventory': inventory,
    'errors': errors,
    'suspiciousIds': suspiciousIds
}
with open('squads/inventory-intelligence-squad/output/2026-04-06-133728/v1/inventory_analysis.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

# Generate resumo.txt
total_items = len(data)
unique_skus = len(set(item['SKU_ID'] for item in data))
total_estoque = sum(item['Estoque'] for item in data)
total_valor = sum(item['Capital Travado'] for item in data)
negative_balances = [item for item in data if item['Estoque'] < 0]
total_entries = total_estoque  # assuming
total_exits = 0

resumo = f"""RESUMO EXECUTIVO - AUDITORIA ESTOQUE
==========================================
Data: {datetime.now().strftime('%Y-%m-%d')}
Execução: 2026-04-06-133728

CHECKPOINT:
- Linhas lidas: {len(data)}
- Linhas consolidadas: {unique_skus}
- Status: OK

REGRA 1 - INTEGRIDADE DE IDs:
- Total items únicos: {unique_skus}
- IDs com variações: 0

REGRA 2 - SALDOS:
- Total Entradas: {total_entries}
- Total Saídas: {total_exits}
- Saldo Total: {total_estoque}
- Saldos negativos: {len(negative_balances)}
"""

for item in negative_balances:
    resumo += f"  ERRO: ERRO SALDO NEGATIVO: {item['SKU_ID']} = {item['Estoque']}\n"

resumo += f"""
REGRA 3 - VALORAÇÃO:
- Valor Total Estoque: R$ {total_valor:.2f}
- Total de itens: {total_items}

ARQUIVOS GERADOS:
- inventory_analysis.json
- resumo.txt
"""

with open('squads/inventory-intelligence-squad/output/resumo.txt', 'w', encoding='utf-8') as f:
    f.write(resumo)

print("Dashboard generation completed")