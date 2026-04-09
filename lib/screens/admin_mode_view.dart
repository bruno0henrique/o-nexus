import 'package:flutter/material.dart';
import 'package:nexus_engine/theme/app_theme.dart';
import 'package:nexus_engine/services/admin_service.dart';

class AdminModeView extends StatefulWidget {
  /// ID da loja selecionada no sidebar. Quando fornecido, filtra tabela_nexus
  /// por esse ID. Quando null, carrega tudo.
  final String? storeId;

  const AdminModeView({super.key, this.storeId});

  @override
  State<AdminModeView> createState() => _AdminModeViewState();
}

class _AdminModeViewState extends State<AdminModeView> {
  final AdminService _adminService = AdminService();

  List<Map<String, dynamic>> _auditoria = [];
  bool _isLoading = true;
  String? _error;

  int _totalSkus = 0;
  int _estoqueTotal = 0;
  double _valorTotalEstoque = 0;
  Map<String, int> _porCategoria = {};

  // Mercadinhos (projetos)
  List<Map<String, dynamic>> _mercadinhos = [];
  String? _selectedMercadinhoId;

  // Pesquisa e filtros
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterCategoria;
  String? _filterEstoque; // 'zerado' | 'baixo' | 'normal'

  // Paginação
  int _currentPage = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    // Se o pai já forneceu um storeId, usá-lo diretamente sem buscar a lista.
    if (widget.storeId != null && widget.storeId!.isNotEmpty) {
      _selectedMercadinhoId = widget.storeId;
      _loadData();
    } else {
      _loadMercadinhos();
    }
  }

  @override
  void didUpdateWidget(AdminModeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reagir quando o storeId mudar (usuário trocou de loja no sidebar).
    if (widget.storeId != oldWidget.storeId) {
      // Limpa estado imediatamente para evitar ghosting de dados antigos
      setState(() {
        _selectedMercadinhoId = widget.storeId;
        _auditoria = [];
        _totalSkus = 0;
        _estoqueTotal = 0;
        _valorTotalEstoque = 0;
        _porCategoria = {};
        _isLoading = true;
        _error = null;
        _currentPage = 0;
      });
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMercadinhos() async {
    try {
      final mercadinhos = await _adminService.fetchMercadinhos();
      setState(() {
        _mercadinhos = mercadinhos;
        if (mercadinhos.isNotEmpty && _selectedMercadinhoId == null) {
          _selectedMercadinhoId = '${mercadinhos.first['loja_id']}';
        }
      });
      await _loadData();
    } catch (e) {
      // Se falhar, carrega tudo sem filtro
      await _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _adminService.fetchAuditoria(
        mercadinhoId: _selectedMercadinhoId,
      );
      _auditoria = data;
      _totalSkus = data.length;
      _estoqueTotal = 0;
      _valorTotalEstoque = 0;
      _porCategoria = {};

      for (final item in data) {
        final estoque = (item['estoque_atual'] ?? 0) as num;
        final precoVenda = (item['preco_venda'] ?? 0) as num;
        _estoqueTotal += estoque.toInt();
        _valorTotalEstoque += estoque * precoVenda.toDouble();

        final cat = (item['categoria'] ?? 'Sem categoria') as String;
        _porCategoria[cat] = (_porCategoria[cat] ?? 0) + 1;
      }

      setState(() {
        _isLoading = false;
        _currentPage = 0;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ── Dados filtrados ──
  List<Map<String, dynamic>> get _filteredData {
    return _auditoria.where((item) {
      // Pesquisa
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match =
            '${item['sku_id'] ?? ''}'.toLowerCase().contains(q) ||
            '${item['produto'] ?? ''}'.toLowerCase().contains(q) ||
            '${item['categoria'] ?? ''}'.toLowerCase().contains(q);
        if (!match) return false;
      }
      // Filtro categoria
      if (_filterCategoria != null) {
        if ((item['categoria'] ?? '') != _filterCategoria) return false;
      }
      // Filtro estoque
      if (_filterEstoque != null) {
        final val = ((item['estoque_atual'] ?? 0) as num).toInt();
        if (_filterEstoque == 'zerado' && val > 0) return false;
        if (_filterEstoque == 'baixo' && (val <= 0 || val > 10)) return false;
        if (_filterEstoque == 'normal' && val <= 10) return false;
      }
      return true;
    }).toList();
  }

  List<String> get _allCategories {
    return _auditoria.map((p) => (p['categoria'] ?? 'Sem categoria') as String).toSet().toList()..sort();
  }

  int get _totalPages => (_filteredData.length / _pageSize).ceil().clamp(1, 9999);

  List<Map<String, dynamic>> get _pageData {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredData.length);
    if (start >= _filteredData.length) return [];
    return _filteredData.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryTeal),
            const SizedBox(height: 16),
            Text('Carregando dados${_selectedMercadinhoId != null ? ' do mercadinho...' : '...'}',
              style: const TextStyle(color: AppTheme.textGray, fontSize: 13)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.criticalRed, size: 48),
              const SizedBox(height: 16),
              const Text('Erro ao carregar dados', style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        final padding = isWide ? 32.0 : 16.0;

        return RefreshIndicator(
          onRefresh: _loadData,
          color: AppTheme.primaryTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header + Seletor de Mercadinho ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Central de Processamento',
                            style: TextStyle(fontSize: isWide ? 28 : 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                          const SizedBox(height: 4),
                          const Text('Dados sincronizados do Supabase',
                            style: TextStyle(fontSize: 13, color: AppTheme.textGray)),
                        ],
                      ),
                    ),
                    // Seletor de mercadinho
                    if (_mercadinhos.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.darkPanel,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMercadinhoId,
                            dropdownColor: AppTheme.darkPanel,
                            icon: const Icon(Icons.swap_horiz, color: AppTheme.primaryTeal, size: 18),
                            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                            items: _mercadinhos.map((m) {
                              final id = '${m['loja_id']}';
                              final nome = m['nome'] ?? 'Loja $id';
                              return DropdownMenuItem(
                                value: id,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.storefront, color: AppTheme.primaryTeal, size: 14),
                                    const SizedBox(width: 8),
                                    Text('$nome'),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedMercadinhoId = v);
                                _loadData();
                              }
                            },
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal),
                      tooltip: 'Atualizar dados',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Métricas ──
                _buildMetricsGrid(isWide),
                const SizedBox(height: 24),

                // ── Pesquisa e Filtros ──
                _buildSearchAndFilters(),
                const SizedBox(height: 16),

                // ── Conteúdo principal ──
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildDataTable()),
                      const SizedBox(width: 20),
                      SizedBox(width: 240, child: _buildCategoriaResumo()),
                    ],
                  )
                else ...[
                  _buildCategoriaResumo(),
                  const SizedBox(height: 16),
                  _buildDataTable(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ================================================================
  // PESQUISA + FILTROS
  // ================================================================
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Campo de pesquisa
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Pesquisar por SKU, produto ou categoria...',
              hintStyle: const TextStyle(color: AppTheme.textGray, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryTeal, size: 20),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 980;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.teal10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.filter_list, color: AppTheme.primaryTeal, size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Filtrar por:',
                            style: TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      _buildFilterDropdown(
                        label: 'Categoria',
                        allLabel: 'Todas as categorias',
                        value: _filterCategoria,
                        items: _allCategories,
                        onChanged: (v) => setState(() {
                          _filterCategoria = v;
                          _currentPage = 0;
                        }),
                      ),
                      _buildFilterDropdown(
                        label: 'Nível de Estoque',
                        allLabel: 'Todos os níveis',
                        value: _filterEstoque,
                        items: const ['zerado', 'baixo', 'normal'],
                        displayMap: const {
                          'zerado': 'Sem estoque (0)',
                          'baixo': 'Estoque baixo (1-10)',
                          'normal': 'Estoque normal (>10)',
                        },
                        onChanged: (v) => setState(() {
                          _filterEstoque = v;
                          _currentPage = 0;
                        }),
                      ),
                      if (_filterCategoria != null || _filterEstoque != null || _searchQuery.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _filterCategoria = null;
                              _filterEstoque = null;
                              _searchQuery = '';
                              _currentPage = 0;
                            });
                          },
                          icon: const Icon(Icons.clear_all, size: 16, color: AppTheme.primaryTeal),
                          label: const Text('Limpar tudo', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: isCompact ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.teal10, borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '${_filteredData.length} de $_totalSkus registros',
                        style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    Map<String, String>? displayMap,
    String? allLabel,
    required ValueChanged<String?> onChanged,
  }) {
    final defaultLabel = allLabel ?? 'Todos';

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: value != null ? AppTheme.primaryTeal : AppTheme.accentGray),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            label,
            style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          dropdownColor: AppTheme.darkPanel,
          style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryTeal, size: 18),
          selectedItemBuilder: (context) => [
            Text(
              defaultLabel,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
            ),
            ...items.map(
              (item) => Text(
                displayMap?[item] ?? item,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
              ),
            ),
          ],
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(
                defaultLabel,
                style: const TextStyle(color: AppTheme.textGray),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  displayMap?[item] ?? item,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(bool isWide) {
    final metrics = [
      _buildMetricCard('TOTAL SKUs', '$_totalSkus', 'registros', Icons.inventory_2_outlined),
      _buildMetricCard('ESTOQUE TOTAL', '$_estoqueTotal', 'un.', Icons.warehouse_outlined),
      _buildMetricCard('VALOR ESTOQUE', 'R\$ ${_valorTotalEstoque.toStringAsFixed(0)}', '', Icons.attach_money, isHighlight: true),
      _buildMetricCard('CATEGORIAS', '${_porCategoria.length}', 'tipos', Icons.category_outlined),
    ];

    if (isWide) {
      return Row(
        children: [
          for (int i = 0; i < metrics.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: metrics[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        Row(children: [Expanded(child: metrics[0]), const SizedBox(width: 12), Expanded(child: metrics[1])]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: metrics[2]), const SizedBox(width: 12), Expanded(child: metrics[3])]),
      ],
    );
  }

  Widget _buildDataTable() {
    final data = _pageData;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGray),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3, height: 20,
                      decoration: BoxDecoration(color: AppTheme.primaryTeal, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 10),
                    const Text('Base de Auditoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.teal10, borderRadius: BorderRadius.circular(12)),
                  child: Text('${_filteredData.length} itens', style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.accentGray, height: 1),

          if (_filteredData.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('Nenhum dado encontrado com os filtros atuais', style: TextStyle(color: AppTheme.textGray))),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 900),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: AppTheme.darkPanel,
                      child: const Row(
                        children: [
                          SizedBox(width: 200, child: Text('PRODUTO', style: _headerStyle)),
                          SizedBox(width: 80, child: Text('ESTOQUE', style: _headerStyle)),
                          SizedBox(width: 80, child: Text('GIRO 30D', style: _headerStyle)),
                          SizedBox(width: 90, child: Text('CUSTO', style: _headerStyle)),
                          SizedBox(width: 90, child: Text('VENDA', style: _headerStyle)),
                          SizedBox(width: 110, child: Text('VENCIMENTO', style: _headerStyle)),
                          SizedBox(width: 130, child: Text('CATEGORIA', style: _headerStyle)),
                          SizedBox(width: 90, child: Text('SKU', style: _headerStyle)),
                        ],
                      ),
                    ),
                    // Rows
                    ...data.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: i.isOdd ? AppTheme.darkPanel.withValues(alpha: 0.3) : Colors.transparent,
                        child: Row(
                          children: [
                            SizedBox(width: 200, child: Text('${item['produto'] ?? '-'}', style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 12), overflow: TextOverflow.ellipsis)),
                            SizedBox(width: 80, child: _buildEstoqueCell(item['estoque_atual'])),
                            SizedBox(width: 80, child: Text('${item['giro_30d'] ?? '-'}', style: const TextStyle(color: AppTheme.textGray, fontSize: 12))),
                            SizedBox(width: 90, child: Text('R\$ ${_formatNum(item['preco_custo'])}', style: const TextStyle(color: AppTheme.textGray, fontSize: 12))),
                            SizedBox(width: 90, child: Text('R\$ ${_formatNum(item['preco_venda'])}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 12))),
                            SizedBox(width: 110, child: Text('${item['data_vencimento'] ?? '-'}', style: const TextStyle(color: AppTheme.textGray, fontSize: 12))),
                            SizedBox(width: 130, child: Align(alignment: Alignment.centerLeft, child: _buildCategoryChip('${item['categoria'] ?? '-'}'))),
                            SizedBox(width: 90, child: Text('${item['sku_id'] ?? '-'}', style: const TextStyle(color: AppTheme.textGray, fontSize: 11, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // ── Paginação ──
          const Divider(color: AppTheme.accentGray, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _filteredData.isEmpty
                      ? '0 registros'
                      : 'Mostrando ${_currentPage * _pageSize + 1}–${((_currentPage + 1) * _pageSize).clamp(0, _filteredData.length)} de ${_filteredData.length}',
                  style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
                ),
                Row(
                  children: [
                    _buildPaginationBtn(icon: Icons.chevron_left, enabled: _currentPage > 0, onTap: () => setState(() => _currentPage--)),
                    const SizedBox(width: 6),
                    ...List.generate(_totalPages.clamp(0, 7), (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildPageNumber(i),
                    )),
                    if (_totalPages > 7) ...[
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('...', style: TextStyle(color: AppTheme.textGray))),
                      _buildPageNumber(_totalPages - 1),
                    ],
                    const SizedBox(width: 6),
                    _buildPaginationBtn(icon: Icons.chevron_right, enabled: _currentPage < _totalPages - 1, onTap: () => setState(() => _currentPage++)),
                  ],
                ),
              ],
            ),
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
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: AppTheme.darkPanel,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.accentGray),
        ),
        child: Icon(icon, color: enabled ? AppTheme.primaryTeal : AppTheme.accentGray, size: 16),
      ),
    );
  }

  Widget _buildPageNumber(int page) {
    final isActive = page == _currentPage;
    return InkWell(
      onTap: () => setState(() => _currentPage = page),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.teal20 : AppTheme.darkPanel,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? AppTheme.primaryTeal : AppTheme.accentGray),
        ),
        child: Center(child: Text('${page + 1}', style: TextStyle(color: isActive ? AppTheme.primaryTeal : AppTheme.textGray, fontWeight: FontWeight.bold, fontSize: 11))),
      ),
    );
  }

  static const _headerStyle = TextStyle(fontSize: 10, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, letterSpacing: 1);

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AppTheme.teal10, borderRadius: BorderRadius.circular(4)),
      child: Text(
        category,
        style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 10),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEstoqueCell(dynamic estoque) {
    final val = (estoque ?? 0) as num;
    Color color;
    if (val <= 0) {
      color = AppTheme.criticalRed;
    } else if (val < 10) {
      color = AppTheme.warningOrange;
    } else {
      color = AppTheme.textWhite;
    }
    return Text('$val', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold));
  }

  Widget _buildCategoriaResumo() {
    final sortedCategories = _porCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 16, decoration: BoxDecoration(color: AppTheme.primaryTeal, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              const Text('Por Categoria', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            ],
          ),
          const SizedBox(height: 16),
          if (sortedCategories.isEmpty)
            const Text('Sem dados', style: TextStyle(color: AppTheme.textGray))
          else
            ...sortedCategories.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(entry.key, style: const TextStyle(color: AppTheme.textWhite, fontSize: 12), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Text('${entry.value}', style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _totalSkus > 0 ? entry.value / _totalSkus : 0,
                      backgroundColor: AppTheme.accentGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            )),
          const SizedBox(height: 8),
          // Mercadinho ID ativo
          if (_selectedMercadinhoId != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.darkPanel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: AppTheme.primaryTeal, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text('ID: $_selectedMercadinhoId', style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontFamily: 'monospace'))),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.teal10, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.cloud_done, color: AppTheme.primaryTeal, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Supabase conectado', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String suffix, IconData icon, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isHighlight ? AppTheme.primaryTeal.withValues(alpha: 0.3) : AppTheme.accentGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryTeal, size: 14),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 9, color: AppTheme.textGray, letterSpacing: 1, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isHighlight ? AppTheme.primaryTeal : AppTheme.textWhite)),
                if (suffix.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(suffix, style: const TextStyle(color: AppTheme.textGray, fontSize: 11)),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNum(dynamic value) {
    if (value == null) return '0.00';
    final num n = value is num ? value : 0;
    return n.toStringAsFixed(2);
  }
}
