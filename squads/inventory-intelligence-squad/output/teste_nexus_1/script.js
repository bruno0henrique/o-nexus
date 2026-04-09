// O NEXUS | Inventory Intelligence Engine
// Lógica de Renderização Portável (Local Friendly)

document.addEventListener('DOMContentLoaded', () => {
    // Definir data no cabeçalho
    const today = new Date();
    document.getElementById('current-date').innerText = today.toLocaleDateString('pt-BR');
    
    // Inicializar o motor
    initializeMotor();

    // Listeners de filtro
    document.getElementById('search-input').addEventListener('input', applyFilters);
    document.getElementById('category-filter').addEventListener('change', applyFilters);
});

function initializeMotor() {
    // inventoryData já está disponível via data.js de forma global
    if (typeof inventoryData !== 'undefined' && inventoryData.length > 0) {
        populateCategories();
        updateKpis(inventoryData);
        renderTable(inventoryData);
        console.log('Motor O NEXUS iniciado com ' + inventoryData.length + ' registros.');
    } else {
        console.error('Falha crítica: inventoryData não encontrado no data.js');
        alert('Erro ao carregar dados do data.js. Verifique a existência do arquivo na pasta.');
    }
}

function populateCategories() {
    const categories = [...new Set(inventoryData.map(item => item.Categoria))];
    const select = document.getElementById('category-filter');
    categories.forEach(cat => {
        const opt = document.createElement('option');
        opt.value = cat;
        opt.innerText = cat;
        select.appendChild(opt);
    });
}

function updateKpis(data) {
    const totalCapital = data.reduce((sum, item) => sum + item['Capital Travado'], 0);
    const totalProfit = data.reduce((sum, item) => sum + (item['Oportunidade Lucro'] || 0), 0);
    const criticalAlerts = data.filter(item => item['Status para IA'] === 'VENCIMENTO' || item['Status para IA'] === 'CAPITAL MORTO').length;

    document.getElementById('total-capital').innerText = `R$ ${totalCapital.toLocaleString('pt-BR', {minimumFractionDigits: 2})}`;
    document.getElementById('total-profit').innerText = `R$ ${totalProfit.toLocaleString('pt-BR', {minimumFractionDigits: 2})}`;
    document.getElementById('total-alerts').innerText = criticalAlerts;
}

function renderTable(data) {
    const tbody = document.getElementById('inventory-table-body');
    tbody.innerHTML = '';

    data.forEach(item => {
        const tr = document.createElement('tr');
        
        let statusClass = 'bg-success';
        if (item['Status para IA'] === 'VENCIMENTO') statusClass = 'bg-danger';
        if (item['Status para IA'] === 'CAPITAL MORTO') statusClass = 'bg-warning';
        if (item['Status para IA'] === 'PREJUÍZO') statusClass = 'bg-danger';

        tr.innerHTML = `
            <td><strong>${item.Produto}</strong><br><small>${item.SKU_ID}</small></td>
            <td>${item.Categoria}</td>
            <td>${item.Estoque}</td>
            <td>R$ ${item['Capital Travado'].toLocaleString('pt-BR')}</td>
            <td>${item.Vencimento}</td>
            <td><span class="status-badge-row ${statusClass}">${item['Status para IA']}</span></td>
        `;
        tbody.appendChild(tr);
    });
}

function applyFilters() {
    const searchTerm = document.getElementById('search-input').value.toLowerCase();
    const categoryTerm = document.getElementById('category-filter').value;

    const filtered = inventoryData.filter(item => {
        const matchesSearch = item.Produto.toLowerCase().includes(searchTerm);
        const matchesCategory = categoryTerm === 'all' || item.Categoria === categoryTerm;
        return matchesSearch && matchesCategory;
    });

    updateKpis(filtered);
    renderTable(filtered);
}
