import json
import os

def consolidate_separate():
    base_path = r'c:\Programas\O-Nexus\nexus_engine\squads\inventory-intelligence-squad\output\2026-04-06-133728\v1'
    audit_file = os.path.join(base_path, 'audit_results.json')
    
    with open(audit_file, 'r', encoding='utf-8') as f:
        audit = json.load(f)
        
    inventory = []
    errors_list = []
    suspicious = []
    
    for item in audit:
        sku = item['SKU_ID']
        status_ia = item['Status para IA']
        d_status = 'OK' if status_ia == 'OK' else 'ERRO'
        
        inventory.append({
            'sku': sku,
            'desc': item['Produto'],
            'entries': int(item['Estoque']),
            'exits': 0,
            'balance': int(item['Estoque']),
            'valorTotal': float(item['Capital Travado']),
            'status': d_status,
            'originalIds': sku
        })
        
        if d_status == 'ERRO':
            errors_list.append({
                'sku': sku,
                'problema': status_ia,
                'acao': 'INVESTIGAR'
            })
            
        if 'O' in sku:
            suspicious.append({
                'normalized': sku.replace('O', '0'),
                'original': sku,
                'status': 'DIFERENTE'
            })
            
    # Also update data.js in teste_nexus_1
    dest_path = r'c:\Programas\O-Nexus\nexus_engine\squads\inventory-intelligence-squad\output\teste_nexus_1'
    data_js = os.path.join(dest_path, 'data.js')
    
    with open(data_js, 'w', encoding='utf-8') as f:
        f.write(f"const inventory = {json.dumps(inventory, ensure_ascii=False, indent=4)};\n\n")
        f.write(f"const errors = {json.dumps(errors_list, ensure_ascii=False, indent=4)};\n\n")
        f.write(f"const suspiciousIds = {json.dumps(suspicious, ensure_ascii=False, indent=4)};\n")

if __name__ == '__main__':
    consolidate_separate()
