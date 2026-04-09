import 'package:flutter/material.dart';
import 'package:nexus_engine/theme/app_theme.dart';
import 'package:nexus_engine/services/admin_service.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final AdminService _service = AdminService();

  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _error;

  // Métricas
  int _totalSkus = 0;
  int _semEstoque = 0;
  double _valorLiquido = 0;

  // Filtros
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterCategoria;
  String? _filterEstoque; // zerado | baixo | normal
  List<String> _categorias = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchAuditoria();
      int semEstq = 0;
      double valor = 0;
      final cats = <String>{};
      for (final item in data) {
        final estq = ((item['estoque_atual'] ?? 0) as num).toInt();
        final preco = ((item['preco_venda'] ?? 0) as num).toDouble();
        if (estq <= 0) semEstq++;
        valor += estq * preco;
        cats.add((item['categoria'] ?? 'Sem categoria') as String);
      }
      setState(() {
        _items = data;
        _totalSkus = data.length;
        _semEstoque = semEstq;
        _valorLiquido = valor;
        _categorias = cats.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _items.where((item) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final ok = '${item['produto'] ?? ''}'.toLowerCase().contains(q) ||
            '${item['sku_id'] ?? ''}'.toLowerCase().contains(q) ||
            '${item['categoria'] ?? ''}'.toLowerCase().contains(q);
        if (!ok) return false;
      }
      if (_filterCategoria != null && item['categoria'] != _filterCategoria) return false;
      if (_filterEstoque != null) {
        final v = ((item['estoque_atual'] ?? 0) as num).toInt();
        if (_filterEstoque == 'zerado' && v > 0) return false;
        if (_filterEstoque == 'baixo' && (v <= 0 || v > 10)) return false;
        if (_filterEstoque == 'normal' && v <= 10) return false;
      }
      return true;
    }).toList();
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
    }
    if (_error != null) {
      return _buildError();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        return Scaffold(
          backgroundColor: AppTheme.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: AppTheme.background,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.primaryTeal,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(isWide)),
                SliverToBoxAdapter(child: _buildSummaryCards(isWide)),
                SliverToBoxAdapter(child: _buildSearchAndFilters()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.teal10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_filtered.length} de $_totalSkus produtos',
                        style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                if (_filtered.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Nenhum produto encontrado',
                        style: TextStyle(color: AppTheme.textGray),
                      ),
                    ),
                  )
                else if (isWide)
                  _buildWideTable()
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildProductCard(_filtered[i]),
                      childCount: _filtered.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Error ──────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.criticalRed, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar inventário',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppTheme.textGray, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────

  Widget _buildHeader(bool isWide) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, isWide ? 32 : 20, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventário',
                  style: TextStyle(
                    fontSize: isWide ? 28 : 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textWhite,
                  ),
                ),
                const Text(
                  'Gestão de ativos em tempo real',
                  style: TextStyle(color: AppTheme.textGray, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal),
            tooltip: 'Atualizar',
          ),
        ],
      ),
    );
  }

  // ── Summary cards ─────────────────────────────────────────────

  Widget _buildSummaryCards(bool isWide) {
    final cards = [
      _SummaryCardData('TOTAL SKUs', '$_totalSkus', Icons.inventory_2_outlined, AppTheme.primaryTeal, false),
      _SummaryCardData('SEM ESTOQUE', '$_semEstoque', Icons.warning_amber_outlined, AppTheme.criticalRed, _semEstoque > 0),
      _SummaryCardData(
        'VALOR LÍQUIDO',
        'R\$ ${_formatMoney(_valorLiquido)}',
        Icons.attach_money,
        AppTheme.primaryTeal,
        true,
      ),
    ];

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: _buildSummaryCard(cards[i])),
            ],
          ],
        ),
      );
    }

    return SizedBox(
      height: 92,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(width: 160, child: _buildSummaryCard(cards[i])),
      ),
    );
  }

  Widget _buildSummaryCard(_SummaryCardData c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.highlight ? c.color.withValues(alpha: 0.4) : AppTheme.accentGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(c.icon, color: c.color, size: 13),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  c.label,
                  style: const TextStyle(fontSize: 9, color: AppTheme.textGray, letterSpacing: 1, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              c.value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.highlight ? c.color : AppTheme.textWhite),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search + Filters ──────────────────────────────────────────

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar produto, SKU ou categoria...',
              hintStyle: const TextStyle(color: AppTheme.textGray, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryTeal, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textGray, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.darkerPanel,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.accentGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.accentGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primaryTeal),
              ),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: _filterCategoria ?? 'Categoria',
                  isActive: _filterCategoria != null,
                  onTap: _showCategoriaFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _filterEstoque == null
                      ? 'Estoque'
                      : _filterEstoque == 'zerado'
                          ? 'Sem estoque'
                          : _filterEstoque == 'baixo'
                              ? 'Estoque baixo'
                              : 'Normal',
                  isActive: _filterEstoque != null,
                  onTap: _showEstoqueFilter,
                ),
                if (_filterCategoria != null || _filterEstoque != null || _searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() {
                        _filterCategoria = null;
                        _filterEstoque = null;
                        _searchQuery = '';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.teal10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryTeal),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear_all, color: AppTheme.primaryTeal, size: 14),
                          SizedBox(width: 4),
                          Text('Limpar', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.teal10 : AppTheme.darkerPanel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppTheme.primaryTeal : AppTheme.accentGray),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primaryTeal : AppTheme.textGray,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: isActive ? AppTheme.primaryTeal : AppTheme.textGray, size: 16),
          ],
        ),
      ),
    );
  }

  void _showCategoriaFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkerPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppTheme.accentGray, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filtrar por Categoria',
              style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: const Text('Todas as categorias', style: TextStyle(color: AppTheme.textGray)),
                    trailing: _filterCategoria == null ? const Icon(Icons.check, color: AppTheme.primaryTeal) : null,
                    onTap: () {
                      setState(() => _filterCategoria = null);
                      Navigator.pop(context);
                    },
                  ),
                  ..._categorias.map(
                    (c) => ListTile(
                      title: Text(
                        c,
                        style: TextStyle(
                          color: _filterCategoria == c ? AppTheme.primaryTeal : AppTheme.textWhite,
                        ),
                      ),
                      trailing: _filterCategoria == c ? const Icon(Icons.check, color: AppTheme.primaryTeal) : null,
                      onTap: () {
                        setState(() => _filterCategoria = c);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEstoqueFilter() {
    final opts = [
      ('zerado', 'Sem estoque (0)'),
      ('baixo', 'Estoque baixo (1–10)'),
      ('normal', 'Estoque normal (>10)'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkerPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppTheme.accentGray, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Filtrar por Estoque',
            style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Todos os níveis', style: TextStyle(color: AppTheme.textGray)),
            trailing: _filterEstoque == null ? const Icon(Icons.check, color: AppTheme.primaryTeal) : null,
            onTap: () {
              setState(() => _filterEstoque = null);
              Navigator.pop(context);
            },
          ),
          ...opts.map(
            (o) => ListTile(
              title: Text(
                o.$2,
                style: TextStyle(
                  color: _filterEstoque == o.$1 ? AppTheme.primaryTeal : AppTheme.textWhite,
                ),
              ),
              trailing: _filterEstoque == o.$1 ? const Icon(Icons.check, color: AppTheme.primaryTeal) : null,
              onTap: () {
                setState(() => _filterEstoque = o.$1);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Product card (mobile) ─────────────────────────────────────

  Widget _buildProductCard(Map<String, dynamic> item) {
    final estoque = ((item['estoque_atual'] ?? 0) as num).toInt();
    final precoVenda = ((item['preco_venda'] ?? 0) as num).toDouble();
    final precoCusto = ((item['preco_custo'] ?? 0) as num).toDouble();
    final categoria = (item['categoria'] ?? '-') as String;
    final produto = (item['produto'] ?? '-') as String;
    final skuId = (item['sku_id'] ?? '-') as String;
    final vencimento = (item['data_vencimento'] ?? '') as String;

    Color estoqueColor;
    String estoqueLabel;
    if (estoque <= 0) {
      estoqueColor = AppTheme.criticalRed;
      estoqueLabel = 'SEM ESTOQUE';
    } else if (estoque <= 10) {
      estoqueColor = AppTheme.warningOrange;
      estoqueLabel = 'BAIXO';
    } else {
      estoqueColor = AppTheme.primaryTeal;
      estoqueLabel = 'OK';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome + badge de estoque
            Row(
              children: [
                Expanded(
                  child: Text(
                    produto,
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: estoqueColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: estoqueColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    estoqueLabel,
                    style: TextStyle(
                      color: estoqueColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Categoria + SKU
            Row(
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 130),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.teal10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    categoria,
                    style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  skuId,
                  style: const TextStyle(color: AppTheme.textGray, fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppTheme.accentGray, height: 1),
            const SizedBox(height: 10),
            // Métricas
            Row(
              children: [
                _buildMiniMetric('ESTOQUE', '$estoque un', estoqueColor),
                _buildMiniMetric('CUSTO', 'R\$ ${_formatNum(precoCusto)}', AppTheme.textGray),
                _buildMiniMetric('VENDA', 'R\$ ${_formatNum(precoVenda)}', AppTheme.textWhite),
                if (vencimento.isNotEmpty)
                  _buildMiniMetric(
                    'VENCE',
                    vencimento.length > 10 ? vencimento.substring(0, 10) : vencimento,
                    AppTheme.textGray,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: AppTheme.textGray,
              letterSpacing: 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 12, color: valueColor, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Wide table (tablet/desktop) ───────────────────────────────

  Widget _buildWideTable() {
    final data = _filtered;
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(
          color: AppTheme.darkerPanel,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.accentGray),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 800),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppTheme.darkPanel,
                  child: const Row(
                    children: [
                      SizedBox(width: 220, child: Text('PRODUTO', style: _headerStyle)),
                      SizedBox(width: 130, child: Text('CATEGORIA', style: _headerStyle)),
                      SizedBox(width: 100, child: Text('SKU', style: _headerStyle)),
                      SizedBox(width: 80, child: Text('ESTOQUE', style: _headerStyle)),
                      SizedBox(width: 90, child: Text('CUSTO', style: _headerStyle)),
                      SizedBox(width: 90, child: Text('VENDA', style: _headerStyle)),
                      SizedBox(width: 110, child: Text('VENCIMENTO', style: _headerStyle)),
                    ],
                  ),
                ),
                // Rows
                ...data.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final estoque = ((item['estoque_atual'] ?? 0) as num).toInt();
                  Color estoqueColor = estoque <= 0
                      ? AppTheme.criticalRed
                      : estoque <= 10
                          ? AppTheme.warningOrange
                          : AppTheme.textWhite;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: i.isOdd ? AppTheme.darkPanel.withValues(alpha: 0.3) : Colors.transparent,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 220,
                          child: Text(
                            '${item['produto'] ?? '-'}',
                            style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 130,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.teal10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item['categoria'] ?? '-'}',
                                style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            '${item['sku_id'] ?? '-'}',
                            style: const TextStyle(color: AppTheme.textGray, fontSize: 11, fontFamily: 'monospace'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            '$estoque',
                            style: TextStyle(color: estoqueColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            'R\$ ${_formatNum(((item['preco_custo'] ?? 0) as num).toDouble())}',
                            style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            'R\$ ${_formatNum(((item['preco_venda'] ?? 0) as num).toDouble())}',
                            style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: Text(
                            '${item['data_vencimento'] ?? '-'}',
                            style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 10,
    color: AppTheme.primaryTeal,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  // ── Helpers ───────────────────────────────────────────────────

  String _formatNum(double v) => v.toStringAsFixed(2);

  String _formatMoney(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}

// ── Data class ─────────────────────────────────────────────────

class _SummaryCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _SummaryCardData(this.label, this.value, this.icon, this.color, this.highlight);
}

