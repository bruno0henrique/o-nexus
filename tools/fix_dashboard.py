"""
Regenera scripts.js limpo para o dashboard do inventory-intelligence-squad.
Lê o sanitized_data.json do run indicado e gera JS válido.
"""
import json, pathlib, sys, textwrap

RUN_ID   = sys.argv[1] if len(sys.argv) > 1 else '2026-04-08-110609'
SQUAD    = pathlib.Path('squads/inventory-intelligence-squad')
SAN_PATH = SQUAD / f'output/{RUN_ID}/v1/sanitized_data.json'
DEST_JS  = SQUAD / f'output/{RUN_ID}/scripts.js'

# ── carrega dados ──────────────────────────────────────────────────────────────
data = json.loads(SAN_PATH.read_text(encoding='utf-8'))

STATUS_MAP = {
    'OK':           ('badge-success', '#22c55e'),
    'CAPITAL MORTO':('badge-error',   '#ef4444'),
    'PREJUÍZO':     ('badge-error',   '#f97316'),
    'VENCIMENTO':   ('badge-warning', '#f59e0b'),
    'RUPTURA':      ('badge-info',    '#3b82f6'),
}

# ── monta inventory ────────────────────────────────────────────────────────────
inventory = []
errors    = []

for row in data:
    sku      = row['SKU_ID']
    produto  = row['Produto']
    cat      = row['Categoria']
    estoque  = int(row['Estoque'])
    giro     = int(row['Giro (30d)'])
    custo    = float(row['Custo (R$)'])
    venda    = float(row['Venda (R$)'])
    capital  = round(estoque * custo, 2)
    venc     = row['Vencimento']
    status   = row['Status para IA']

    inventory.append({
        'sku': sku, 'produto': produto, 'categoria': cat,
        'estoque': estoque, 'giro30d': giro,
        'custo': custo, 'venda': venda,
        'capital': capital, 'vencimento': venc, 'status': status,
    })

    if status == 'CAPITAL MORTO':
        errors.append({'sku': sku, 'problema': f'CAPITAL MORTO – {produto} ({estoque} un, Giro={giro}/mês)', 'acao': 'INVESTIGAR'})
    elif status == 'PREJUÍZO':
        errors.append({'sku': sku, 'problema': f'PREJUÍZO – {produto} (Custo R${custo} > Venda R${venda})', 'acao': 'INVESTIGAR'})
    elif status == 'VENCIMENTO':
        errors.append({'sku': sku, 'problema': f'VENCIMENTO – {produto} (Vence {venc})', 'acao': 'RETIRAR'})
    elif status == 'RUPTURA':
        errors.append({'sku': sku, 'problema': f'RUPTURA – {produto} (Estoque=0, Giro={giro}/mês)', 'acao': 'REABASTECER'})

# ── gera JS ────────────────────────────────────────────────────────────────────
inv_js  = json.dumps(inventory, ensure_ascii=False, indent=2)
err_js  = json.dumps(errors, ensure_ascii=False, indent=2)

def _color(status):
    return STATUS_MAP.get(status, ('', '#9ca3af'))[1]

bar_colors_js = '[' + ', '.join(f"'{_color(i['status'])}'" for i in inventory) + ']'

