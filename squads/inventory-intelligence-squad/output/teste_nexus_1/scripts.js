// Os dados (inventory, errors, suspiciousIds) são carregados via data.js

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
