import json
import os
import shutil

# Folder name
folder_name = '2026-04-06-133728'
dashboard_dir = f'squads/inventory-intelligence-squad/output/{folder_name}'

# Create directory if not exists
os.makedirs(dashboard_dir, exist_ok=True)

# Copy files from /resumo/
shutil.copy('resumo/index.html', dashboard_dir)
shutil.copy('resumo/styles.css', dashboard_dir)
shutil.copy('resumo/scripts.js', dashboard_dir)

# Copy inventory_analysis.json
shutil.copy(f'squads/inventory-intelligence-squad/output/{folder_name}/v1/inventory_analysis.json', dashboard_dir)

# Read inventory_analysis.json
with open(f'{dashboard_dir}/inventory_analysis.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

inventory = data['inventory']
errors = data['errors']
suspiciousIds = data['suspiciousIds']

# Modify scripts.js
with open(f'{dashboard_dir}/scripts.js', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the hardcoded data
content = content.replace('const inventory = [', f'const inventory = {json.dumps(inventory, ensure_ascii=False, indent=4)};\n\n// Original hardcoded removed')
content = content.replace('const errors = [', f'const errors = {json.dumps(errors, ensure_ascii=False, indent=4)};\n\n// Original hardcoded removed')
content = content.replace('const suspiciousIds = [', f'const suspiciousIds = {json.dumps(suspiciousIds, ensure_ascii=False, indent=4)};\n\n// Original hardcoded removed')

# But since the original has the arrays, I need to replace the entire blocks.

# Find the positions
start_inventory = content.find('const inventory = [')
end_inventory = content.find('];', start_inventory) + 2

start_errors = content.find('const errors = [')
end_errors = content.find('];', start_errors) + 2

start_suspicious = content.find('const suspiciousIds = [')
end_suspicious = content.find('];', start_suspicious) + 2

content = content[:start_inventory] + f'const inventory = {json.dumps(inventory, ensure_ascii=False, indent=4)};\n\n' + content[end_inventory:]
content = content[:start_errors] + f'const errors = {json.dumps(errors, ensure_ascii=False, indent=4)};\n\n' + content[end_errors:]
content = content[:start_suspicious] + f'const suspiciousIds = {json.dumps(suspiciousIds, ensure_ascii=False, indent=4)};\n\n' + content[end_suspicious:]

# Write back
with open(f'{dashboard_dir}/scripts.js', 'w', encoding='utf-8') as f:
    f.write(content)

print("Visual dashboard generated")