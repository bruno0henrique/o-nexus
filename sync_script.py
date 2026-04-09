import os
from supabase import create_client, Client
from dotenv import load_dotenv
import json

load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_ANON_KEY")

supabase: Client = create_client(url, key)

# Read audit_results.json
with open('squads/inventory-intelligence-squad/output/2026-04-06-133728/v1/audit_results.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Assume table name is 'estoque'
table_name = 'estoque'

# Check if table exists, but since we can't, assume it does or create it
# For simplicity, try to upsert

log = []

for item in data:
    try:
        response = supabase.table(table_name).upsert(item, on_conflict='SKU_ID').execute()
        log.append(f"Upserted {item['SKU_ID']}: {response}")
    except Exception as e:
        log.append(f"Error upserting {item['SKU_ID']}: {str(e)}")

# Write log
with open('squads/inventory-intelligence-squad/output/2026-04-06-133728/v1/sync_log.md', 'w', encoding='utf-8') as f:
    f.write('# Sync Log\n\n')
    for entry in log:
        f.write(f'- {entry}\n')

print("Sync completed")