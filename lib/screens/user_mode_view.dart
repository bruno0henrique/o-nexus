import 'package:flutter/material.dart';
import 'package:nexus_engine/services/admin_service.dart';
import 'package:nexus_engine/theme/app_theme.dart';

class UserModeView extends StatefulWidget {
  final String? storeId;
  final String? storeName;
  const UserModeView({super.key, this.storeId, this.storeName});

  @override
  State<UserModeView> createState() => _UserModeViewState();
}

class _UserModeViewState extends State<UserModeView> {
  final AdminService _service = AdminService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = [];

  String _searchQuery = '';
  String? _filterCategoria;
  String? _filterEstoqueRange;
  int _currentPage = 0;
  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant UserModeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storeId != widget.storeId) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _service.fetchAuditoria(mercadinhoId: widget.storeId);
      setState(() {
        _rows = data;
        _isLoading = false;
        _currentPage = 0;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _rows.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = '${p['produto'] ?? ''}'.toLowerCase().contains(q) ||
            '${p['sku_id'] ?? ''}'.toLowerCase().contains(q) ||
            '${p['categoria'] ?? ''}'.toLowerCase().contains(q);
        if (!match) return false;
      }
      if (_filterCategoria != null && _filterCategoria!.isNotEmpty) {
        if ('${p['categoria'] ?? ''}' != _filterCategoria) return false;
      }
      if (_filterEstoqueRange != null) {
        final estoque = ((p['estoque_atual'] ?? 0) as num).toDouble();
        if (_filterEstoqueRange == 'baixo' && estoque > 10) return false;
        if (_filterEstoqueRange == 'medio' && (estoque <= 10 || estoque > 40)) return false;
        if (_filterEstoqueRange == 'alto' && estoque <= 40) return false;
      }
      return true;
    }).toList();
  }

  List<String> get _allCategories {
    final set = _rows.map((p) => '${p['categoria'] ?? 'Sem categoria'}').toSet().toList();
    set.sort();
    return set;
  }

  int get _totalPages => (_filteredProducts.length / _pageSize).ceil().clamp(1, 999);

  List<Map<String, dynamic>> get _pageProducts {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredProducts.length);
    if (start >= _filteredProducts.length) return [];
    return _filteredProducts.sublist(start, end);
  }

  int get _totalSkus => _rows.length;
  int get _semEstoque => _rows.where((e) => ((e['estoque_atual'] ?? 0) as num) <= 0).length;
  double get _valorTotalEstoque => _rows.fold<double>(
      0,
      (acc, e) =>
          acc + (((e['estoque_atual'] ?? 0) as num) * ((e['preco_venda'] ?? 0) as num)).toDouble());
  double get _capitalCusto => _rows.fold<double>(
      0,
      (acc, e) =>
          acc + (((e['estoque_atual'] ?? 0) as num) * ((e['preco_custo'] ?? 0) as num)).toDouble());

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.criticalRed, size: 36),
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: AppTheme.textGray), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront, color: AppTheme.primaryTeal, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.storeName ?? 'Loja selecionada',
                  style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal),
                tooltip: 'Atualizar',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Visão de Capital (dinâmica) ──
          Row(
            children: const [
              Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primaryTeal, size: 22),
              SizedBox(width: 8),
              Text(
                'Visão de Capital',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildExecCard('VALOR TOTAL EM ESTOQUE', _money(_valorTotalEstoque), icon: Icons.arrow_upward, iconColor: AppTheme.primaryTeal)),
                SizedBox(width: isMobile ? 12 : 24),
                Expanded(child: _buildExecCard('CAPITAL EM CUSTO', _money(_capitalCusto), subtitle: 'SKUs ativos: $_totalSkus', valueColor: AppTheme.primaryTeal)),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 20 : 32),

          // ── Ações do Dia ──
          Row(
            children: const [
              Icon(Icons.bolt, color: AppTheme.warningOrange, size: 22),
              SizedBox(width: 8),
              Text(
                'Ações do Dia',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAcoesCards(isMobile),
          SizedBox(height: isMobile ? 20 : 32),

          // ── Inventário Detalhado ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: AppTheme.primaryTeal),
                    const SizedBox(width: 8),
                    Flexible(child: Text(
                      'Inventário Detalhado',
                      style: TextStyle(fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('VER TUDO', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearchAndFilters(isMobile),
          const SizedBox(height: 16),
          _buildInventoryTable(isMobile),
          SizedBox(height: isMobile ? 20 : 32),

          // ── Blocos informativos ──
          if (isMobile) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkerPanel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Visão do Armazém', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                  SizedBox(height: 8),
                  Text(
                    'Itens sem estoque: $_semEstoque.\nUse os filtros e o inventário detalhado para priorizar reposição.',
                    style: TextStyle(color: AppTheme.textGray, height: 1.5, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.darkerPanel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentGray),
              ),
              child: Row(
                children: const [
                  Icon(Icons.stacked_line_chart, color: AppTheme.primaryTeal, size: 28),
                  SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Previsão IA', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('Resumo alimentado pelos dados reais da loja selecionada no Supabase.', style: TextStyle(color: AppTheme.textGray, fontSize: 12)),
                    ],
                  )),
                ],
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.darkerPanel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.accentGray),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Visão do Armazém', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                        SizedBox(height: 8),
                        Text(
                          'Itens sem estoque: $_semEstoque.\nAcompanhe as rupturas e reposicoes por categoria.',
                          style: TextStyle(color: AppTheme.textGray, height: 1.5, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 200,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.darkerPanel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.accentGray),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.stacked_line_chart, color: AppTheme.primaryTeal, size: 32),
                          SizedBox(height: 16),
                          Text('Previsão IA', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 8),
                          Text(
                            'Resumo alimentado por\nestoque atual da loja\nselecionada.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textGray, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _money(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  Widget _buildAcoesCards(bool isMobile) {
    final card1 = _buildAcaoCard(
      borderColor: AppTheme.warningOrange,
      icon: Icons.access_time_filled,
      iconColor: AppTheme.warningOrange,
      titulo: 'Rupturas',
      corpo: RichText(
        text: TextSpan(
          style: TextStyle(color: AppTheme.textGray, fontSize: 13, height: 1.5),
          children: [
            const TextSpan(text: 'Produtos sem estoque agora: '),
            TextSpan(text: '$_semEstoque', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            const TextSpan(text: '\n\nSugestão: priorizar itens com maior giro.'),
          ],
        ),
      ),
      botaoLabel: 'EXECUTAR SUGESTÃO',
      botaoStyle: _ActionBtnStyle.outlined,
    );
    final card2 = _buildAcaoCard(
      borderColor: AppTheme.primaryTeal,
      icon: Icons.shopping_cart,
      iconColor: AppTheme.primaryTeal,
      titulo: 'Inventário Filtrado',
      corpo: RichText(
        text: TextSpan(
          style: TextStyle(color: AppTheme.textGray, fontSize: 13, height: 1.5),
          children: [
            const TextSpan(text: 'Registros visíveis com filtros atuais: '),
            TextSpan(text: '${_filteredProducts.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            const TextSpan(text: '.\n\nAjuste categoria e estoque para foco operacional.'),
          ],
        ),
      ),
      botaoLabel: 'ABRIR PEDIDO',
      botaoStyle: _ActionBtnStyle.filled,
    );
    final card3 = _buildAcaoCard(
      borderColor: const Color(0xFF8B4513),
      icon: Icons.warning_amber_rounded,
      iconColor: AppTheme.criticalRed,
      titulo: 'Capital em Estoque',
      corpo: RichText(
        text: TextSpan(
          style: TextStyle(color: AppTheme.textGray, fontSize: 13, height: 1.5),
          children: [
            const TextSpan(text: 'Valor de venda acumulado:\n'),
            TextSpan(text: _money(_valorTotalEstoque), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.criticalRed)),
            const TextSpan(text: '\n\nMonitore para evitar capital parado.'),
          ],
        ),
      ),
      botaoLabel: 'EXECUTAR SUGESTÃO',
      botaoStyle: _ActionBtnStyle.dark,
    );

    if (isMobile) {
      return Column(children: [
        card1, const SizedBox(height: 12),
        card2, const SizedBox(height: 12),
        card3,
      ]);
    }
    return Row(children: [
      Expanded(child: card1),
      const SizedBox(width: 16),
      Expanded(child: card2),
      const SizedBox(width: 16),
      Expanded(child: card3),
    ]);
  }

  Widget _buildAcaoCard({
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String titulo,
    required Widget corpo,
    required String botaoLabel,
    required _ActionBtnStyle botaoStyle,
  }) {
    Color bgColor;
    Color textColor;
    Color borderBtn;
    switch (botaoStyle) {
      case _ActionBtnStyle.filled:
        bgColor = AppTheme.primaryTeal;
        textColor = AppTheme.background;
        borderBtn = AppTheme.primaryTeal;
        break;
      case _ActionBtnStyle.outlined:
        bgColor = Colors.transparent;
        textColor = AppTheme.textWhite;
        borderBtn = AppTheme.accentGray;
        break;
      case _ActionBtnStyle.dark:
        bgColor = const Color(0xFF2A1F14);
        textColor = AppTheme.textWhite;
        borderBtn = const Color(0xFF5C3A1E);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(titulo, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          corpo,
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: bgColor,
                side: BorderSide(color: borderBtn),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(botaoLabel, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Pesquisar por nome, SKU ou categoria...',
              hintStyle: const TextStyle(color: AppTheme.textGray, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textGray, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textGray, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() { _searchQuery = ''; _currentPage = 0; });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.darkPanel,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.accentGray)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.accentGray)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primaryTeal)),
            ),
            onChanged: (v) => setState(() { _searchQuery = v; _currentPage = 0; }),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Filtros:', style: TextStyle(color: AppTheme.textGray, fontSize: 12, fontWeight: FontWeight.bold)),
              _buildDropdownFilter(
                label: 'Categoria',
                value: _filterCategoria,
                items: _allCategories,
                onChanged: (v) => setState(() { _filterCategoria = v; _currentPage = 0; }),
              ),
              _buildDropdownFilter(
                label: 'Estoque',
                value: _filterEstoqueRange,
                items: const ['baixo', 'medio', 'alto'],
                displayMap: const {'baixo': 'Baixo (≤25%)', 'medio': 'Médio (26-70%)', 'alto': 'Alto (>70%)'},
                onChanged: (v) => setState(() { _filterEstoqueRange = v; _currentPage = 0; }),
              ),
              if (_filterCategoria != null || _filterEstoqueRange != null)
                TextButton.icon(
                  onPressed: () => setState(() { _filterCategoria = null; _filterEstoqueRange = null; _currentPage = 0; }),
                  icon: const Icon(Icons.clear_all, size: 16, color: AppTheme.primaryTeal),
                  label: const Text('Limpar filtros', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 12)),
                ),
              Text('${_filteredProducts.length} produtos', style: const TextStyle(color: AppTheme.textGray, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    Map<String, String>? displayMap,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: value != null ? AppTheme.primaryTeal : AppTheme.accentGray),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label, style: const TextStyle(color: AppTheme.textGray, fontSize: 12)),
          dropdownColor: AppTheme.darkPanel,
          style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textGray, size: 18),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('Todos', style: TextStyle(color: AppTheme.textGray))),
            ...items.map((item) => DropdownMenuItem<String>(value: item, child: Text(displayMap?[item] ?? item))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInventoryTable(bool isMobile) {
    final products = _pageProducts;
    if (isMobile) return _buildMobileInventoryList(products);
    return _buildDesktopInventoryTable(products);
  }

  // ── Mobile: lista de cards compactos ──
  Widget _buildMobileInventoryList(List<Map<String, dynamic>> products) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Column(
        children: [
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text('Nenhum produto encontrado', style: TextStyle(color: AppTheme.textGray))),
            )
          else
            ...products.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final estoque = ((item['estoque_atual'] ?? 0) as num).toInt();
              final estoquePct = estoque <= 0 ? 0 : (estoque >= 100 ? 100 : estoque);
              final barColor = estoquePct <= 10 ? AppTheme.criticalRed : estoquePct <= 25 ? AppTheme.warningOrange : AppTheme.primaryTeal;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: i.isOdd ? AppTheme.darkPanel.withValues(alpha: 0.3) : Colors.transparent,
                  border: i < products.length - 1
                      ? const Border(bottom: BorderSide(color: Color(0xFF222222), width: 0.5))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha 1: nome + preço
                    Row(
                      children: [
                        Expanded(child: Text('${item['produto'] ?? '-'}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Text('R\$ ${((item['preco_venda'] ?? 0) as num).toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Linha 2: SKU + categoria
                    Row(
                      children: [
                        Text('SKU: ${item['sku_id'] ?? '-'}', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppTheme.teal10, borderRadius: BorderRadius.circular(3)),
                          child: Text('${item['categoria'] ?? '-'}', style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 9)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Linha 3: barra de estoque
                    Row(
                      children: [
                        Expanded(child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: estoquePct / 100,
                            backgroundColor: AppTheme.accentGray,
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                            minHeight: 6,
                          ),
                        )),
                        const SizedBox(width: 10),
                        SizedBox(width: 36, child: Text('$estoquePct%', style: TextStyle(color: barColor, fontSize: 12, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 8),
                        Text(_money((((item['estoque_atual'] ?? 0) as num) * ((item['preco_venda'] ?? 0) as num)).toDouble()), style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const Divider(height: 1, color: AppTheme.accentGray),
          _buildPaginationBar(),
        ],
      ),
    );
  }

  // ── Desktop: tabela tradicional ──
  Widget _buildDesktopInventoryTable(List<Map<String, dynamic>> products) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              children: const [
                Expanded(flex: 3, child: _TableHeader('PRODUTO')),
                Expanded(flex: 2, child: _TableHeader('CATEGORIA')),
                Expanded(flex: 3, child: _TableHeader('NÍVEL DE ESTOQUE')),
                Expanded(flex: 2, child: _TableHeader('PREÇO UNIT.')),
                Expanded(flex: 2, child: _TableHeader('VALOR TOTAL')),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.accentGray),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text('Nenhum produto encontrado', style: TextStyle(color: AppTheme.textGray))),
            )
          else
            ...products.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final estoque = ((item['estoque_atual'] ?? 0) as num).toInt();
              final estoquePct = estoque <= 0 ? 0 : (estoque >= 100 ? 100 : estoque);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: i.isOdd ? AppTheme.darkPanel.withValues(alpha: 0.3) : Colors.transparent,
                  border: const Border(bottom: BorderSide(color: Color(0xFF222222), width: 0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['produto'] ?? '-'}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('SKU: ${item['sku_id'] ?? '-'}', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
                      ],
                    )),
                    Expanded(flex: 2, child: Text('${item['categoria'] ?? '-'}', style: const TextStyle(color: AppTheme.textGray, fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 3, child: Row(
                      children: [
                        Expanded(child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: estoquePct / 100,
                            backgroundColor: AppTheme.accentGray,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              estoquePct <= 10 ? AppTheme.criticalRed : estoquePct <= 25 ? AppTheme.warningOrange : AppTheme.primaryTeal,
                            ),
                            minHeight: 8,
                          ),
                        )),
                        const SizedBox(width: 10),
                        SizedBox(width: 36, child: Text('$estoquePct%', style: TextStyle(
                          color: estoquePct <= 10 ? AppTheme.criticalRed : estoquePct <= 25 ? AppTheme.warningOrange : AppTheme.textWhite,
                          fontSize: 12, fontWeight: FontWeight.bold,
                        ))),
                      ],
                    )),
                    Expanded(flex: 2, child: Text('R\$ ${((item['preco_venda'] ?? 0) as num).toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 12))),
                    Expanded(flex: 2, child: Text(_money((((item['estoque_atual'] ?? 0) as num) * ((item['preco_venda'] ?? 0) as num)).toDouble()), style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold))),
                  ],
                ),
              );
            }),
          const Divider(height: 1, color: AppTheme.accentGray),
          _buildPaginationBar(),
        ],
      ),
    );
  }

  // ── Paginação compartilhada ──
  Widget _buildPaginationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          Text(
            _filteredProducts.isEmpty
                ? '0 registros'
                : 'Mostrando ${_currentPage * _pageSize + 1}–${((_currentPage + 1) * _pageSize).clamp(0, _filteredProducts.length)} de ${_filteredProducts.length}',
            style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPaginationBtn(icon: Icons.chevron_left, enabled: _currentPage > 0, onTap: () => setState(() => _currentPage--)),
              const SizedBox(width: 6),
              ...List.generate(_totalPages.clamp(0, 5), (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildPageNumber(i),
              )),
              if (_totalPages > 5) ...[
                const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: AppTheme.textGray))),
                _buildPageNumber(_totalPages - 1),
              ],
              const SizedBox(width: 6),
              _buildPaginationBtn(icon: Icons.chevron_right, enabled: _currentPage < _totalPages - 1, onTap: () => setState(() => _currentPage++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBtn({required IconData icon, required bool enabled, required VoidCallback onTap}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: AppTheme.darkPanel, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.accentGray)),
        child: Icon(icon, color: enabled ? AppTheme.textWhite : AppTheme.accentGray, size: 18),
      ),
    );
  }

  Widget _buildPageNumber(int page) {
    final isActive = page == _currentPage;
    return InkWell(
      onTap: () => setState(() => _currentPage = page),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.teal20 : AppTheme.darkPanel,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? AppTheme.primaryTeal : AppTheme.accentGray),
        ),
        child: Center(child: Text('${page + 1}', style: TextStyle(color: isActive ? AppTheme.primaryTeal : AppTheme.textGray, fontWeight: FontWeight.bold, fontSize: 12))),
      ),
    );
  }

  Widget _buildExecCard(String title, String value, {IconData? icon, Color? iconColor, String? subtitle, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: AppTheme.textGray, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: valueColor ?? AppTheme.primaryTeal)),
                if (icon != null) ...[const SizedBox(width: 8), Icon(icon, color: iconColor)],
              ],
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppTheme.textGray, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

enum _ActionBtnStyle { filled, outlined, dark }

class _TableHeader extends StatelessWidget {
  final String label;
  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 10, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, letterSpacing: 1),
    );
  }
}
