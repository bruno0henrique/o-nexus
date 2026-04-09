const inventory = [
    { sku: 'BRG-6204', desc: 'Rolamento de Esferas', entries: 7003, exits: 4322, balance: 2681, valorTotal: 112816.48, status: 'OK', originalIds: 'BRG-6204, BRG_6204, brg-6204' },
    { sku: 'BRG-62O4', desc: 'Rolamento de Esferas', entries: 0, exits: 123, balance: -123, valorTotal: 0, status: 'ERRO', originalIds: 'BRG-62O4' },
    { sku: 'FAN-COOL-02', desc: 'Cooler Industrial', entries: 5049, exits: 4676, balance: 373, valorTotal: 31701.27, status: 'OK', originalIds: 'FAN-COOL-02, FAN_COOL_02, fan-cool-02' },
    { sku: 'FAN-COOL-O2', desc: 'Cooler Industrial', entries: 217, exits: 263, balance: -46, valorTotal: -3854.34, status: 'ERRO', originalIds: 'FAN-COOL-O2' },
    { sku: 'KADAC-TX90', desc: 'Módulo Kadac TX90', entries: 5521, exits: 3641, balance: 1880, valorTotal: 1673237.60, status: 'OK', originalIds: 'KADAC-TX90, KADAC_TX90, kadac-tx90' },
    { sku: 'KADAC-TX9O', desc: 'Módulo Kadac TX90', entries: 177, exits: 172, balance: 5, valorTotal: 4447.25, status: 'OK', originalIds: 'KADAC-TX9O' },
    { sku: 'PLC-NEX-01', desc: 'Controlador Nexus 01', entries: 5025, exits: 4853, balance: 172, valorTotal: 498865.36, status: 'OK', originalIds: 'PLC-NEX-01, PLC_NEX_01, plc-nex-01' },
    { sku: 'PLC-NEX-O1', desc: 'Controlador Nexus 01', entries: 242, exits: 310, balance: -68, valorTotal: -197202.72, status: 'ERRO', originalIds: 'PLC-NEX-O1' },
    { sku: 'SENS-LSR-01', desc: 'Sensor Laser', entries: 6048, exits: 8029, balance: -1981, valorTotal: -2377774.49, status: 'ERRO', originalIds: 'SENS-LSR-01, SENS_LSR_01, sens-lsr-01' },
    { sku: 'SENS-LSR-O1', desc: 'Sensor Laser', entries: 448, exits: 142, balance: 306, valorTotal: 367310.16, status: 'OK', originalIds: 'SENS-LSR-O1' },
    { sku: 'SRV-5000-X', desc: 'Servomotor 5KW', entries: 5648, exits: 3984, balance: 1664, valorTotal: 6988450.56, status: 'OK', originalIds: 'SRV-5000-X, SRV_5000_X, srv-5000-x' },
    { sku: 'SRV-5OOO-X', desc: 'Servomotor 5KW', entries: 0, exits: 261, balance: -261, valorTotal: 0, status: 'ERRO', originalIds: 'SRV-5OOO-X' },
    { sku: 'WIR-RED-50M', desc: 'Cabo Flexível Vermelho', entries: 5700, exits: 4246, balance: 1454, valorTotal: 9741.80, status: 'OK', originalIds: 'WIR-RED-50M, WIR_RED_50M, wir-red-50m' },
    { sku: 'WIR-RED-5OM', desc: 'Cabo Flexível Vermelho', entries: 624, exits: 43, balance: 581, valorTotal: 3079.30, status: 'OK', originalIds: 'WIR-RED-5OM' }
];

const errors = [
    { sku: 'BRG-62O4', problema: 'Saldo negativo (-123) - ID com O vs 0', acao: 'INVESTIGAR' },
    { sku: 'FAN-COOL-O2', problema: 'Saldo negativo (-46) - ID com O vs 0', acao: 'INVESTIGAR' },
    { sku: 'PLC-NEX-O1', problema: 'Saldo negativo (-68) - ID com O vs 0', acao: 'INVESTIGAR' },
    { sku: 'SENS-LSR-01', problema: 'Saldo negativo (-1981) - Saída sem lastro', acao: 'INVESTIGAR' },
    { sku: 'SRV-5OOO-X', problema: 'Saldo negativo (-261) - ID com OOO vs 000', acao: 'INVESTIGAR' }
];

const suspiciousIds = [
    { normalized: 'BRG-6204', original: 'BRG-6204, BRG_6204, brg-6204, BRG-62O4', status: 'DIFERENTE' },
    { normalized: 'FAN-COOL-02', original: 'FAN-COOL-02, FAN_COOL_02, fan-cool-02, FAN-COOL-O2', status: 'DIFERENTE' },
    { normalized: 'KADAC-TX90', original: 'KADAC-TX90, KADAC_TX90, kadac-tx90, KADAC-TX9O', status: 'DIFERENTE' },
    { normalized: 'PLC-NEX-01', original: 'PLC-NEX-01, PLC_NEX_01, plc-nex-01, PLC-NEX-O1', status: 'DIFERENTE' },
    { normalized: 'SENS-LSR-01', original: 'SENS-LSR-01, SENS_LSR_01, sens-lsr-01, SENS-LSR-O1', status: 'DIFERENTE' },
    { normalized: 'SRV-5000-X', original: 'SRV-5000-X, SRV_5000_X, srv-5000-x, SRV-5OOO-X', status: 'DIFERENTE' },
    { normalized: 'WIR-RED-50M', original: 'WIR-RED-50M, WIR_RED_50M, wir-red-50m, WIR-RED-5OM', status: 'DIFERENTE' }
];

