#!/usr/bin/env python3
import os
import json
from supabase import create_client
from dotenv import load_dotenv

load_dotenv()
SUPABASE_URL = os.getenv('SUPABASE_URL')
SERVICE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY') or os.getenv('SUPABASE_ANON_KEY')

if not SUPABASE_URL or not SERVICE_KEY:
    print('Credenciais Supabase ausentes. Verifique .env')
    raise SystemExit(2)

supabase = create_client(SUPABASE_URL, SERVICE_KEY)

SQUAD = 'squads/inventory-intelligence-squad'
# Allow overriding RUN_ID from environment for new runs
RUN_ID = os.getenv('RUN_ID') or '2026-04-08-040742'
AUDIT_PATH = f'{SQUAD}/output/{RUN_ID}/audit_results.json'
if not os.path.exists(AUDIT_PATH):
    # fallback to v1/ where runner may have placed artifacts
    alt = f'{SQUAD}/output/{RUN_ID}/v1/audit_results.json'
    if os.path.exists(alt):
        AUDIT_PATH = alt
# checkpoint remains at squad output root for interactive input
CHECKPOINT = f'{SQUAD}/output/checkpoint_input.md'
LOG_PATH = f'{SQUAD}/output/{RUN_ID}/sync_log.md'

# Read checkpoint (expecting key 'loja_id' from user input) and map to DB column 'loja_id'
loja_id = None
# First try to read from environment (interactive runs can set this)
loja_id = os.getenv('LOJA_ID')
if not loja_id:
    try:
        with open(CHECKPOINT, 'r', encoding='utf-8') as f:
            for line in f:
                if line.strip().startswith('loja_id:'):
                    loja_id = line.split(':',1)[1].strip()
                    break
    except FileNotFoundError:
        pass
if not loja_id:
    print('loja_id não encontrado em checkpoint_input.md nem em $LOJA_ID')
    raise SystemExit(3)

with open(AUDIT_PATH, 'r', encoding='utf-8') as f:
    audit = json.load(f)

# Prepare records for upsert: use only the table's expected columns + loja_id
records = []
for item in audit.get('todos_os_itens', []):
    # Normalize types to match DB expectations
    estoque = item.get('Estoque')
    giro = item.get('Giro (30d)')
    try:
        # convert floats like 510.0 to int where appropriate
        if isinstance(estoque, float) and estoque.is_integer():
            estoque_val = int(estoque)
        else:
            estoque_val = int(round(float(estoque))) if estoque not in (None, '') else None
    except Exception:
        estoque_val = None
    try:
        if isinstance(giro, float) and giro.is_integer():
            giro_val = int(giro)
        else:
            giro_val = int(round(float(giro))) if giro not in (None, '') else None
    except Exception:
        giro_val = None

    try:
        preco_custo_val = float(item.get('Custo (R$)')) if item.get('Custo (R$)') not in (None, '') else None
    except Exception:
        preco_custo_val = None
    try:
        preco_venda_val = float(item.get('Venda (R$)')) if item.get('Venda (R$)') not in (None, '') else None
    except Exception:
        preco_venda_val = None

    rec = {
        'loja_id': loja_id,
        'sku_id': item.get('SKU_ID'),
        'produto': item.get('Produto'),
        'categoria': item.get('Categoria'),
        'preco_custo': preco_custo_val,
        'preco_venda': preco_venda_val,
        'estoque_atual': estoque_val,
        'giro_30d': giro_val,
        'data_vencimento': item.get('Vencimento')
    }
    records.append(rec)

print(f'Preparando {len(records)} registros para upsert (loja_id={loja_id})')

# Upsert usando sku_id + loja_id como chave composta
# Supabase Python client doesn't support composite upsert directly; we'll perform upsert per record with on_conflict
errors = []
for r in records:
    try:
        # Use loja_id as the DB column for store identifier when upserting
        res = supabase.table('tabela_nexus').upsert(r, on_conflict=['sku_id','loja_id']).execute()
        # res has status_code and maybe error
        if hasattr(res, 'status_code') and res.status_code >= 400:
            errors.append({'record': r, 'error': str(res)})
    except Exception as e:
        errors.append({'record': r, 'error': str(e)})

# Write log
os.makedirs(os.path.dirname(LOG_PATH), exist_ok=True)
with open(LOG_PATH, 'w', encoding='utf-8') as lf:
    lf.write(f'Run ID: {RUN_ID}\n')
    lf.write(f'Loja ID: {loja_id}\n')
    lf.write(f'Records processed: {len(records)}\n')
    lf.write(f'Errors: {len(errors)}\n')
    if errors:
        for e in errors[:20]:
            lf.write(json.dumps(e, ensure_ascii=False) + '\n')

print(f'Sync log escrito em {LOG_PATH}')
print(f'Erros: {len(errors)}')
if errors:
    raise SystemExit(4)
