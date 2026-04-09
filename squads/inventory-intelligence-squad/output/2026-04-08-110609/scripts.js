'use strict';

// ─── DADOS ───────────────────────────────────────────────────────────────────
const inventory = [
  {
    "sku": "NEX-2001",
    "produto": "Vinho Tinto",
    "categoria": "Bebidas",
    "estoque": 45,
    "giro30d": 22,
    "custo": 25.0,
    "venda": 45.0,
    "capital": 1125.0,
    "vencimento": "2026-11-15",
    "status": "OK"
  },
  {
    "sku": "NEX-2002",
    "produto": "Iogurte Morango",
    "categoria": "Laticínios",
    "estoque": 12,
    "giro30d": 85,
    "custo": 3.2,
    "venda": 6.9,
    "capital": 38.4,
    "vencimento": "2026-04-08",
    "status": "VENCIMENTO"
  },
  {
    "sku": "NEX-2003",
    "produto": "Arroz 5kg",
    "categoria": "Mercearia",
    "estoque": 88,
    "giro30d": 75,
    "custo": 15.0,
    "venda": 26.0,
    "capital": 1320.0,
    "vencimento": "2027-02-10",
    "status": "OK"
  },
  {
    "sku": "NEX-2004",
    "produto": "Tomate Kg",
    "categoria": "Hortifruti",
    "estoque": 15,
    "giro30d": 45,
    "custo": 4.0,
    "venda": 7.5,
    "capital": 60.0,
    "vencimento": "2026-04-07",
    "status": "VENCIMENTO"
  },
  {
    "sku": "NEX-2005",
    "produto": "Cerveja Lata",
    "categoria": "Bebidas",
    "estoque": 550,
    "giro30d": 0,
    "custo": 2.5,
    "venda": 4.8,
    "capital": 1375.0,
    "vencimento": "2026-09-30",
    "status": "CAPITAL MORTO"
  },
  {
    "sku": "NEX-2006",
    "produto": "Queijo Prato",
    "categoria": "Laticínios",
    "estoque": 25,
    "giro30d": 18,
    "custo": 18.0,
    "venda": 32.0,
    "capital": 450.0,
    "vencimento": "2026-05-20",
    "status": "OK"
  },
  {
    "sku": "NEX-2007",
    "produto": "Feijão Carioca",
    "categoria": "Mercearia",
    "estoque": 40,
    "giro30d": 35,
    "custo": 6.0,
    "venda": 4.0,
    "capital": 240.0,
    "vencimento": "2026-12-15",
    "status": "PREJUÍZO"
  },
  {
    "sku": "NEX-2008",
    "produto": "Banana Prata",
    "categoria": "Hortifruti",
    "estoque": 0,
    "giro30d": 180,
    "custo": 3.5,
    "venda": 6.0,
    "capital": 0.0,
    "vencimento": "2026-04-09",
    "status": "RUPTURA"
  },
  {
    "sku": "NEX-2009",
    "produto": "Leite Integral",
    "categoria": "Laticínios",
    "estoque": 100,
    "giro30d": 95,
    "custo": 3.5,
    "venda": 5.2,
    "capital": 350.0,
    "vencimento": "2026-08-14",
    "status": "OK"
  },
  {
    "sku": "NEX-2010",
    "produto": "Azeite Oliva",
    "categoria": "Mercearia",
    "estoque": 15,
    "giro30d": 8,
    "custo": 28.0,
    "venda": 25.0,
    "capital": 420.0,
    "vencimento": "2027-01-20",
    "status": "PREJUÍZO"
  },
  {
    "sku": "NEX-2011",
    "produto": "Maçã Fuji",
    "categoria": "Hortifruti",
    "estoque": 22,
    "giro30d": 30,
    "custo": 6.0,
    "venda": 11.0,
    "capital": 132.0,
    "vencimento": "2026-04-08",
    "status": "VENCIMENTO"
  },
  {
    "sku": "NEX-2012",
    "produto": "Vinho Tinto",
    "categoria": "Bebidas",
    "estoque": 0,
    "giro30d": 45,
    "custo": 25.0,
    "venda": 45.0,
    "capital": 0.0,
    "vencimento": "2027-03-10",
    "status": "RUPTURA"
  },
  {
    "sku": "NEX-2013",
    "produto": "Iogurte Morango",
    "categoria": "Laticínios",
    "estoque": 55,
    "giro30d": 40,
    "custo": 3.2,
    "venda": 6.9,
    "capital": 176.0,
    "vencimento": "2026-04-25",
    "status": "OK"
  },
  {
    "sku": "NEX-2014",
    "produto": "Arroz 5kg",
    "categoria": "Mercearia",
    "estoque": 12,
    "giro30d": 110,
    "custo": 15.0,
    "venda": 26.0,
    "capital": 180.0,
    "vencimento": "2026-10-05",
    "status": "OK"
  },
  {
    "sku": "NEX-2015",
    "produto": "Tomate Kg",
    "categoria": "Hortifruti",
    "estoque": 480,
    "giro30d": 0,
    "custo": 4.0,
    "venda": 7.5,
    "capital": 1920.0,
    "vencimento": "2026-04-10",
    "status": "CAPITAL MORTO"
  },
  {
    "sku": "NEX-2016",
    "produto": "Cerveja Lata",
    "categoria": "Bebidas",
    "estoque": 200,
    "giro30d": 180,
    "custo": 2.5,
    "venda": 4.8,
    "capital": 500.0,
    "vencimento": "2026-07-15",
    "status": "OK"
  },
  {
    "sku": "NEX-2017",
    "produto": "Queijo Prato",
    "categoria": "Laticínios",
    "estoque": 30,
    "giro30d": 22,
    "custo": 18.0,
    "venda": 16.0,
    "capital": 540.0,
    "vencimento": "2026-06-01",
    "status": "PREJUÍZO"
  },
  {
    "sku": "NEX-2018",
    "produto": "Feijão Carioca",
    "categoria": "Mercearia",
    "estoque": 15,
    "giro30d": 12,
    "custo": 6.0,
    "venda": 10.5,
    "capital": 90.0,
    "vencimento": "2026-04-09",
    "status": "VENCIMENTO"
  },
  {
    "sku": "NEX-2019",
    "produto": "Banana Prata",
    "categoria": "Hortifruti",
    "estoque": 45,
    "giro30d": 50,
    "custo": 3.5,
    "venda": 6.0,
    "capital": 157.5,
    "vencimento": "2026-04-15",
    "status": "OK"
  },
  {
    "sku": "NEX-2020",
    "produto": "Leite Integral",
    "categoria": "Laticínios",
    "estoque": 600,
    "giro30d": 0,
    "custo": 3.5,
    "venda": 5.2,
    "capital": 2100.0,
    "vencimento": "2026-05-30",
    "status": "CAPITAL MORTO"
  },
  {
    "sku": "NEX-2021",
    "produto": "Azeite Oliva",
    "categoria": "Mercearia",
    "estoque": 5,
    "giro30d": 12,
    "custo": 28.0,
    "venda": 52.0,
    "capital": 140.0,
    "vencimento": "2027-02-14",
    "status": "OK"
  },
  {
    "sku": "NEX-2022",
    "produto": "Maçã Fuji",
    "categoria": "Hortifruti",
    "estoque": 0,
    "giro30d": 95,
    "custo": 6.0,
    "venda": 11.0,
    "capital": 0.0,
    "vencimento": "2026-04-11",
    "status": "RUPTURA"
  },
  {
    "sku": "NEX-2023",
    "produto": "Vinho Tinto",
    "categoria": "Bebidas",
    "estoque": 30,
    "giro30d": 28,
    "custo": 25.0,
    "venda": 45.0,
    "capital": 750.0,
    "vencimento": "2027-04-01",
    "status": "OK"
  },
  {
    "sku": "NEX-2024",
    "produto": "Iogurte Morango",
    "categoria": "Laticínios",
    "estoque": 80,
    "giro30d": 60,
    "custo": 3.2,
    "venda": 2.5,
    "capital": 256.0,
    "vencimento": "2026-04-15",
    "status": "PREJUÍZO"
  },
  {
    "sku": "NEX-2025",
    "produto": "Arroz 5kg",
    "categoria": "Mercearia",
    "estoque": 510,
    "giro30d": 0,
    "custo": 15.0,
    "venda": 26.0,
    "capital": 7650.0,
    "vencimento": "2026-12-20",
    "status": "CAPITAL MORTO"
  }
];

