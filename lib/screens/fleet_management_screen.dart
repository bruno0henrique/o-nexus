import 'package:flutter/material.dart';
import 'package:nexus_engine/screens/store_detail_screen.dart';
import 'package:nexus_engine/screens/store_registration_screen.dart';
import 'package:nexus_engine/services/admin_service.dart';
import 'package:nexus_engine/theme/app_theme.dart';

class FleetManagementScreen extends StatefulWidget {
  final void Function(String storeId, String storeName)? onStoreCreated;

  const FleetManagementScreen({super.key, this.onStoreCreated});

  @override
  State<FleetManagementScreen> createState() => _FleetManagementScreenState();
}

class _FleetManagementScreenState extends State<FleetManagementScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStores();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilter);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final raw = await _adminService.fetchStores();
      final safe = raw.map((r) => Map<String, dynamic>.from(r)).toList();
      if (!mounted) return;
      setState(() {
        _stores = safe;
        _filteredFromSource(safe);
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filteredFromSource(List<Map<String, dynamic>> source) {
    final q = _searchCtrl.text.trim().toLowerCase();
    _filtered = q.isEmpty
        ? List.from(source)
        : source.where((s) {
            return '${s['nome_loja'] ?? ''}'.toLowerCase().contains(q) ||
                '${s['cnpj'] ?? ''}'.toLowerCase().contains(q);
          }).toList();
  }

  void _applyFilter() {
    setState(() => _filteredFromSource(_stores));
  }

  String _nxId(String id) {
    if (id.isEmpty) return '#NX-0000';
    return '#NX-${id.substring(0, id.length >= 4 ? 4 : id.length).toUpperCase()}';
  }

  void _openDetails(Map<String, dynamic> store) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoreDetailScreen(store: store, onUpdated: _loadStores),
      ),
    );
  }

  void _openRegister() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => StoreRegistrationScreen(
        onStoreCreated: (id, nome) {
          widget.onStoreCreated?.call(id, nome);
          _loadStores();
          Navigator.of(context).pop();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabeçalho ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FLEET MANAGEMENT',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryTeal,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Lojas Cadastradas',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _openRegister,
                  icon: const Icon(Icons.storefront, size: 16),
                  label: const Text('Cadastrar Nova Loja'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Busca ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.darkPanel,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.accentGray),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: AppTheme.textGray, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Filtrar por nome ou CNPJ...',
                        hintStyle: TextStyle(color: AppTheme.textGray),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  if (_searchCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        _applyFilter();
                      },
                      child: const Icon(Icons.close, color: AppTheme.textGray, size: 16),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Cabeçalho da tabela ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.accentGray)),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 88,
                    child: Text('ID', style: _headerStyle),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('NOME DA LOJA', style: _headerStyle),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('CNPJ', style: _headerStyle),
                  ),
                  SizedBox(
                    width: 92,
                    child: Text('STATUS', style: _headerStyle),
                  ),
                  SizedBox(
                    width: 136,
                    child: Text('AÇÕES', style: _headerStyle),
                  ),
                ],
              ),
            ),

            // ── Conteúdo ────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppTheme.criticalRed, size: 36),
                              const SizedBox(height: 8),
                              Text('Erro: $_error',
                                  style: const TextStyle(
                                      color: AppTheme.criticalRed)),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _loadStores,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        )
                      : _filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhuma loja encontrada.',
                                style: TextStyle(color: AppTheme.textGray),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filtered.length,
                              itemBuilder: (ctx, i) =>
                                  _buildRow(_filtered[i], i),
                            ),
            ),

            // ── Rodapé de contagem ───────────────────────────────────────
            if (!_isLoading && _error == null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Exibindo ${_filtered.length} de ${_stores.length} '
                  'loja${_stores.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppTheme.textGray, fontSize: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> store, int index) {
    final id = '${store['id'] ?? ''}';
    final nome = '${store['nome_loja'] ?? '-'}';
    final cnpj = '${store['cnpj'] ?? '-'}';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
      decoration: BoxDecoration(
        color: index.isEven ? AppTheme.darkerPanel : Colors.transparent,
        border: const Border(
            bottom: BorderSide(color: AppTheme.accentGray, width: 0.4)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              _nxId(id),
              style: const TextStyle(
                color: AppTheme.primaryTeal,
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              nome,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              cnpj,
              style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 92,
            child: Row(
              children: const [
                _StatusDot(online: true),
                SizedBox(width: 6),
                Text('Ativo',
                    style:
                        TextStyle(color: Color(0xFF00FF66), fontSize: 11)),
              ],
            ),
          ),
          SizedBox(
            width: 136,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openDetails(store),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryTeal,
                      side: const BorderSide(color: AppTheme.primaryTeal),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                      minimumSize: const Size(0, 30),
                    ),
                    child: const Text('GERENCIAR'),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _openDetails(store),
                  borderRadius: BorderRadius.circular(4),
                  child: const Icon(
                    Icons.visibility_outlined,
                    color: AppTheme.textGray,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── helpers ────────────────────────────────────────────────────────────────────

const _headerStyle = TextStyle(
  color: AppTheme.textGray,
  fontSize: 11,
  fontWeight: FontWeight.bold,
  letterSpacing: 1,
);

class _StatusDot extends StatelessWidget {
  final bool online;
  const _StatusDot({required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: online ? const Color(0xFF00FF66) : AppTheme.criticalRed,
        boxShadow: online
            ? [BoxShadow(color: const Color(0xFF00FF66).withValues(alpha: 0.5), blurRadius: 6)]
            : null,
      ),
    );
  }
}
