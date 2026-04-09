import 'package:flutter/material.dart';
import 'package:nexus_engine/services/admin_service.dart';
import 'package:nexus_engine/theme/app_theme.dart';

const _headerStyle = TextStyle(
  fontSize: 10,
  color: AppTheme.primaryTeal,
  fontWeight: FontWeight.bold,
  letterSpacing: 1,
);

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _mercadinhos = [];
  String? _selectedMercadinhoId;

  // Métricas calculadas
  double _valorEstoque = 0;
  double _custoTotal = 0;
  double _margemMedia = 0;
  int _totalSkus = 0;

  // Breakdown por categoria
  Map<String, double> _receitaPorCategoria = {};

  // Top produtos por valor
  List<Map<String, dynamic>> _topProdutos = [];

  // Vencimentos próximos (30 dias)
  List<Map<String, dynamic>> _vencimentos = [];

  @override
  void initState() {
    super.initState();
    _loadMercadinhos();
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
    } catch (_) {}
    await _loadData();
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

      double valorEstoque = 0;
      double custoTotal = 0;
      double margemSum = 0;
      int margemCount = 0;
      final catReceita = <String, double>{};

      for (final item in data) {
        final estoque = (item['estoque_atual'] ?? 0) as num;
        final venda = (item['preco_venda'] ?? 0) as num;
        final custo = (item['preco_custo'] ?? 0) as num;

        valorEstoque += estoque * venda.toDouble();
        custoTotal += estoque * custo.toDouble();

        if (venda > 0 && custo > 0) {
          margemSum += (venda - custo) / venda * 100;
          margemCount++;
        }

        final cat = (item['categoria'] ?? 'Outros') as String;
        catReceita[cat] = (catReceita[cat] ?? 0) + estoque * venda.toDouble();
      }

      // Top 5 por valor em estoque
      final sorted = List<Map<String, dynamic>>.from(data)
        ..sort((a, b) {
          final av = ((a['estoque_atual'] ?? 0) as num) * ((a['preco_venda'] ?? 0) as num);
          final bv = ((b['estoque_atual'] ?? 0) as num) * ((b['preco_venda'] ?? 0) as num);
          return bv.compareTo(av);
        });

      // Vencimentos nos próximos 30 dias
      final hoje = DateTime.now();
      final vencimentos = <Map<String, dynamic>>[];
      for (final item in data) {
        final venc = item['data_vencimento'];
        if (venc != null && '$venc'.isNotEmpty && '$venc' != '-' && '$venc' != 'null') {
          try {
            final dt = DateTime.parse('$venc');
            final diff = dt.difference(hoje).inDays;
            if (diff <= 30) {
              vencimentos.add({...item, '_diasRestantes': diff});
            }
          } catch (_) {}
        }
      }
      vencimentos.sort((a, b) => (a['_diasRestantes'] as int).compareTo(b['_diasRestantes'] as int));

      setState(() {
        _valorEstoque = valorEstoque;
        _custoTotal = custoTotal;
        _margemMedia = margemCount > 0 ? margemSum / margemCount : 0;
        _totalSkus = data.length;
        final sortedCat = catReceita.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        _receitaPorCategoria = Map.fromEntries(sortedCat);
        _topProdutos = sorted.take(5).toList();
        _vencimentos = vencimentos.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  String _formatMoney(double v) {
    if (v >= 1000000) return 'R\$ ${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return 'R\$ ${(v / 1000).toStringAsFixed(1)}K';
    return 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.criticalRed, size: 48),
              const SizedBox(height: 16),
              const Text('Erro ao carregar dados', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppTheme.textGray, fontSize: 12), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, foregroundColor: AppTheme.background),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final padding = isMobile ? 16.0 : 32.0;

        return RefreshIndicator(
          onRefresh: _loadData,
          color: AppTheme.primaryTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile),
                SizedBox(height: isMobile ? 20 : 32),
                _buildMetricsGrid(isMobile),
                SizedBox(height: isMobile ? 20 : 28),
                if (isMobile) ...[
                  _buildCategoryBreakdown(),
                  const SizedBox(height: 16),
                  _buildTopProdutos(),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildCategoryBreakdown()),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: _buildTopProdutos()),
                    ],
                  ),
                SizedBox(height: isMobile ? 20 : 28),
                _buildVencimentos(isMobile),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ──
  Widget _buildHeader(bool isMobile) {
    final mercadinhoSelector = _mercadinhos.isNotEmpty
        ? Container(
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
          )
        : const SizedBox.shrink();

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('VISÃO EXECUTIVA', style: TextStyle(fontSize: 10, color: AppTheme.primaryTeal, letterSpacing: 4, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Inteligência Financeira', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textWhite)),
          const SizedBox(height: 12),
          mercadinhoSelector,
          const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: _loadData,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.darkPanel, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.accentGray)),
                  child: const Icon(Icons.refresh, color: AppTheme.primaryTeal, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Dados ao vivo · Supabase', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('VISÃO EXECUTIVA', style: TextStyle(fontSize: 10, color: AppTheme.primaryTeal, letterSpacing: 4, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Inteligência Financeira', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.textWhite, letterSpacing: -0.5)),
          ],
        ),
        Row(
          children: [
            mercadinhoSelector,
            const SizedBox(width: 12),
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, color: AppTheme.primaryTeal),
              tooltip: 'Atualizar',
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textWhite,
                side: const BorderSide(color: AppTheme.accentGray),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('EXPORTAR CSV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  // ── Grid de métricas ──
  Widget _buildMetricsGrid(bool isMobile) {
    final lucro = _valorEstoque - _custoTotal;
    final cards = [
      _buildMetricCard(
        label: 'VALOR EM ESTOQUE',
        value: _formatMoney(_valorEstoque),
        icon: Icons.payments_outlined,
        iconColor: AppTheme.primaryTeal,
        accentColor: AppTheme.primaryTeal,
        sub: '$_totalSkus SKUs ativos',
      ),
      _buildMetricCard(
        label: 'MARGEM MÉDIA',
        value: '${_margemMedia.toStringAsFixed(1)}%',
        icon: Icons.trending_up,
        iconColor: const Color(0xFF98D0DA),
        accentColor: const Color(0xFF98D0DA),
        sub: 'Preço de venda vs. custo',
      ),
      _buildMetricCard(
        label: 'CUSTO DO ESTOQUE',
        value: _formatMoney(_custoTotal),
        icon: Icons.account_balance_wallet_outlined,
        iconColor: AppTheme.criticalRed,
        accentColor: AppTheme.criticalRed,
        sub: 'Total de aquisição',
      ),
      _buildMetricCard(
        label: 'LUCRO BRUTO POTENCIAL',
        value: _formatMoney(lucro),
        icon: Icons.show_chart,
        iconColor: const Color(0xFFF3BF26),
        accentColor: const Color(0xFFF3BF26),
        sub: 'Receita − Custo',
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(children: [Expanded(child: cards[0]), const SizedBox(width: 12), Expanded(child: cards[1])]),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: cards[2]), const SizedBox(width: 12), Expanded(child: cards[3])]),
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color accentColor,
    String? sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textGray, letterSpacing: 1.5, fontWeight: FontWeight.bold))),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: accentColor)),
          ),
          if (sub != null) ...[
            const SizedBox(height: 6),
            Text(sub, style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
          ],
        ],
      ),
    );
  }

  // ── Receita por Categoria ──
  Widget _buildCategoryBreakdown() {
    final maxVal = _receitaPorCategoria.isEmpty ? 1.0 : _receitaPorCategoria.values.reduce((a, b) => a > b ? a : b);
    final entries = _receitaPorCategoria.entries.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.donut_small_outlined, color: AppTheme.primaryTeal, size: 18),
            SizedBox(width: 8),
            Text('Valor por Categoria', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 4),
          const Text('Valor de estoque agrupado por categoria', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Sem dados disponíveis', style: TextStyle(color: AppTheme.textGray)),
            ))
          else
            ...entries.map((e) {
              final pct = e.value / maxVal;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(e.key, style: const TextStyle(color: AppTheme.textWhite, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Text(_formatMoney(e.value), style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppTheme.accentGray,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Top 5 Produtos ──
  Widget _buildTopProdutos() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.emoji_events_outlined, color: AppTheme.primaryTeal, size: 18),
            SizedBox(width: 8),
            Text('Top 5 por Valor', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 4),
          const Text('Produtos com maior valor em estoque', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
          const SizedBox(height: 16),
          if (_topProdutos.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Sem dados disponíveis', style: TextStyle(color: AppTheme.textGray)),
            ))
          else
            ..._topProdutos.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final estoque = (item['estoque_atual'] ?? 0) as num;
              final venda = (item['preco_venda'] ?? 0) as num;
              final total = estoque * venda.toDouble();
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.darkPanel, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(color: AppTheme.teal10, borderRadius: BorderRadius.circular(4)),
                      child: Center(child: Text('${i + 1}', style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item['produto'] ?? '-'}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                        Text('Estoque: ${estoque.toInt()} un', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
                      ],
                    )),
                    Text(_formatMoney(total), style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Trilha de Vencimentos ──
  Widget _buildVencimentos(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(children: const [
                  Icon(Icons.receipt_long_outlined, color: AppTheme.primaryTeal, size: 18),
                  SizedBox(width: 8),
                  Flexible(child: Text('Trilha de Auditoria — Vencimentos', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.darkPanel, borderRadius: BorderRadius.circular(4)),
                child: const Text('AO VIVO', style: TextStyle(fontSize: 9, color: AppTheme.primaryTeal, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Produtos com vencimento nos próximos 30 dias', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
          const SizedBox(height: 16),
          if (_vencimentos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.darkPanel, shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle_outline, color: AppTheme.primaryTeal, size: 28),
                    ),
                    const SizedBox(height: 12),
                    const Text('Nenhum vencimento crítico', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Todos os produtos estão com prazo seguro.', style: TextStyle(color: AppTheme.textGray, fontSize: 12)),
                  ],
                ),
              ),
            )
          else ...[
            if (!isMobile)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.darkPanel, borderRadius: BorderRadius.circular(6)),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('PRODUTO', style: _headerStyle)),
                    Expanded(flex: 2, child: Text('CATEGORIA', style: _headerStyle)),
                    Expanded(flex: 1, child: Text('ESTOQUE', style: _headerStyle)),
                    Expanded(flex: 2, child: Text('VENCIMENTO', style: _headerStyle)),
                    Expanded(flex: 1, child: Text('DIAS', style: _headerStyle)),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            ..._vencimentos.map((item) {
              final dias = item['_diasRestantes'] as int;
              final badgeColor = dias <= 0
                  ? AppTheme.criticalRed
                  : dias <= 7
                      ? AppTheme.warningOrange
                      : const Color(0xFFF3BF26);
              final label = dias <= 0 ? 'VENCIDO' : '$dias d';

              if (isMobile) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkPanel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border(left: BorderSide(color: badgeColor, width: 3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item['produto'] ?? '-'}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('${item['categoria'] ?? ''} • Estoque: ${item['estoque_atual'] ?? 0}', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
                            Text('Vence: ${item['data_vencimento'] ?? '-'}', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                        child: Text(label, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF222222), width: 0.5))),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('${item['produto'] ?? '-'}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 2, child: Text('${item['categoria'] ?? '-'}', style: const TextStyle(color: AppTheme.textGray, fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 1, child: Text('${item['estoque_atual'] ?? 0}', style: const TextStyle(color: AppTheme.textGray, fontSize: 12))),
                    Expanded(flex: 2, child: Text('${item['data_vencimento'] ?? '-'}', style: const TextStyle(color: AppTheme.textGray, fontSize: 12))),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                        child: Text(label, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