const errors = [
  {
    "sku": "NEX-2002",
    "problema": "VENCIMENTO – Iogurte Morango (Vence 2026-04-08)",
    "acao": "RETIRAR"
  },
  {
    "sku": "NEX-2004",
    "problema": "VENCIMENTO – Tomate Kg (Vence 2026-04-07)",
    "acao": "RETIRAR"
  },
  {
    "sku": "NEX-2005",
    "problema": "CAPITAL MORTO – Cerveja Lata (550 un, Giro=0/mês)",
    "acao": "INVESTIGAR"
  },
  {
    "sku": "NEX-2007",
    "problema": "PREJUÍZO – Feijão Carioca (Custo R$6.0 > Venda R$4.0)",
    "acao": "INVESTIGAR"
  },
  {
    "sku": "NEX-2008",
    "problema": "RUPTURA – Banana Prata (Estoque=0, Giro=180/mês)",
    "acao": "REABASTECER"
  },
  {
    "sku": "NEX-2010",
    "problema": "PREJUÍZO – Azeite Oliva (Custo R$28.0 > Venda R$25.0)",
    "acao": "INVESTIGAR"
  },
  {
    "sku": "NEX-2011",
    "problema": "VENCIMENTO – Maçã Fuji (Vence 2026-04-08)",
    "acao": "RETIRAR"
  },
  {
    "sku": "NEX-2012",
    "problema": "RUPTURA – Vinho Tinto (Estoque=0, Giro=45/mês)",
    "acao": "REABASTECER"
  },
  {
    "sku": "NEX-2015",
    "problema": "CAPITAL MORTO – Tomate Kg (480 un, Giro=0/mês)",
    "acao": "INVESTIGAR"
  },
  {
    "sku": "NEX-2017",
    "problema": "PREJUÍZO – Queijo Prato (Custo R$18.0 > Venda R$16.0)",
    "acao": "INVESTIGAR"
  },
  {
    "sku": "NEX-2018",
    "problema": "VENCIMENTO – Feijão Carioca (Vence 2026-04-09)",
    "acao": "RETIRAR"
  },
  {
    "sku": "NEX-2020",
    "problema": "CAPITAL MORTO – Leite Integral (600 un, Giro=0/mês)",
    "acao": "INVESTIGAR"
  },
  {
    "sku": "NEX-2022",
    "problema": "RUPTURA – Maçã Fuji (Estoque=0, Giro=95/mês)",
    "acao": "REABASTECER"
  },
  {
    "sku": "NEX-2024",
    "problema": "PREJUÍZO – Iogurte Morango (Custo R$3.2 > Venda R$2.5)",
    "acao": "INVESTIGAR"
  },
  {
    "sku": "NEX-2025",
    "problema": "CAPITAL MORTO – Arroz 5kg (510 un, Giro=0/mês)",
    "acao": "INVESTIGAR"
  }
];