function renderTable(filter = 'all') {
    const tbody = document.getElementById('inventoryTable');
    tbody.innerHTML = '';
    
    inventory.forEach(item => {
        let show = true;
        if (filter === 'OK' && item.status !== 'OK') show = false;
        if (filter === 'ERRO' && item.status !== 'ERRO') show = false;
        
        if (show) {
            let statusClass = item.status === 'OK' ? 'badge-success' : 'badge-error';
            let balanceClass = item.balance > 0 ? 'text-green-400' : (item.balance < 0 ? 'text-red-400' : 'text-gray-400');
            
            const tr = document.createElement('tr');
            tr.className = 'border-b border-gray-800 hover:bg-gray-800/50';
            tr.innerHTML = `
                <td class="py-3 px-4 font-mono text-blue-400">${item.sku}</td>
                <td class="py-3 px-4 text-xs text-gray-500">${item.originalIds}</td>
                <td class="py-3 px-4">${item.entries}</td>
                <td class="py-3 px-4">${item.exits}</td>
                <td class="py-3 px-4 ${balanceClass} font-bold">${item.balance}</td>
                <td class="py-3 px-4">R$ ${item.valorTotal.toLocaleString('pt-BR', {minimumFractionDigits: 2})}</td>
                <td class="py-3 px-4"><span class="badge ${statusClass}">${item.status}</span></td>
            `;
            tbody.appendChild(tr);
        }
    });
}

function renderErrors() {
    const tbody = document.getElementById('errorTable');
    tbody.innerHTML = '';
    
    errors.forEach(err => {
        const tr = document.createElement('tr');
        tr.className = 'border-b border-gray-800 hover:bg-gray-800/50';
        tr.innerHTML = `
            <td class="py-3 px-4 font-mono text-red-400">${err.sku}</td>
            <td class="py-3 px-4">${err.problema}</td>
            <td class="py-3 px-4"><span class="badge badge-error">${err.acao}</span></td>
        `;
        tbody.appendChild(tr);
    });
}

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

document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        renderTable(btn.dataset.filter);
    });
});

function toggleChart(card) {
    card.classList.toggle('active');
    card.querySelector('.chart-container').classList.toggle('expanded');
    Chart.getChart(card.dataset.chart)?.resize();
}

function updateKPIs() {
    const totalEntries = inventory.reduce((sum, item) => sum + item.entries, 0);
    const totalExits = inventory.reduce((sum, item) => sum + item.exits, 0);
    const totalBalance = inventory.reduce((sum, item) => sum + item.balance, 0);
    const totalValue = inventory.reduce((sum, item) => sum + item.valorTotal, 0);

    document.querySelector('[data-kpi="entries"] .kpi-value').textContent = totalEntries.toLocaleString('pt-BR');
    document.querySelector('[data-kpi="exits"] .kpi-value').textContent = totalExits.toLocaleString('pt-BR');
    document.querySelector('[data-kpi="balance"] .kpi-value').textContent = totalBalance.toLocaleString('pt-BR');
    
    const valueElement = document.querySelector('[data-kpi="capital"] .kpi-value');
    if (totalValue >= 1000000) {
        valueElement.textContent = `R$ ${(totalValue / 1000000).toFixed(2)}M`;
    } else if (totalValue >= 1000) {
        valueElement.textContent = `R$ ${(totalValue / 1000).toFixed(2)}K`;
    } else {
        valueElement.textContent = `R$ ${totalValue.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`;
    }
}

document.addEventListener('DOMContentLoaded', () => {
    renderTable();
    renderErrors();
    renderSuspicious();
    updateKPIs();
    initCharts();
});

function initCharts() {
    const balanceData = inventory.map(i => i.balance);
    const entryData = inventory.map(i => i.entries);
    const exitData = inventory.map(i => i.exits);
    const labels = inventory.map(i => i.sku);

    new Chart(document.getElementById('balanceChart'), {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Saldo',
                data: balanceData,
                backgroundColor: balanceData.map(b => b >= 0 ? '#22c55e' : '#ef4444'),
                borderRadius: 6
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                x: { ticks: { color: '#9ca3af' }, grid: { display: false } },
                y: { ticks: { color: '#9ca3af' }, grid: { color: '#374151' } }
            }
        }
    });

    new Chart(document.getElementById('flowChart'), {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                { label: 'Entradas', data: entryData, backgroundColor: '#22c55e', borderRadius: 6 },
                { label: 'Saídas', data: exitData, backgroundColor: '#ef4444', borderRadius: 6 }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { position: 'bottom', labels: { color: '#9ca3af' } } },
            scales: {
                x: { ticks: { color: '#9ca3af' }, grid: { display: false } },
                y: { ticks: { color: '#9ca3af' }, grid: { color: '#374151' } }
            }
        }
    });
}
