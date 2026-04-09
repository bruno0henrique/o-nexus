import 'package:flutter/material.dart';
import 'package:nexus_engine/theme/app_theme.dart';

// ── Modelos de dados estáticos ─────────────────────────────────────────────

class _Remessa {
  final String id;
  final String fornecedor;
  final String dataPrevista;
  final _StatusRemessa status;

  const _Remessa({
    required this.id,
    required this.fornecedor,
    required this.dataPrevista,
    required this.status,
  });
}

enum _StatusRemessa { emTransito, atrasado, pendente }

class _Fornecedor {
  final String inicial;
  final String nome;
  final String categoria;
  final double nota;
  final Color cor;

  const _Fornecedor({
    required this.inicial,
    required this.nome,
    required this.categoria,
    required this.nota,
    required this.cor,
  });
}

// ── Dados ──────────────────────────────────────────────────────────────────

const _remessas = [
  _Remessa(id: '#NX-9921', fornecedor: 'Ambev Distribuidora', dataPrevista: '15 Mai, 2024', status: _StatusRemessa.emTransito),
  _Remessa(id: '#NX-9842', fornecedor: 'Loggi Express', dataPrevista: '12 Mai, 2024', status: _StatusRemessa.atrasado),
  _Remessa(id: '#NX-9980', fornecedor: 'Nestlé Brasil', dataPrevista: '16 Mai, 2024', status: _StatusRemessa.pendente),
  _Remessa(id: '#NX-1005', fornecedor: 'Unilever S.A.', dataPrevista: '17 Mai, 2024', status: _StatusRemessa.emTransito),
];

const _fornecedores = [
  _Fornecedor(
    inicial: 'A',
    nome: 'Ambev',
    categoria: 'BEBIDAS & DESTILADOS',
    nota: 9.8,
    cor: Color(0xFF00BFFF),
  ),
  _Fornecedor(
    inicial: 'N',
    nome: 'Nestlé Brasil',
    categoria: 'ALIMENTOS SECOS',
    nota: 9.4,
    cor: Color(0xFF00FFAA),
  ),
  _Fornecedor(
    inicial: 'U',
    nome: 'Unilever S.A.',
    categoria: 'HIGIENE & LIMPEZA',
    nota: 8.9,
    cor: Color(0xFF7B68EE),
  ),
  _Fornecedor(
    inicial: 'L',
    nome: 'Loggi Express',
    categoria: 'LOGÍSTICA TERCEIRIZADA',
    nota: 7.2,
    cor: Color(0xFFFF8C00),
  ),
];

// ── Widget principal ───────────────────────────────────────────────────────