js = f"""\
'use strict';

// ─── DADOS ───────────────────────────────────────────────────────────────────
const inventory = {inv_js};

const errors = {err_js};

const suspiciousIds = [];

// ─── STATUS BADGE ────────────────────────────────────────────────────────────
function statusBadgeClass(status) {{
  const map = {{
    'OK':           'badge-success',
    'CAPITAL MORTO':'badge-error',
    'PREJUÍZO':     'badge-error',
    'VENCIMENTO':   'badge-warning',
    'RUPTURA':      'badge-info',
  }};
  return map[status] || 'badge-info';
}}

// ─── RENDER TABLE ────────────────────────────────────────────────────────────
function renderTable(filter = 'all') {{
  const tbody = document.getElementById('inventoryTable');
  tbody.innerHTML = '';
  inventory.forEach(item => {{
    let show = true;
    if (filter === 'OK'   && item.status !== 'OK') show = false;
    if (filter === 'ERRO' && item.status === 'OK') show = false;
    if (!show) return;
    const tr = document.createElement('tr');
    tr.className = 'border-b border-gray-800 hover:bg-gray-800/50';
    tr.innerHTML = `
      <td class="py-3 px-4 font-mono text-blue-400">${{item.sku}}</td>
      <td class="py-3 px-4">${{item.produto}}</td>
      <td class="py-3 px-4 text-xs text-gray-500">${{item.categoria}}</td>
      <td class="py-3 px-4 font-medium">${{item.estoque.toLocaleString('pt-BR')}}</td>
      <td class="py-3 px-4 text-yellow-400">${{item.giro30d}}</td>
      <td class="py-3 px-4">R$ ${{item.capital.toLocaleString('pt-BR',{{minimumFractionDigits:2}})}}</td>
      <td class="py-3 px-4"><span class="badge ${{statusBadgeClass(item.status)}}">${{item.status}}</span></td>
    `;
    tbody.appendChild(tr);
  }});
}}

// ─── RENDER ERRORS ───────────────────────────────────────────────────────────
function renderErrors() {{
  const tbody = document.getElementById('errorTable');
  tbody.innerHTML = '';
  errors.forEach(err => {{
    const bc = err.acao === 'RETIRAR' ? 'badge-warning'
             : err.acao === 'REABASTECER' ? 'badge-info' : 'badge-error';
    const tr = document.createElement('tr');
    tr.className = 'border-b border-gray-800 hover:bg-gray-800/50';
    tr.innerHTML = `
      <td class="py-3 px-4 font-mono text-red-400">${{err.sku}}</td>
      <td class="py-3 px-4">${{err.problema}}</td>
      <td class="py-3 px-4"><span class="badge ${{bc}}">${{err.acao}}</span></td>
    `;
    tbody.appendChild(tr);
  }});
}}

// ─── RENDER SUSPICIOUS ───────────────────────────────────────────────────────
function renderSuspicious() {{
  const tbody = document.getElementById('suspiciousTable');
  tbody.innerHTML = '';
  suspiciousIds.forEach(item => {{
    const tr = document.createElement('tr');
    tr.className = 'border-b border-gray-800 hover:bg-gray-800/50';
    tr.innerHTML = `
      <td class="py-3 px-4 font-mono text-blue-400">${{item.normalized}}</td>
      <td class="py-3 px-4 text-xs text-gray-400">${{item.original}}</td>
      <td class="py-3 px-4"><span class="badge badge-warning">${{item.status}}</span></td>
    `;
    tbody.appendChild(tr);
  }});
}}

// ─── FILTER BUTTONS ──────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {{
  document.querySelectorAll('.filter-btn').forEach(btn => {{
    btn.addEventListener('click', () => {{
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      renderTable(btn.dataset.filter);
    }});
  }});
}});

// ─── KPIs ────────────────────────────────────────────────────────────────────
function updateKPIs() {{
  const totalEstoque = inventory.reduce((s,i) => s + i.estoque, 0);
  const totalGiro    = inventory.reduce((s,i) => s + i.giro30d, 0);
  const totalOK      = inventory.filter(i => i.status === 'OK').length;
  const totalCapital = inventory.reduce((s,i) => s + i.capital, 0);

  document.querySelector('[data-kpi="entries"] .kpi-value').textContent =
    totalEstoque.toLocaleString('pt-BR');
  document.querySelector('[data-kpi="exits"] .kpi-value').textContent =
    totalGiro.toLocaleString('pt-BR');
  document.querySelector('[data-kpi="balance"] .kpi-value').textContent =
    totalOK + ' itens';
  const capEl = document.querySelector('[data-kpi="capital"] .kpi-value');
  capEl.textContent = totalCapital >= 1e6
    ? 'R$ ' + (totalCapital/1e6).toFixed(2) + 'M'
    : 'R$ ' + (totalCapital/1000).toFixed(1) + 'K';
}}

// ─── TOGGLE CHART ────────────────────────────────────────────────────────────
function toggleChart(card) {{
  card.classList.toggle('active');
  card.querySelector('.chart-container').classList.toggle('expanded');
  const chartId = card.dataset.chart;
  setTimeout(() => Chart.getChart(chartId)?.resize(), 310);
}}

// ─── CHARTS ──────────────────────────────────────────────────────────────────
function initCharts() {{
  const labels   = inventory.map(i => i.sku);
  const estoques = inventory.map(i => i.estoque);
  const capitals = inventory.map(i => i.capital);
  const barColors = {bar_colors_js};

  const baseOpts = {{
    responsive: true,
    maintainAspectRatio: false,
    plugins: {{ legend: {{ display: false }} }},
    scales: {{
      x: {{ ticks: {{ color:'#9ca3af', font:{{size:9}}, maxRotation:60 }}, grid:{{ display:false }} }},
      y: {{ ticks: {{ color:'#9ca3af' }}, grid:{{ color:'#374151' }} }},
    }},
  }};

  new Chart(document.getElementById('balanceChart'), {{
    type: 'bar',
    data: {{ labels, datasets: [{{ label:'Estoque', data:estoques, backgroundColor:barColors, borderRadius:6 }}] }},
    options: {{
      ...baseOpts,
      plugins: {{ ...baseOpts.plugins,
        tooltip: {{ callbacks: {{ label: ctx => 'Estoque: ' + ctx.parsed.y.toLocaleString('pt-BR') + ' un' }} }} }},
    }},
  }});

  new Chart(document.getElementById('flowChart'), {{
    type: 'bar',
    data: {{ labels, datasets: [{{ label:'Capital (R$)', data:capitals, backgroundColor:barColors, borderRadius:6 }}] }},
    options: {{
      ...baseOpts,
      plugins: {{ ...baseOpts.plugins,
        tooltip: {{ callbacks: {{ label: ctx => 'Capital: R$ ' + ctx.parsed.y.toLocaleString('pt-BR',{{minimumFractionDigits:2}}) }} }} }},
    }},
  }});
}}

// ─── INIT ────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {{
  renderTable();
  renderErrors();
  renderSuspicious();
  updateKPIs();
  initCharts();
  // Expande os charts automaticamente
  document.querySelectorAll('.chart-card').forEach(card => {{
    card.classList.add('active');
    card.querySelector('.chart-container').classList.add('expanded');
  }});
  setTimeout(() => {{
    Chart.getChart('balanceChart')?.resize();
    Chart.getChart('flowChart')?.resize();
  }}, 150);
}});
"""

DEST_JS.write_text(js, encoding='utf-8')
print(f'scripts.js gerado: {DEST_JS}')
print(f'  {len(inventory)} itens | {len(errors)} erros')
