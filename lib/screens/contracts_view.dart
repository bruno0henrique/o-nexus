import 'package:flutter/material.dart';
import 'package:nexus_engine/screens/store_inspection_screen.dart';
import 'package:nexus_engine/services/admin_service.dart';
import 'package:nexus_engine/theme/app_theme.dart';

class ContractsView extends StatefulWidget {
  const ContractsView({super.key});

  @override
  State<ContractsView> createState() => _ContractsViewState();
}

class _ContractsViewState extends State<ContractsView> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _contracts = [];
  bool _isLoading = true;
  String? _errorMsg;

  Map<String, dynamic>? _selected;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final stores = await _adminService.fetchStores();
      setState(() {
        _contracts = stores.map((s) {
          final name = (s['nome_loja'] as String?) ?? 'Loja';
          final words = name.trim().split(RegExp(r'\s+'));
          final initials = words.length >= 2
              ? '${words[0][0]}${words[1][0]}'.toUpperCase()
              : name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
          final plano = (s['plano'] as String?) ?? 'Basic';
          final url = s['url_contrato'] as String?;
          return {
            'id': s['id'],
            'initials': initials,
            'name': name,
            'type': plano.toUpperCase(),
            'typeIsPrimary': plano.toLowerCase() == 'enterprise',
            'activation': '—',
            'maturity': '—',
            'status': url != null && url.isNotEmpty ? 'Ativo' : 'Sem Contrato',
            'statusColor': url != null && url.isNotEmpty
                ? AppTheme.primaryTeal
                : AppTheme.textGray,
            'pdfUrl': url ?? '',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return StoreInspectionScreen(
        contractName: _selected!['name'] as String,
        pdfUrl: _selected!['pdfUrl'] as String,
        onBack: () => setState(() => _selected = null),
      );
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
    }
    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.criticalRed, size: 40),
            const SizedBox(height: 12),
            Text(_errorMsg!, style: const TextStyle(color: AppTheme.textGray, fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContracts,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    return _buildMasterView();
  }

  // ─── Master View ──────────────────────────────────────────────────────────
  Widget _buildMasterView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(isMobile ? 10 : 28, isMobile ? 12 : 24, isMobile ? 10 : 28, isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile: isMobile),
              SizedBox(height: isMobile ? 14 : 24),
              _buildStatCards(isMobile: isMobile),
              SizedBox(height: isMobile ? 14 : 24),
              Divider(
                color: AppTheme.accentGray.withValues(alpha: 0.35),
                thickness: 1,
                height: isMobile ? 18 : 28,
              ),
              SizedBox(height: isMobile ? 10 : 18),
              isMobile ? _buildListViewMobile() : _buildTable(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader({bool isMobile = false}) {
    if (!isMobile) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Registro de Contratos',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gerencie e monitore a infraestrutura legal de varejo de alto valor.',
                  style: TextStyle(color: AppTheme.textGray, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              _headerBtn(Icons.file_download_outlined, 'Exportar', false),
              const SizedBox(width: 8),
              _headerBtn(Icons.upload_file, 'Upload PDF', false),
              const SizedBox(width: 8),
              _headerBtn(Icons.add, 'Novo Contrato', true),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registro de Contratos',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gerencie e monitore a infraestrutura legal de varejo de alto valor.',
            style: TextStyle(color: AppTheme.textGray, fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _headerBtn(Icons.file_download_outlined, '', false)),
              const SizedBox(width: 6),
              Expanded(child: _headerBtn(Icons.upload_file, '', false)),
              const SizedBox(width: 6),
              Expanded(child: _headerBtn(Icons.add, '', true)),
            ],
          ),
        ],
      );
    }
  }

  Widget _headerBtn(IconData icon, String label, bool primary) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary ? AppTheme.primaryTeal : AppTheme.darkPanel,
        foregroundColor: primary ? AppTheme.background : AppTheme.textWhite,
        side: primary ? null : const BorderSide(color: AppTheme.accentGray),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      onPressed: () {},
      child: label.isEmpty
          ? Icon(icon, size: 18)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15),
                const SizedBox(width: 6),
                Text(label),
              ],
            ),
    );
  }

  Widget _buildStatCards({bool isMobile = false}) {
    final cards = [
      _statCard(
        badge: 'ATIVO',
        badgeColor: AppTheme.primaryTeal,
        icon: Icons.verified_outlined,
        value: '1.248',
        sub: 'Total de Contratos Ativos',
        note: '+12% em relação ao trimestre anterior',
        noteColor: AppTheme.primaryTeal,
      ),
      _statCard(
        badge: 'PIPELINE',
        badgeColor: AppTheme.warningOrange,
        icon: Icons.autorenew,
        value: '42',
        sub: 'Renovações Pendentes',
        note: 'Próxima revisão: Ago 24',
        noteColor: AppTheme.textGray,
      ),
      _statCard(
        badge: 'AÇÃO NECESSÁRIA',
        badgeColor: AppTheme.criticalRed,
        icon: Icons.event_busy_outlined,
        value: '08',
        sub: 'Vencendo em Breve',
        note: '⚠ Atenção crítica necessária',
        noteColor: AppTheme.criticalRed,
      ),
    ];
    if (!isMobile) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i < cards.length - 1) const SizedBox(width: 12),
          ],
        ],
      );
    } else {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }
  }
  // Mobile: lista vertical simplificada
  Widget _buildListViewMobile() {
    if (_contracts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text('Nenhum contrato encontrado.', style: TextStyle(color: AppTheme.textGray, fontSize: 13)),
        ),
      );
    }
    return Column(
      children: [
        for (final c in _contracts) _contractCardMobile(c),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _pageBtn('< Anterior'),
            _pageBtn('Próximo >'),
          ],
        ),
      ],
    );
  }

  Widget _contractCardMobile(Map<String, dynamic> c) {
    final statusColor = c['statusColor'] as Color;
    final isPrimary = c['typeIsPrimary'] as bool;
    final typeColor = isPrimary ? AppTheme.primaryTeal : AppTheme.textGray;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGray.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.accentGray,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  c['initials'] as String,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c['name'] as String,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.visibility_outlined, color: AppTheme.primaryTeal, size: 20),
                onPressed: () => setState(() => _selected = c),
                tooltip: 'Visualizar Contrato',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  c['type'] as String,
                  style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
              ),
              const SizedBox(width: 4),
              Text(c['status'] as String, style: TextStyle(color: statusColor, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 12, color: AppTheme.textGray),
              const SizedBox(width: 4),
              Text('Ativação: ${c['activation']}', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
              const SizedBox(width: 12),
              const Icon(Icons.event, size: 12, color: AppTheme.textGray),
              const SizedBox(width: 4),
              Text('Venc: ${c['maturity']}', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required String value,
    required String sub,
    required String note,
    required Color noteColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGray.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: badgeColor, size: 22),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(color: AppTheme.textGray, fontSize: 11)),
          const SizedBox(height: 8),
          Text(
            note,
            style: TextStyle(color: noteColor.withValues(alpha: 0.85), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGray.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          // Table toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const Text(
                  'Acordos Recentes',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Icon(Icons.filter_list, color: AppTheme.textGray, size: 18),
                const SizedBox(width: 12),
                Icon(Icons.more_vert, color: AppTheme.textGray, size: 18),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.accentGray.withValues(alpha: 0.4)),
          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: const [
                Expanded(flex: 3, child: _ColHeader('ENTIDADE CLIENTE')),
                Expanded(flex: 2, child: _ColHeader('TIPO DE LICENÇA')),
                Expanded(flex: 2, child: _ColHeader('DATA DE ATIVAÇÃO')),
                Expanded(flex: 2, child: _ColHeader('DATA DE VENCIMENTO')),
                Expanded(flex: 2, child: _ColHeader('STATUS DO CICLO')),
                SizedBox(width: 50, child: _ColHeader('AÇÕES')),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.accentGray.withValues(alpha: 0.3)),
          // Data rows
          if (_contracts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text('Nenhum contrato encontrado.',
                    style: TextStyle(color: AppTheme.textGray, fontSize: 13)),
              ),
            )
          else
            ..._contracts.map(_contractRow),
          Divider(height: 1, color: AppTheme.accentGray.withValues(alpha: 0.3)),
          // Footer / pagination
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Mostrando ${_contracts.length} contrato${_contracts.length != 1 ? 's' : ''}',
                  style: const TextStyle(color: AppTheme.textGray, fontSize: 11),
                ),
                const Spacer(),
                _pageBtn('< Anterior'),
                const SizedBox(width: 8),
                _pageBtn('Próximo >'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractRow(Map<String, dynamic> c) {
    final statusColor = c['statusColor'] as Color;
    final isPrimary = c['typeIsPrimary'] as bool;
    final typeColor = isPrimary ? AppTheme.primaryTeal : AppTheme.textGray;

    return InkWell(
      onTap: () => setState(() => _selected = c),
      hoverColor: AppTheme.darkerPanel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            // Client
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGray,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c['initials'] as String,
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      c['name'] as String,
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Type badge
            Expanded(
              flex: 2,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    c['type'] as String,
                    style: TextStyle(
                        color: typeColor, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // Activation
            Expanded(
              flex: 2,
              child: Text(c['activation'] as String,
                  style: const TextStyle(color: AppTheme.textGray, fontSize: 12)),
            ),
            // Maturity
            Expanded(
              flex: 2,
              child: Text(c['maturity'] as String,
                  style: const TextStyle(color: AppTheme.textGray, fontSize: 12)),
            ),
            // Status
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: statusColor),
                  ),
                  const SizedBox(width: 6),
                  Text(c['status'] as String,
                      style: TextStyle(color: statusColor, fontSize: 12)),
                ],
              ),
            ),
            // Action
            SizedBox(
              width: 50,
              child: IconButton(
                icon: const Icon(Icons.visibility_outlined,
                    color: AppTheme.textGray, size: 18),
                onPressed: () => setState(() => _selected = c),
                tooltip: 'Visualizar Contrato',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageBtn(String label) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.textGray,
        textStyle: const TextStyle(fontSize: 11),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        side: const BorderSide(color: AppTheme.accentGray),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      onPressed: () {},
      child: Text(label),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textGray,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}
