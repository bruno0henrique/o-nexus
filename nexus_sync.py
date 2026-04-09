import pandas as pd
from supabase import create_client, Client
from dotenv import load_dotenv
import os

# Carregar variáveis de ambiente
load_dotenv()

# Credenciais do Supabase
url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_ANON_KEY")
service_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

# Usar service role se disponível para operações de escrita
if service_key:
    supabase: Client = create_client(url, service_key)
else:
    supabase: Client = create_client(url, key)

# Ler o CSV
csv_file = "squads/inventory-intelligence-squad/input/base_teste.csv"
df = pd.read_csv(csv_file)

# Mapear colunas para o padrão da tabela
column_mapping = {
    'SKU_ID': 'sku_id',
    'Produto': 'produto',
    'Categoria': 'categoria',
    'Custo (R$)': 'preco_custo',
    'Venda (R$)': 'preco_venda',
    'Estoque': 'estoque_atual',
    'Giro (30d)': 'giro_30d',
    'Vencimento': 'data_vencimento'
}

# Renomear colunas
df = df.rename(columns=column_mapping)

# Selecionar apenas as colunas necessárias
df = df[list(column_mapping.values())]

# Converter para lista de dicionários
data = df.to_dict('records')

# Inserir identificação da loja (loja_id) a partir da variável de ambiente ou checkpoint
loja_id = os.getenv('LOJA_ID')
if not loja_id:
    checkpoint_path = 'squads/inventory-intelligence-squad/output/checkpoint_input.md'
    try:
        with open(checkpoint_path, 'r', encoding='utf-8') as cf:
            for line in cf:
                if line.strip().startswith('loja_id:'):
                    loja_id = line.split(':', 1)[1].strip()
                    break
    except FileNotFoundError:
        pass

if not loja_id:
    print('LOJA_ID não encontrado. Defina $LOJA_ID ou preencha squads/.../checkpoint_input.md com `loja_id: <id>`')
    raise SystemExit(2)

# Adiciona campo `loja_id` em cada registro para persistência correta na tabela
for rec in data:
    rec['loja_id'] = loja_id

# Tentar inserir no Supabase
try:
    response = supabase.table('tabela_nexus').insert(data).execute()
    print("Upload realizado com sucesso!")
    print(f"Registros inseridos: {len(data)}")
except Exception as e:
    print(f"Erro durante o upload: {str(e)}")