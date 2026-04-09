import json
import os

def consolidate():
    base_path = r'c:\Programas\O-Nexus\nexus_engine\squads\inventory-intelligence-squad\output\2026-04-06-133728\v1'
    audit_file = os.path.join(base_path, 'audit_results.json')
    
    with open(audit_file, 'r', encoding='utf-8') as f:
        audit = json.load(f)
        
    inventory = []
    errors = []
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
            errors.append({
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
            
    data = {
        'inventory': inventory,
        'errors': errors,
        'suspiciousIds': suspicious
    }
    
    # Save JSON and update data.js
    output_json = os.path.join(base_path, 'inventory_analysis.json')
    with open(output_json, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
        
    # Also update data.js in teste_nexus_1
    dest_path = r'c:\Programas\O-Nexus\nexus_engine\squads\inventory-intelligence-squad\output\teste_nexus_1'
    data_js = os.path.join(dest_path, 'data.js')
    with open(data_js, 'w', encoding='utf-8') as f:
        f.write('const inventoryData = ' + json.dumps(data, ensure_ascii=False) + ';')
        
    # Save resumo.txt
    resumo_path = r'c:\Programas\O-Nexus\nexus_engine\squads\inventory-intelligence-squad\output\resumo.txt'
    total_val = sum(i['valorTotal'] for i in inventory)
    with open(resumo_path, 'w', encoding='utf-8') as f:
        f.write(f"RESUMO EXECUTIVO - AUDITORIA ESTOQUE\n")
        f.write(f"==========================================\n")
        f.write(f"Data: 2026-04-06\n")
        f.write(f"- Linhas lidas: {len(audit)}\n")
        f.write(f"- Itens com erro: {len(errors)}\n")
        f.write(f"- Valor Total: R$ {total_val:,.2f}\n")

if __name__ == '__main__':
    consolidate()
