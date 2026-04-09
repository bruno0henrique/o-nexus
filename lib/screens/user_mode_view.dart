import 'package:flutter/material.dart';
import 'package:nexus_engine/theme/app_theme.dart';

// ============================================================
// Dados estáticos de demonstração
// ============================================================
final List<Map<String, dynamic>> _demoProducts = [
  {'produto': 'Vinho Tinto Reserva', 'sku': '8826-VT', 'categoria': 'Bebidas Alcoólicas', 'estoque': 25, 'estoqueMax': 100, 'preco': 89.90, 'valorTotal': 2247.50},
  {'produto': 'Cerveja Lata 350ml', 'sku': '1014-CL', 'categoria': 'Bebidas', 'estoque': 8, 'estoqueMax': 100, 'preco': 4.50, 'valorTotal': 360.00},
  {'produto': 'Iogurte Grego Natural', 'sku': '5821-IG', 'categoria': 'Laticínios', 'estoque': 85, 'estoqueMax': 100, 'preco': 3.20, 'valorTotal': 1280.00},
  {'produto': 'Arroz Integral 1kg', 'sku': '2290-AI', 'categoria': 'Grãos', 'estoque': 60, 'estoqueMax': 100, 'preco': 7.90, 'valorTotal': 948.00},
  {'produto': 'Detergente Líquido', 'sku': '9931-DL', 'categoria': 'Limpeza', 'estoque': 45, 'estoqueMax': 100, 'preco': 2.50, 'valorTotal': 562.50},
  {'produto': 'Chocolate Amargo 70%', 'sku': '4412-CA', 'categoria': 'Confeitaria', 'estoque': 100, 'estoqueMax': 100, 'preco': 12.90, 'valorTotal': 2580.00},
  {'produto': 'Leite Integral 1L', 'sku': '1100-LI', 'categoria': 'Laticínios', 'estoque': 72, 'estoqueMax': 100, 'preco': 5.99, 'valorTotal': 431.28},
  {'produto': 'Café Torrado 500g', 'sku': '3301-CT', 'categoria': 'Bebidas', 'estoque': 38, 'estoqueMax': 100, 'preco': 22.50, 'valorTotal': 855.00},
  {'produto': 'Sabão em Pó 1kg', 'sku': '9900-SP', 'categoria': 'Limpeza', 'estoque': 55, 'estoqueMax': 100, 'preco': 9.90, 'valorTotal': 544.50},
  {'produto': 'Macarrão Espaguete', 'sku': '2201-ME', 'categoria': 'Grãos', 'estoque': 90, 'estoqueMax': 100, 'preco': 4.80, 'valorTotal': 432.00},
  {'produto': 'Azeite Extra Virgem', 'sku': '3350-AV', 'categoria': 'Mercearia', 'estoque': 20, 'estoqueMax': 100, 'preco': 35.00, 'valorTotal': 700.00},
  {'produto': 'Queijo Mussarela', 'sku': '5800-QM', 'categoria': 'Laticínios', 'estoque': 42, 'estoqueMax': 100, 'preco': 29.90, 'valorTotal': 1255.80},
  {'produto': 'Refrigerante 2L', 'sku': '1050-RF', 'categoria': 'Bebidas', 'estoque': 65, 'estoqueMax': 100, 'preco': 8.50, 'valorTotal': 552.50},
  {'produto': 'Papel Higiênico 12un', 'sku': '9800-PH', 'categoria': 'Limpeza', 'estoque': 30, 'estoqueMax': 100, 'preco': 18.90, 'valorTotal': 567.00},
  {'produto': 'Biscoito Recheado', 'sku': '4450-BR', 'categoria': 'Confeitaria', 'estoque': 78, 'estoqueMax': 100, 'preco': 3.50, 'valorTotal': 273.00},
  {'produto': 'Óleo de Soja 900ml', 'sku': '3370-OS', 'categoria': 'Mercearia', 'estoque': 50, 'estoqueMax': 100, 'preco': 7.20, 'valorTotal': 360.00},
  {'produto': 'Manteiga 200g', 'sku': '5830-MT', 'categoria': 'Laticínios', 'estoque': 15, 'estoqueMax': 100, 'preco': 11.50, 'valorTotal': 172.50},
  {'produto': 'Água Mineral 1.5L', 'sku': '1070-AM', 'categoria': 'Bebidas', 'estoque': 95, 'estoqueMax': 100, 'preco': 2.90, 'valorTotal': 275.50},
  {'produto': 'Desinfetante 2L', 'sku': '9950-DF', 'categoria': 'Limpeza', 'estoque': 33, 'estoqueMax': 100, 'preco': 6.80, 'valorTotal': 224.40},
  {'produto': 'Feijão Preto 1kg', 'sku': '2210-FP', 'categoria': 'Grãos', 'estoque': 48, 'estoqueMax': 100, 'preco': 8.90, 'valorTotal': 427.20},
  {'produto': 'Suco de Laranja 1L', 'sku': '1090-SL', 'categoria': 'Bebidas', 'estoque': 58, 'estoqueMax': 100, 'preco': 6.50, 'valorTotal': 377.00},
  {'produto': 'Farinha de Trigo 1kg', 'sku': '2250-FT', 'categoria': 'Grãos', 'estoque': 70, 'estoqueMax': 100, 'preco': 5.20, 'valorTotal': 364.00},
  {'produto': 'Creme de Leite', 'sku': '5850-CL', 'categoria': 'Laticínios', 'estoque': 40, 'estoqueMax': 100, 'preco': 4.90, 'valorTotal': 196.00},
  {'produto': 'Açúcar Cristal 1kg', 'sku': '3390-AC', 'categoria': 'Mercearia', 'estoque': 82, 'estoqueMax': 100, 'preco': 4.50, 'valorTotal': 369.00},
  {'produto': 'Sardinha em Lata', 'sku': '3400-SL', 'categoria': 'Mercearia', 'estoque': 27, 'estoqueMax': 100, 'preco': 7.80, 'valorTotal': 210.60},
  {'produto': 'Sabonete Líquido', 'sku': '9970-SB', 'categoria': 'Limpeza', 'estoque': 62, 'estoqueMax': 100, 'preco': 8.90, 'valorTotal': 551.80},
  {'produto': 'Bolo Pronto', 'sku': '4470-BP', 'categoria': 'Confeitaria', 'estoque': 12, 'estoqueMax': 100, 'preco': 15.00, 'valorTotal': 180.00},
  {'produto': 'Milho Verde Lata', 'sku': '3420-MV', 'categoria': 'Mercearia', 'estoque': 44, 'estoqueMax': 100, 'preco': 4.20, 'valorTotal': 184.80},
  {'produto': 'Presunto Fatiado', 'sku': '5870-PF', 'categoria': 'Laticínios', 'estoque': 18, 'estoqueMax': 100, 'preco': 16.90, 'valorTotal': 304.20},
  {'produto': 'Energético 250ml', 'sku': '1110-EN', 'categoria': 'Bebidas', 'estoque': 52, 'estoqueMax': 100, 'preco': 9.90, 'valorTotal': 514.80},
  {'produto': 'Molho de Tomate', 'sku': '3440-MT', 'categoria': 'Mercearia', 'estoque': 67, 'estoqueMax': 100, 'preco': 3.90, 'valorTotal': 261.30},
  {'produto': 'Achocolatado 400g', 'sku': '4490-AC', 'categoria': 'Confeitaria', 'estoque': 35, 'estoqueMax': 100, 'preco': 6.50, 'valorTotal': 227.50},
  {'produto': 'Ervilha em Lata', 'sku': '3460-EL', 'categoria': 'Mercearia', 'estoque': 39, 'estoqueMax': 100, 'preco': 4.10, 'valorTotal': 159.90},
  {'produto': 'Iogurte de Morango', 'sku': '5890-IM', 'categoria': 'Laticínios', 'estoque': 56, 'estoqueMax': 100, 'preco': 2.80, 'valorTotal': 156.80},
  {'produto': 'Chá Mate 1.5L', 'sku': '1130-CM', 'categoria': 'Bebidas', 'estoque': 43, 'estoqueMax': 100, 'preco': 5.50, 'valorTotal': 236.50},
  {'produto': 'Esponja de Aço', 'sku': '9990-EA', 'categoria': 'Limpeza', 'estoque': 88, 'estoqueMax': 100, 'preco': 2.20, 'valorTotal': 193.60},
  {'produto': 'Lentilha 500g', 'sku': '2270-LT', 'categoria': 'Grãos', 'estoque': 22, 'estoqueMax': 100, 'preco': 9.50, 'valorTotal': 209.00},
  {'produto': 'Requeijão Cremoso', 'sku': '5910-RC', 'categoria': 'Laticínios', 'estoque': 31, 'estoqueMax': 100, 'preco': 8.70, 'valorTotal': 269.70},
  {'produto': 'Cerveja Long Neck', 'sku': '1015-CN', 'categoria': 'Bebidas Alcoólicas', 'estoque': 76, 'estoqueMax': 100, 'preco': 6.90, 'valorTotal': 524.40},
  {'produto': 'Amaciante 2L', 'sku': '9910-AM', 'categoria': 'Limpeza', 'estoque': 29, 'estoqueMax': 100, 'preco': 11.90, 'valorTotal': 345.10},
  {'produto': 'Gelatina em Pó', 'sku': '4510-GP', 'categoria': 'Confeitaria', 'estoque': 91, 'estoqueMax': 100, 'preco': 1.90, 'valorTotal': 172.90},
  {'produto': 'Sal Refinado 1kg', 'sku': '3480-SR', 'categoria': 'Mercearia', 'estoque': 80, 'estoqueMax': 100, 'preco': 2.50, 'valorTotal': 200.00},
  {'produto': 'Vinagre 750ml', 'sku': '3500-VG', 'categoria': 'Mercearia', 'estoque': 54, 'estoqueMax': 100, 'preco': 3.80, 'valorTotal': 205.20},
  {'produto': 'Cream Cheese', 'sku': '5930-CC', 'categoria': 'Laticínios', 'estoque': 19, 'estoqueMax': 100, 'preco': 12.90, 'valorTotal': 245.10},
  {'produto': 'Vodka 1L', 'sku': '8840-VK', 'categoria': 'Bebidas Alcoólicas', 'estoque': 14, 'estoqueMax': 100, 'preco': 42.00, 'valorTotal': 588.00},
  {'produto': 'Limpa Vidros 500ml', 'sku': '9920-LV', 'categoria': 'Limpeza', 'estoque': 47, 'estoqueMax': 100, 'preco': 7.50, 'valorTotal': 352.50},
  {'produto': 'Aveia em Flocos', 'sku': '2290-AF', 'categoria': 'Grãos', 'estoque': 63, 'estoqueMax': 100, 'preco': 6.80, 'valorTotal': 428.40},
  {'produto': 'Doce de Leite', 'sku': '4530-DL', 'categoria': 'Confeitaria', 'estoque': 37, 'estoqueMax': 100, 'preco': 9.90, 'valorTotal': 366.30},
  {'produto': 'Whisky 750ml', 'sku': '8860-WK', 'categoria': 'Bebidas Alcoólicas', 'estoque': 7, 'estoqueMax': 100, 'preco': 89.90, 'valorTotal': 629.30},
  {'produto': 'Catchup 400g', 'sku': '3520-CT', 'categoria': 'Mercearia', 'estoque': 71, 'estoqueMax': 100, 'preco': 5.90, 'valorTotal': 418.90},
  {'produto': 'Leite Condensado', 'sku': '4550-LC', 'categoria': 'Confeitaria', 'estoque': 46, 'estoqueMax': 100, 'preco': 6.20, 'valorTotal': 285.20},
  {'produto': 'Maionese 500g', 'sku': '3540-MN', 'categoria': 'Mercearia', 'estoque': 59, 'estoqueMax': 100, 'preco': 7.50, 'valorTotal': 442.50},
  {'produto': 'Grão de Bico 500g', 'sku': '2310-GB', 'categoria': 'Grãos', 'estoque': 26, 'estoqueMax': 100, 'preco': 8.40, 'valorTotal': 218.40},
  {'produto': 'Chocolate ao Leite', 'sku': '4570-CL', 'categoria': 'Confeitaria', 'estoque': 83, 'estoqueMax': 100, 'preco': 7.90, 'valorTotal': 655.70},
  {'produto': 'Cerveja Puro Malte', 'sku': '8880-PM', 'categoria': 'Bebidas Alcoólicas', 'estoque': 34, 'estoqueMax': 100, 'preco': 5.90, 'valorTotal': 200.60},
  {'produto': 'Álcool Gel 500ml', 'sku': '9940-AG', 'categoria': 'Limpeza', 'estoque': 68, 'estoqueMax': 100, 'preco': 8.90, 'valorTotal': 605.20},
  {'produto': 'Granola 800g', 'sku': '2330-GR', 'categoria': 'Grãos', 'estoque': 41, 'estoqueMax': 100, 'preco': 14.90, 'valorTotal': 610.90},
  {'produto': 'Sorvete 2L', 'sku': '4590-SV', 'categoria': 'Confeitaria', 'estoque': 11, 'estoqueMax': 100, 'preco': 19.90, 'valorTotal': 218.90},
  {'produto': 'Suco de Uva 1L', 'sku': '1150-SU', 'categoria': 'Bebidas', 'estoque': 53, 'estoqueMax': 100, 'preco': 7.90, 'valorTotal': 418.70},
  {'produto': 'Toalha de Papel', 'sku': '9960-TP', 'categoria': 'Limpeza', 'estoque': 75, 'estoqueMax': 100, 'preco': 5.50, 'valorTotal': 412.50},
];

