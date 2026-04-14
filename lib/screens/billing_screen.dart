import 'package:flutter/material.dart';
import 'package:nexus_engine/services/billing_service.dart';
import 'package:nexus_engine/theme/app_theme.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

// ─── Helpers ────────────────────────────────────────────────────────────────

String _moeda(double v) {
  final str = v.toStringAsFixed(2);
  final parts = str.split('.');
  String intStr = parts[0];
  String result = '';
  int count = 0;
  for (int i = intStr.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) result = '.$result';
    result = intStr[i] + result;
    count++;
  }
  return 'R\$ $result,${parts[1]}';
}

Color _statusCor(String s) {
  switch (s) {
    case 'pago':
      return AppTheme.primaryTeal;
    case 'cancelado':
      return AppTheme.criticalRed;
    default:
      return AppTheme.warningOrange;
  }
}

String _statusLabel(String s) {
  switch (s) {
    case 'pago':
      return 'PAGO';
    case 'cancelado':
      return 'CANCELADO';
    default:
      return 'PENDENTE';
  }
}

// ─── State ───────────────────────────────────────────────────────────────────

class _BillingScreenState extends State<BillingScreen> {
  final _service = FaturamentoService();

  int _page = 0;
  int _totalRegistros = 0;
  List<FaturamentoEntry> _lista = const [];
  FaturamentoResumo? _resumo;
  List<Map<String, dynamic>> _lojas = const [];
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
      _lista = const [];
      _resumo = null;
      _lojas = const [];
      _totalRegistros = 0;
    });
    try {
      // Carregamento sequencial com validações para evitar dados inválidos
      final paginado = await _service.fetchPaginado(page: _page);
      final resumo = await _service.fetchResumo();
      final total = await _service.countTotal();
      final lojas = await _service.fetchLojas();

      setState(() {
        _lista = paginado;
        _resumo = resumo;
        _totalRegistros = total;
        _lojas = lojas;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar dados: $e';
        _carregando = false;
      });
    }
  }

  int get _totalPaginas => (_totalRegistros / FaturamentoService.pageSize).ceil().clamp(1, 9999);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final carregando = _carregando ?? false;
        final erro = _erro;
        final lista = _lista ?? const [];
        final lojas = _lojas ?? const [];
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: isMobile
              ? AppBar(
                  backgroundColor: AppTheme.background,
                  elevation: 0,
                  title: const Text('Faturamento', style: TextStyle(color: AppTheme.textWhite)),
                )
              : null,
          body: carregando
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
              : erro != null
                  ? _buildErro()
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 12 : 32,
                        isMobile ? 16 : 32,
                        isMobile ? 12 : 32,
                        isMobile ? 20 : 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(isMobile),
                          SizedBox(height: isMobile ? 16 : 28),
                          _buildSummaryCards(isMobile),
                          SizedBox(height: isMobile ? 18 : 32),
                          _buildTransactionTable(isMobile),
                          SizedBox(height: isMobile ? 18 : 32),
                          _buildFooter(),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildErro() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.warningOrange, size: 40),
          const SizedBox(height: 12),
          Text(_erro!, style: const TextStyle(color: AppTheme.textGray), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, foregroundColor: AppTheme.background),
            onPressed: _carregar,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Controle de ',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Faturamento',
                style: TextStyle(
                  color: AppTheme.primaryTeal,
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Acompanhe receitas, cobranças e status de pagamento por loja.',
          style: TextStyle(color: AppTheme.textGray, fontSize: 13),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        SizedBox(height: isMobile ? 14 : 22),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _actionBtn(Icons.file_download_outlined, 'Exportar', isMobile),
            _actionBtn(Icons.add, 'Nova Cobrança', isMobile, primary: true),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, bool isMobile, {bool primary = false}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? AppTheme.primaryTeal : AppTheme.darkPanel,
        foregroundColor: primary ? AppTheme.background : AppTheme.textWhite,
        side: primary ? null : const BorderSide(color: AppTheme.accentGray),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 18, vertical: isMobile ? 10 : 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: TextStyle(fontSize: isMobile ? 12 : 14, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      icon: Icon(icon, size: isMobile ? 16 : 18),
      label: Text(label),
      onPressed: primary ? () => _showNovaCobrancaDialog() : null,
    );
  }

  // ─── Summary Cards ─────────────────────────────────────────────────────────

  Widget _buildSummaryCards(bool isMobile) {
    final r = _resumo;
    final cards = [
      _summaryCard(
        title: 'RECEITA TOTAL (MÊS)',
        value: r != null ? _moeda(r.totalPago) : '—',
        subtitle: 'PAGO',
        icon: Icons.show_chart,
        color: AppTheme.primaryTeal,
        note: '',
      ),
      _summaryCard(
        title: 'COBRANÇAS PENDENTES',
        value: r != null ? _moeda(r.totalPendente) : '—',
        subtitle: r != null ? '${r.qtdPendente} ativas' : '',
        icon: Icons.access_time,
        color: AppTheme.warningOrange,
        note: r != null && r.qtdPendente > 0 ? 'Aguardando confirmação de pagamento' : '',
      ),
      _summaryCard(
        title: 'TAXA DE SUCESSO',
        value: r != null ? '${r.taxaSucesso.toStringAsFixed(1)}%' : '—',
        subtitle: r != null && r.taxaSucesso >= 90 ? 'Ótimo' : 'Verificar',
        icon: Icons.verified,
        color: AppTheme.textWhite,
        note: '',
      ),
    ];

    if (!isMobile) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i < cards.length - 1) const SizedBox(width: 18),
          ],
        ],
      );
    } else {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String note,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentGray.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const Spacer(),
              if (subtitle.isNotEmpty)
                Flexible(
                  child: Text(
                    subtitle,
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textWhite, fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: AppTheme.textGray, fontSize: 11), overflow: TextOverflow.ellipsis),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(note, style: const TextStyle(color: AppTheme.textGray, fontSize: 10), overflow: TextOverflow.ellipsis, maxLines: 2),
          ],
        ],
      ),
    );
  }

  // ─── Tabela ────────────────────────────────────────────────────────────────

  Widget _buildTransactionTable(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentGray.withValues(alpha: 0.18)),
      ),
      child: isMobile ? _buildListaMobile() : _buildTabelaDesktop(),
    );
  }

  Widget _buildTabelaDesktop() {
    final inicio = _lista.isNotEmpty ? _page * FaturamentoService.pageSize + 1 : 0;
    final fim = _lista.isNotEmpty ? inicio + _lista.length - 1 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: const [
              Expanded(flex: 3, child: Text('CLIENTE / LOJA', style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.bold, fontSize: 11))),
              Expanded(flex: 2, child: Text('VENCIMENTO', style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.bold, fontSize: 11))),
              Expanded(flex: 2, child: Text('VALOR', style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.bold, fontSize: 11))),
              Expanded(flex: 1, child: Text('PARC.', style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.bold, fontSize: 11))),
              Expanded(flex: 2, child: Text('STATUS', style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.bold, fontSize: 11))),
              SizedBox(width: 80, child: Text('AÇÕES', style: TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.bold, fontSize: 11))),
            ],
          ),
        ),
        Divider(height: 1, color: AppTheme.accentGray.withValues(alpha: 0.3)),
        if (_lista.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration, color: AppTheme.primaryTeal, size: 36),
                  SizedBox(height: 10),
                  Text('Tudo certo! Nenhum faturamento registrado.', style: TextStyle(color: AppTheme.textGray)),
                ],
              ),
            ),
          )
        else
          ..._lista.map(_linhaDesktop),
        Divider(height: 1, color: AppTheme.accentGray.withValues(alpha: 0.3)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Text(
                '$inicio–$fim de $_totalRegistros registros',
                style: const TextStyle(color: AppTheme.textGray, fontSize: 11),
              ),
              const Spacer(),
              _btnPagina('< Anterior', _page > 0 ? _paginaAnterior : null),
              const SizedBox(width: 10),
              Text('PÁG. ${_page + 1} DE $_totalPaginas', style: const TextStyle(color: AppTheme.textGray, fontSize: 11)),
              const SizedBox(width: 10),
              _btnPagina('Próxima >', _page < _totalPaginas - 1 ? _proximaPagina : null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linhaDesktop(FaturamentoEntry e) {
    final cor = _statusCor(e.status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Cliente + Loja
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppTheme.accentGray,
                  child: Text(
                    e.nomeCliente.isNotEmpty ? e.nomeCliente[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.nomeCliente, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                      Text(e.nomeLoja, style: const TextStyle(color: AppTheme.textGray, fontSize: 10), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Vencimento
          Expanded(
            flex: 2,
            child: Text('Dia ${e.diaVencimento}', style: const TextStyle(color: AppTheme.textGray, fontSize: 12)),
          ),
          // Valor
          Expanded(
            flex: 2,
            child: Text(_moeda(e.valorTotal), style: const TextStyle(color: AppTheme.textWhite, fontSize: 12), overflow: TextOverflow.ellipsis),
          ),
          // Parcelas
          Expanded(
            flex: 1,
            child: Text('${e.parcelas}x', style: const TextStyle(color: AppTheme.textGray, fontSize: 12)),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_statusLabel(e.status), style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ),
          ),
          // Ações
          SizedBox(
            width: 80,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.visibility, color: AppTheme.textGray, size: 17),
                  onPressed: () => _showDetalhe(e),
                ),
                IconButton(
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit, color: AppTheme.textGray, size: 17),
                  onPressed: () => _showAlterarStatus(e),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaMobile() {
    return Column(
      children: [
        if (_lista.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration, color: AppTheme.primaryTeal, size: 36),
                  SizedBox(height: 10),
                  Text('Tudo certo! Nenhum faturamento registrado.', style: TextStyle(color: AppTheme.textGray)),
                ],
              ),
            ),
          )
        else
          ..._lista.map(_cardMobile),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _btnPagina('< Anterior', _page > 0 ? _paginaAnterior : null),
              Text('${_page + 1}/$_totalPaginas', style: const TextStyle(color: AppTheme.textGray, fontSize: 11)),
              _btnPagina('Próxima >', _page < _totalPaginas - 1 ? _proximaPagina : null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cardMobile(FaturamentoEntry e) {
    final cor = _statusCor(e.status);
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGray.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppTheme.accentGray,
                child: Text(
                  (e.nomeCliente.isNotEmpty ? e.nomeCliente[0].toUpperCase() : '?') ?? '?',
                  style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.nomeCliente ?? '', style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                    Text(e.nomeLoja ?? '', style: const TextStyle(color: AppTheme.textGray, fontSize: 11), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit, color: AppTheme.textGray, size: 17),
                onPressed: () => _showAlterarStatus(e),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _infoChip(Icons.calendar_today, 'Dia ${(e.diaVencimento ?? '')}'),
              _infoChip(Icons.payments, _moeda(e.valorTotal ?? 0)),
              _infoChip(Icons.repeat, '${e.parcelas ?? 1}x'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_statusLabel(e.status ?? 'pendente'), style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textGray, size: 12),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.textGray, fontSize: 11)),
      ],
    );
  }

  Widget _btnPagina(String label, VoidCallback? onTap) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: onTap != null ? AppTheme.textWhite : AppTheme.accentGray,
        textStyle: const TextStyle(fontSize: 11),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        side: BorderSide(color: onTap != null ? AppTheme.accentGray : AppTheme.accentGray.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }

  void _paginaAnterior() {
    setState(() => _page--);
    _carregarPagina();
  }

  void _proximaPagina() {
    setState(() => _page++);
    _carregarPagina();
  }

  Future<void> _carregarPagina() async {
    setState(() => _carregando = true);
    try {
      final lista = await _service.fetchPaginado(page: _page);
      setState(() {
        _lista = lista;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar página: $e';
        _carregando = false;
      });
    }
  }

  // ─── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.darkPanel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accentGray.withValues(alpha: 0.18)),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.sync, color: AppTheme.primaryTeal, size: 16),
            const Text('DADOS SINCRONIZADOS', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
            Text('$_totalRegistros registros', style: const TextStyle(color: AppTheme.textGray, fontSize: 11)),
            IconButton(
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.refresh, color: AppTheme.textGray, size: 16),
              onPressed: _carregar,
              tooltip: 'Recarregar',
            ),
          ],
        ),
      ),
    );
  }

  // ─── Diálogos ──────────────────────────────────────────────────────────────

  void _showDetalhe(FaturamentoEntry e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkPanel,
        title: Text(e.nomeCliente, style: const TextStyle(color: AppTheme.textWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detalheItem('Loja', e.nomeLoja),
            _detalheItem('Valor Total', _moeda(e.valorTotal)),
            _detalheItem('Parcelas', '${e.parcelas}x'),
            _detalheItem('Dia de Vencimento', 'Dia ${e.diaVencimento}'),
            _detalheItem('Status', _statusLabel(e.status)),
            _detalheItem('Cadastrado em', '${e.criadoEm.day.toString().padLeft(2, '0')}/${e.criadoEm.month.toString().padLeft(2, '0')}/${e.criadoEm.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar', style: TextStyle(color: AppTheme.primaryTeal)),
          ),
        ],
      ),
    );
  }

  Widget _detalheItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text('$label:', style: const TextStyle(color: AppTheme.textGray, fontSize: 12)),
          ),
          Flexible(
            child: Text(value, style: const TextStyle(color: AppTheme.textWhite, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showAlterarStatus(FaturamentoEntry e) {
    String selecionado = e.status;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppTheme.darkPanel,
          title: const Text('Alterar Status', style: TextStyle(color: AppTheme.textWhite)),
          content: DropdownButton<String>(
            value: selecionado,
            dropdownColor: AppTheme.darkPanel,
            style: const TextStyle(color: AppTheme.textWhite),
            onChanged: (v) => setLocal(() => selecionado = v!),
            items: const [
              DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
              DropdownMenuItem(value: 'pago', child: Text('Pago')),
              DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textGray)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, foregroundColor: AppTheme.background),
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await _service.atualizarStatus(e.id, selecionado);
                  _carregar();
                } catch (err) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro: $err'), backgroundColor: AppTheme.criticalRed),
                    );
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNovaCobrancaDialog() {
    if (_lojas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma loja cadastrada. Cadastre uma loja primeiro.'),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    String? lojaId = _lojas.first['id'] as String;
    final clienteCtrl = TextEditingController();
    final valorCtrl = TextEditingController();
    final parcelasCtrl = TextEditingController(text: '1');
    final diaCtrl = TextEditingController(text: '10');
    String statusNovo = 'pendente';
    bool salvando = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: AppTheme.darkPanel,
          title: const Text('Nova Cobrança', style: TextStyle(color: AppTheme.textWhite)),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Loja
                    DropdownButtonFormField<String>(
                      value: lojaId,
                      dropdownColor: AppTheme.darkPanel,
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                      decoration: _inputDecoration('Loja'),
                      items: _lojas.map((l) => DropdownMenuItem<String>(
                        value: l['id'] as String,
                        child: Text(l['nome'] as String? ?? ''),
                      )).toList(),
                      onChanged: (v) => lojaId = v,
                      validator: (v) => v == null ? 'Selecione uma loja' : null,
                    ),
                    const SizedBox(height: 12),
                    // Nome do cliente
                    TextFormField(
                      controller: clienteCtrl,
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                      decoration: _inputDecoration('Nome do cliente'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 12),
                    // Valor
                    TextFormField(
                      controller: valorCtrl,
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                      decoration: _inputDecoration('Valor total (R\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                        return n == null || n <= 0 ? 'Valor inválido' : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // Parcelas + Dia (linha)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: parcelasCtrl,
                            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                            decoration: _inputDecoration('Parcelas'),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              return n == null || n < 1 ? 'Mín. 1' : null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: diaCtrl,
                            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                            decoration: _inputDecoration('Dia venc.'),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              return n == null || n < 1 || n > 31 ? '1–31' : null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Status
                    DropdownButtonFormField<String>(
                      value: statusNovo,
                      dropdownColor: AppTheme.darkPanel,
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                      decoration: _inputDecoration('Status'),
                      items: const [
                        DropdownMenuItem(value: 'pendente', child: Text('Pendente')),
                        DropdownMenuItem(value: 'pago', child: Text('Pago')),
                        DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
                      ],
                      onChanged: (v) => setLocal(() => statusNovo = v!),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: salvando ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textGray)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal, foregroundColor: AppTheme.background),
              onPressed: salvando
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setLocal(() => salvando = true);
                      try {
                        await _service.inserir(
                          lojaId: lojaId!,
                          nomeCliente: clienteCtrl.text.trim(),
                          valorTotal: double.parse(valorCtrl.text.replaceAll(',', '.')),
                          parcelas: int.parse(parcelasCtrl.text),
                          diaVencimento: int.parse(diaCtrl.text),
                          status: statusNovo,
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        _carregar();
                      } catch (err) {
                        setLocal(() => salvando = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro: $err'), backgroundColor: AppTheme.criticalRed),
                          );
                        }
                      }
                    },
              child: salvando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.background))
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textGray, fontSize: 12),
      filled: true,
      fillColor: AppTheme.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.accentGray)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.accentGray)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.primaryTeal)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