const suspiciousIds = [];

// ─── STATUS BADGE ────────────────────────────────────────────────────────────
function statusBadgeClass(status) {
  const map = {
    'OK':           'badge-success',
    'CAPITAL MORTO':'badge-error',
    'PREJUÍZO':     'badge-error',
    'VENCIMENTO':   'badge-warning',
    'RUPTURA':      'badge-info',
  };
  return map[status] || 'badge-info';
}

// ─── RENDER TABLE ────────────────────────────────────────────────────────────
function renderTable(filter = 'all') {
  const tbody = document.getElementById('inventoryTable');
  tbody.innerHTML = '';
  inventory.forEach(item => {
    let show = true;
    if (filter === 'OK'   && item.status !== 'OK') show = false;
    if (filter === 'ERRO' && item.status === 'OK') show = false;
    if (!show) return;
    const tr = document.createElement('tr');
    tr.className = 'border-b border-gray-800 hover:bg-gray-800/50';
    tr.innerHTML = `
      <td class="py-3 px-4 font-mono text-blue-400">${item.sku}</td>
      <td class="py-3 px-4">${item.produto}</td>
      <td class="py-3 px-4 text-xs text-gray-500">${item.categoria}</td>
      <td class="py-3 px-4 font-medium">${item.estoque.toLocaleString('pt-BR')}</td>
      <td class="py-3 px-4 text-yellow-400">${item.giro30d}</td>
      <td class="py-3 px-4">R$ ${item.capital.toLocaleString('pt-BR',{minimumFractionDigits:2})}</td>
      <td class="py-3 px-4"><span class="badge ${statusBadgeClass(item.status)}">${item.status}</span></td>
    `;
    tbody.appendChild(tr);
  });
}