class UserModeView extends StatefulWidget {
  const UserModeView({super.key});

  @override
  State<UserModeView> createState() => _UserModeViewState();
}

class _UserModeViewState extends State<UserModeView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterCategoria;
  String? _filterEstoqueRange;

  int _currentPage = 0;
  static const int _pageSize = 50;

  List<Map<String, dynamic>> get _filteredProducts {
    return _demoProducts.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = (p['produto'] as String).toLowerCase().contains(q) ||
            (p['sku'] as String).toLowerCase().contains(q) ||
            (p['categoria'] as String).toLowerCase().contains(q);
        if (!match) return false;
      }
      if (_filterCategoria != null && _filterCategoria!.isNotEmpty) {
        if (p['categoria'] != _filterCategoria) return false;
      }
      if (_filterEstoqueRange != null) {
        final pct = ((p['estoque'] as int) / (p['estoqueMax'] as int) * 100).round();
        if (_filterEstoqueRange == 'baixo' && pct > 25) return false;
        if (_filterEstoqueRange == 'medio' && (pct <= 25 || pct > 70)) return false;
        if (_filterEstoqueRange == 'alto' && pct <= 70) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final pctA = (a['estoque'] as int) / (a['estoqueMax'] as int);
        final pctB = (b['estoque'] as int) / (b['estoqueMax'] as int);
        return pctA.compareTo(pctB);
      });
  }

  List<String> get _allCategories {
    return _demoProducts.map((p) => p['categoria'] as String).toSet().toList()..sort();
  }

  int get _totalPages => (_filteredProducts.length / _pageSize).ceil().clamp(1, 999);

  List<Map<String, dynamic>> get _pageProducts {
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredProducts.length);
    if (start >= _filteredProducts.length) return [];
    return _filteredProducts.sublist(start, end);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Visão de Capital ──
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
                Expanded(child: _buildExecCard('DESPERDÍCIO EVITADO (MÊS)', 'R\$ 1.300,00', icon: Icons.arrow_upward, iconColor: AppTheme.primaryTeal)),
                SizedBox(width: isMobile ? 12 : 24),
                Expanded(child: _buildExecCard('CAPITAL TRAVADO NO ESTOQUE', 'R\$ 4.500,00', subtitle: 'Corresponde a 12% do inventário total ativo', valueColor: AppTheme.primaryTeal)),
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

          // ── Visão do Armazém + Previsão IA ──
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
                children: const [
                  Text('Visão do Armazém', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                  SizedBox(height: 8),
                  Text(
                    'Sistema de monitoramento térmico e de validade operando em 99,8% de precisão. Sem inconsistências detectadas nos últimos 7 dias.',
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
                      Text('Crescimento de demanda de 15% para itens de higiene no próximo trimestre.', style: TextStyle(color: AppTheme.textGray, fontSize: 12)),
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
                      children: const [
                        Text('Visão do Armazém', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                        SizedBox(height: 8),
                        Text(
                          'Sistema de monitoramento térmico e de validade operando em\n99,8% de precisão. Sem inconsistências detectadas nos últimos 7 dias.',
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
                            'Crescimento de demanda de\n15% para itens de higiene no\npróximo trimestre.',
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

  // ================================================================
  // AÇÕES DO DIA — 3 cards estáticos
  // ================================================================
  Widget _buildAcoesCards(bool isMobile) {
    final card1 = _buildAcaoCard(
      borderColor: AppTheme.warningOrange,
      icon: Icons.access_time_filled,
      iconColor: AppTheme.warningOrange,
      titulo: 'Estoque Parado',
      corpo: RichText(
        text: const TextSpan(
          style: TextStyle(color: AppTheme.textGray, fontSize: 13, height: 1.5),
          children: [
            TextSpan(text: 'O produto '),
            TextSpan(text: 'Vinho Tinto', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            TextSpan(text: ' não vende há 15 dias.\n\n'),
            TextSpan(text: 'Sugestão: Promoção na frente do caixa.', style: TextStyle(fontStyle: FontStyle.italic)),
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
      titulo: 'Ponto de Pedido',
      corpo: RichText(
        text: const TextSpan(
          style: TextStyle(color: AppTheme.textGray, fontSize: 13, height: 1.5),
          children: [
            TextSpan(text: 'O estoque de '),
            TextSpan(text: 'Cerveja Lata', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            TextSpan(text: ' zera em 4 dias.\n\nFaça o pedido ao fornecedor hoje.'),
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
      titulo: 'Risco de Perda',
      corpo: RichText(
        text: const TextSpan(
          style: TextStyle(color: AppTheme.textGray, fontSize: 13, height: 1.5),
          children: [
            TextSpan(text: '20 unidades', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.criticalRed)),
            TextSpan(text: ' de Iogurte vencem em 7 dias.\n\n'),
            TextSpan(text: 'Necessário ação imediata de queima.', style: TextStyle(fontStyle: FontStyle.italic)),
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

  // ================================================================
  // PESQUISA + FILTROS
  // ================================================================
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

  // ================================================================
  // TABELA + PAGINAÇÃO
  // ================================================================
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
              final estoquePct = ((item['estoque'] as int) / (item['estoqueMax'] as int) * 100).round();
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
                        Expanded(child: Text(item['produto'] as String, style: const TextStyle(color: AppTheme.textWhite, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Text('R\$ ${(item['preco'] as double).toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Linha 2: SKU + categoria
                    Row(
                      children: [
                        Text('SKU: ${item['sku']}', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppTheme.teal10, borderRadius: BorderRadius.circular(3)),
                          child: Text(item['categoria'] as String, style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 9)),
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
                        Text('R\$ ${(item['valorTotal'] as double).toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold)),
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
              final estoquePct = ((item['estoque'] as int) / (item['estoqueMax'] as int) * 100).round();
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
                        Text(item['produto'] as String, style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('SKU: ${item['sku']}', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
                      ],
                    )),
                    Expanded(flex: 2, child: Text(item['categoria'] as String, style: const TextStyle(color: AppTheme.textGray, fontSize: 12), overflow: TextOverflow.ellipsis)),
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
                    Expanded(flex: 2, child: Text('R\$ ${(item['preco'] as double).toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 12))),
                    Expanded(flex: 2, child: Text('R\$ ${(item['valorTotal'] as double).toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold))),
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

  // ================================================================
  // CARD EXECUTIVO
  // ================================================================
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