class LogisticsView extends StatelessWidget {
  const LogisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return Scaffold(
          backgroundColor: AppTheme.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: AppTheme.background,
            icon: const Icon(Icons.add),
            label: const Text('Nova Remessa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(isWide ? 28 : 16, isWide ? 28 : 20, isWide ? 28 : 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isWide),
                const SizedBox(height: 20),
                _buildMetricCards(isWide),
                const SizedBox(height: 24),
                isWide ? _buildWideContent() : _buildNarrowContent(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAINEL OPERACIONAL',
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.primaryTeal,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Gestão de Logística\ne Suprimentos',
          style: TextStyle(
            fontSize: isWide ? 26 : 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textWhite,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // ── Metric cards ────────────────────────────────────────────────────────

  Widget _buildMetricCards(bool isWide) {
    final cards = [
      _buildMetricCard(
        title: 'PEDIDOS EM TRÂNSITO',
        value: '08',
        icon: Icons.local_shipping_outlined,
        iconColor: AppTheme.primaryTeal,
        sub: '+12% em relação à semana passada',
        subColor: AppTheme.primaryTeal,
        isAlert: false,
      ),
      _buildMetricCard(
        title: 'ENTREGAS PARA HOJE',
        value: '03',
        icon: Icons.access_time_outlined,
        iconColor: AppTheme.warningOrange,
        sub: 'Previsão: 14:00 – 18:00 (Janela Principal)',
        subColor: AppTheme.textGray,
        isAlert: false,
      ),
      _buildMetricCard(
        title: 'ATRASOS DETECTADOS',
        value: '01',
        icon: Icons.warning_rounded,
        iconColor: AppTheme.criticalRed,
        sub: 'Ação imediata recomendada\npara o Pedido #NX-9842',
        subColor: AppTheme.criticalRed,
        isAlert: true,
      ),
    ];

    if (isWide) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        // Dois cards lado a lado no mobile
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 10),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 10),
        // Alerta em largura total
        cards[2],
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String sub,
    required Color subColor,
    required bool isAlert,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? AppTheme.criticalRed.withValues(alpha: 0.08) : AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAlert ? AppTheme.criticalRed.withValues(alpha: 0.4) : AppTheme.accentGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: isAlert ? AppTheme.criticalRed : AppTheme.textWhite,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              color: subColor,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Layout wide (tablet/desktop): lado a lado ────────────────────────────

  Widget _buildWideContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildRemessasPanel(wide: true)),
        const SizedBox(width: 16),
        SizedBox(width: 260, child: _buildFornecedoresPanel()),
      ],
    );
  }

  // ── Layout narrow (mobile): empilhado ────────────────────────────────────

  Widget _buildNarrowContent() {
    return Column(
      children: [
        _buildRemessasPanel(wide: false),
        const SizedBox(height: 20),
        _buildFornecedoresPanel(),
      ],
    );
  }

  // ── Painel de remessas ───────────────────────────────────────────────────

  Widget _buildRemessasPanel({required bool wide}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Lista de Remessas Ativas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'VER TUDO',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new, color: AppTheme.primaryTeal, size: 13),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.accentGray, height: 1),

          // Conteúdo: tabela (wide) ou cards (narrow)
          if (wide)
            _buildRemessasTable()
          else
            ..._remessas.map(_buildRemessaCard),
        ],
      ),
    );
  }

  // Tabela (wide) ─────────────────────────────────────────────────────────

  Widget _buildRemessasTable() {
    return Column(
      children: [
        // Header da tabela
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.darkPanel,
          child: const Row(
            children: [
              SizedBox(width: 100, child: Text('ID PEDIDO', style: _tblHeader)),
              SizedBox(width: 160, child: Text('FORNECEDOR', style: _tblHeader)),
              SizedBox(width: 120, child: Text('DATA PREVISTA', style: _tblHeader)),
              SizedBox(width: 110, child: Text('STATUS', style: _tblHeader)),
              SizedBox(width: 50, child: Text('AÇÃO', style: _tblHeader)),
            ],
          ),
        ),
        // Linhas
        ..._remessas.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: i.isOdd ? AppTheme.darkPanel.withValues(alpha: 0.3) : Colors.transparent,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    r.id,
                    style: const TextStyle(
                      color: AppTheme.primaryTeal,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: Text(
                    r.fornecedor,
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    r.dataPrevista,
                    style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
                  ),
                ),
                SizedBox(width: 110, child: _buildStatusBadge(r.status)),
                SizedBox(
                  width: 50,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.visibility_outlined, color: AppTheme.textGray, size: 18),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Card de remessa (mobile) ──────────────────────────────────────────────

  Widget _buildRemessaCard(_Remessa r) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.accentGray, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ID + Fornecedor
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.id,
                  style: const TextStyle(
                    color: AppTheme.primaryTeal,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  r.fornecedor,
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  r.dataPrevista,
                  style: const TextStyle(color: AppTheme.textGray, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Status
          _buildStatusBadge(r.status),
          const SizedBox(width: 12),
          // Ação
          Icon(Icons.visibility_outlined, color: AppTheme.textGray, size: 20),
        ],
      ),
    );
  }

  // Badge de status ───────────────────────────────────────────────────────

  Widget _buildStatusBadge(_StatusRemessa status) {
    final (label, color) = switch (status) {
      _StatusRemessa.emTransito => ('EM TRÂNSITO', AppTheme.primaryTeal),
      _StatusRemessa.atrasado => ('ATRASADO', AppTheme.criticalRed),
      _StatusRemessa.pendente => ('PENDENTE', AppTheme.warningOrange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Painel de fornecedores ───────────────────────────────────────────────

  Widget _buildFornecedoresPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkerPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Top Fornecedores',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textWhite,
                  ),
                ),
              ),
              const Icon(Icons.star, color: AppTheme.warningOrange, size: 16),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de fornecedores
          ..._fornecedores.map((f) => _buildFornecedorItem(f)),

          const SizedBox(height: 12),
          const Divider(color: AppTheme.accentGray, height: 1),
          const SizedBox(height: 12),

          // Botão gerenciar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: const BorderSide(color: AppTheme.accentGray),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'GERENCIAR TODOS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFornecedorItem(_Fornecedor f) {
    final pct = (f.nota / 10.0).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: f.cor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: f.cor.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                f.inicial,
                style: TextStyle(
                  color: f.cor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        f.nome,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${f.nota}/10',
                      style: TextStyle(
                        color: f.cor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  f.categoria,
                  style: const TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 9,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppTheme.accentGray,
                    valueColor: AlwaysStoppedAnimation<Color>(f.cor),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _tblHeader = TextStyle(
    fontSize: 9,
    color: AppTheme.primaryTeal,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );
}