// ─── RENDER ERRORS ───────────────────────────────────────────────────────────
function renderErrors() {
  const tbody = document.getElementById('errorTable');
  tbody.innerHTML = '';
  errors.forEach(err => {
    const bc = err.acao === 'RETIRAR' ? 'badge-warning'
             : err.acao === 'REABASTECER' ? 'badge-info' : 'badge-error';
    const tr = document.createElement('tr');
    tr.className = 'border-b border-gray-800 hover:bg-gray-800/50';
    tr.innerHTML = `
      <td class="py-3 px-4 font-mono text-red-400">${err.sku}</td>
      <td class="py-3 px-4">${err.problema}</td>
      <td class="py-3 px-4"><span class="badge ${bc}">${err.acao}</span></td>
    `;
    tbody.appendChild(tr);
  });
}

// ─── RENDER SUSPICIOUS ───────────────────────────────────────────────────────
function renderSuspicious() {
  const tbody = document.getElementById('suspiciousTable');
  tbody.innerHTML = '';
  suspiciousIds.forEach(item => {
    const tr = document.createElement('tr');
    tr.className = 'border-b border-gray-800 hover:bg-gray-800/50';
    tr.innerHTML = `
      <td class="py-3 px-4 font-mono text-blue-400">${item.normalized}</td>
      <td class="py-3 px-4 text-xs text-gray-400">${item.original}</td>
      <td class="py-3 px-4"><span class="badge badge-warning">${item.status}</span></td>
    `;
    tbody.appendChild(tr);
  });
}

// ─── FILTER BUTTONS ──────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      renderTable(btn.dataset.filter);
    });
  });
});

// ─── KPIs ────────────────────────────────────────────────────────────────────
function updateKPIs() {
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
}

// ─── TOGGLE CHART ────────────────────────────────────────────────────────────
function toggleChart(card) {
  card.classList.toggle('active');
  card.querySelector('.chart-container').classList.toggle('expanded');
  const chartId = card.dataset.chart;
  setTimeout(() => Chart.getChart(chartId)?.resize(), 310);
}

// ─── CHARTS ──────────────────────────────────────────────────────────────────
function initCharts() {
  const labels   = inventory.map(i => i.sku);
  const estoques = inventory.map(i => i.estoque);
  const capitals = inventory.map(i => i.capital);
  const barColors = ['#22c55e', '#f59e0b', '#22c55e', '#f59e0b', '#ef4444', '#22c55e', '#f97316', '#3b82f6', '#22c55e', '#f97316', '#f59e0b', '#3b82f6', '#22c55e', '#22c55e', '#ef4444', '#22c55e', '#f97316', '#f59e0b', '#22c55e', '#ef4444', '#22c55e', '#3b82f6', '#22c55e', '#f97316', '#ef4444'];

  const baseOpts = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: { ticks: { color:'#9ca3af', font:{size:9}, maxRotation:60 }, grid:{ display:false } },
      y: { ticks: { color:'#9ca3af' }, grid:{ color:'#374151' } },
    },
  };

  new Chart(document.getElementById('balanceChart'), {
    type: 'bar',
    data: { labels, datasets: [{ label:'Estoque', data:estoques, backgroundColor:barColors, borderRadius:6 }] },
    options: {
      ...baseOpts,
      plugins: { ...baseOpts.plugins,
        tooltip: { callbacks: { label: ctx => 'Estoque: ' + ctx.parsed.y.toLocaleString('pt-BR') + ' un' } } },
    },
  });

  new Chart(document.getElementById('flowChart'), {
    type: 'bar',
    data: { labels, datasets: [{ label:'Capital (R$)', data:capitals, backgroundColor:barColors, borderRadius:6 }] },
    options: {
      ...baseOpts,
      plugins: { ...baseOpts.plugins,
        tooltip: { callbacks: { label: ctx => 'Capital: R$ ' + ctx.parsed.y.toLocaleString('pt-BR',{minimumFractionDigits:2}) } } },
    },
  });
}

// ─── INIT ────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  renderTable();
  renderErrors();
  renderSuspicious();
  updateKPIs();
  initCharts();
  // Expande os charts automaticamente
  document.querySelectorAll('.chart-card').forEach(card => {
    card.classList.add('active');
    card.querySelector('.chart-container').classList.add('expanded');
  });
  setTimeout(() => {
    Chart.getChart('balanceChart')?.resize();
    Chart.getChart('flowChart')?.resize();
  }, 150);
});
