import 'package:flutter/material.dart';
import 'package:nexus_engine/screens/admin_mode_view.dart';
import 'package:nexus_engine/screens/user_mode_view.dart';
import 'package:nexus_engine/screens/inventory_view.dart';
import 'package:nexus_engine/screens/logistics_view.dart';
import 'package:nexus_engine/screens/statistics_view.dart';
import 'package:nexus_engine/screens/contracts_view.dart';
import 'package:nexus_engine/screens/fleet_management_screen.dart';
import 'package:nexus_engine/screens/store_registration_screen.dart';
import 'package:nexus_engine/screens/billing_screen.dart';
import 'package:nexus_engine/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:nexus_engine/services/admin_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexus_engine/main.dart' show supabaseAvailable;
import 'package:nexus_engine/screens/login_screen.dart';

class MainApplication extends StatefulWidget {
  const MainApplication({super.key});

  @override
  State<MainApplication> createState() => _MainApplicationState();
}

class _MainApplicationState extends State<MainApplication> {
  bool isAdminMode = false;
  int _selectedIndex = 0;

  // Stores (populated from Supabase)
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _userStores = [];
  String? _selectedStoreId;
  String? _selectedStoreName;
  String? _selectedUserStoreId;
  String? _selectedUserStoreName;
  bool _isStoreSelectorOpen = false;
  bool _isUserStoreSelectorOpen = false;
  final bool _isStoreButtonPressed = false;
  String? _loggedClientCnpj;

  // Última loja cadastrada — exibida na topbar para copiar o ID
  String? _lastCreatedStoreId;
  String? _lastCreatedStoreName;

  void toggleMode() {
    setState(() {
      isAdminMode = !isAdminMode;
      _selectedIndex = 0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    try {
      final raw = await _adminService.fetchStores();
      // Cria cópia segura para evitar referências a objetos JS (Flutter Web)
      final safeCopy = <Map<String, dynamic>>[];
      for (final r in raw) {
        safeCopy.add(Map<String, dynamic>.from(r));
      }
      setState(() {
        _stores = safeCopy;
        _loggedClientCnpj = _resolveLoggedClientCnpj();
        _userStores = _filterStoresByCnpj(_stores, _loggedClientCnpj);
        if ((_selectedStoreId == null || _selectedStoreId!.isEmpty) && _stores.isNotEmpty) {
          _selectedStoreId = '${_stores.first['id'] ?? ''}';
          _selectedStoreName = '${_stores.first['nome_loja'] ?? _selectedStoreId}';
        }
        if ((_selectedUserStoreId == null || _selectedUserStoreId!.isEmpty) && _userStores.isNotEmpty) {
          _selectedUserStoreId = '${_userStores.first['id'] ?? ''}';
          _selectedUserStoreName = '${_userStores.first['nome_loja'] ?? _selectedUserStoreId}';
        }
      });
    } catch (e, st) {
      // ignore: avoid_print
      print('Erro ao carregar lojas: $e\n$st');
    }
  }

  String? _resolveLoggedClientCnpj() {
    if (!supabaseAvailable) return null;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    final candidates = <dynamic>[
      user.userMetadata?['cnpj'],
      user.userMetadata?['cnpj_cliente'],
      user.userMetadata?['client_cnpj'],
      user.appMetadata['cnpj'],
      user.appMetadata['cnpj_cliente'],
      user.appMetadata['client_cnpj'],
    ];
    for (final item in candidates) {
      final value = (item ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  List<Map<String, dynamic>> _filterStoresByCnpj(List<Map<String, dynamic>> stores, String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) return <Map<String, dynamic>>[];
    final target = cnpj.replaceAll(RegExp(r'\D'), '');
    return stores.where((s) {
      final storeCnpj = '${s['cnpj'] ?? ''}'.replaceAll(RegExp(r'\D'), '');
      return storeCnpj.isNotEmpty && storeCnpj == target;
    }).toList();
  }

  Widget _buildAppTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryTeal, width: 3),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'NEXUS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: AppTheme.textWhite),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    // Custom slim sidebar to match visual model: icon above, label below, thin right indicator
    final adminItems = [
      {'icon': Icons.dashboard, 'label': 'PAINEL'},
      {'icon': Icons.store_mall_directory, 'label': 'GERENCIAR LOJAS'},
      {'icon': Icons.add_business, 'label': 'CADASTRAR LOJA'},
      {'icon': Icons.history, 'label': 'HISTÓRICO'},
      {'icon': Icons.payments_outlined, 'label': 'FATURAMENTO'},
      {'icon': Icons.query_stats, 'label': 'MONITORAMENTO SQL'},
      {'icon': Icons.security_update_good, 'label': 'AUDITORIA DE LOGS'},
      {'icon': Icons.description_outlined, 'label': 'CONTRATOS'},
    ];

    final userItems = [
      {'icon': Icons.dashboard, 'label': 'PAINEL'},
      {'icon': Icons.inventory_2_outlined, 'label': 'INVENTÁRIO'},
      {'icon': Icons.analytics_outlined, 'label': 'ANÁLISES'},
      {'icon': Icons.local_shipping_outlined, 'label': 'LOGÍSTICA'},
      {'icon': Icons.bar_chart, 'label': 'ESTATÍSTICAS'},
    ];

    final items = isAdminMode ? adminItems : userItems;

    return Container(
      width: 78,
      color: AppTheme.darkerPanel,
      child: Column(
        children: [
          // Header (compact)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: isAdminMode
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Nexus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                      SizedBox(height: 2),
                      Text('HUD', style: TextStyle(fontSize: 10, color: AppTheme.textWhite)),
                      SizedBox(height: 2),
                      Text('ADMIN', style: TextStyle(fontSize: 9, color: AppTheme.textGray, letterSpacing: 1)),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('Nexus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                      SizedBox(height: 2),
                      Text('HUD', style: TextStyle(fontSize: 9, color: AppTheme.textGray)),
                    ],
                  ),
          ),
          // Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final item = items[idx];
                final bool selected = _selectedIndex == idx;
                return InkWell(
                  onTap: () => _onItemTapped(idx),
                  child: Container(
                      height: 72,
                      color: selected ? AppTheme.darkPanel : Colors.transparent,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(item['icon'] as IconData, color: selected ? AppTheme.primaryTeal : AppTheme.textGray, size: 24),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['label'] as String,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: selected ? AppTheme.primaryTeal : AppTheme.textGray,
                                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Thin right indicator
                          Container(width: 4, height: 56, color: selected ? AppTheme.primaryTeal : Colors.transparent),
                        ],
                      ),
                    ),
                );
              },
            ),
          ),
          // Botão de seleção de loja no rodapé do Drawer — apenas em Admin Mode mobile
          if (isAdminMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: InkWell(
                onTap: _openStoreSelector,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.teal10,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront, color: AppTheme.primaryTeal, size: 17),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'LOJA ATIVA',
                              style: TextStyle(
                                color: AppTheme.textGray,
                                fontSize: 8,
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _selectedStoreName ?? 'Selecionar loja',
                              style: const TextStyle(
                                color: AppTheme.textWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.swap_horiz, color: AppTheme.primaryTeal, size: 15),
                    ],
                  ),
                ),
              ),
            ),
          // Settings button at bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: IconButton(
              icon: const Icon(Icons.settings, color: AppTheme.textGray),
              onPressed: () {
                // preserve existing behavior
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 800;
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: isMobile
              ? AppBar(
                  title: _buildAppTitle(),
                  actions: [
                    _buildModeToggle(),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppTheme.textGray),
                      tooltip: 'Sair',
                      onPressed: _handleLogout,
                    ),
                  ],
                )
              : null,
          drawer: isMobile ? Drawer(child: _buildSidebar()) : null,
          body: Row(
            children: [
              if (!isMobile) _buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile) _buildTopBar(),
                    Expanded(child: _buildCurrentView()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentView() {
    if (isAdminMode) {
      if (_selectedIndex == 0) {
        return Column(
          children: [
            if (_lastCreatedStoreId != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 2, 24, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 28, maxHeight: 36),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.teal10,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppTheme.primaryTeal, size: 12),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _lastCreatedStoreName ?? 'Nova loja',
                                style: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w700, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _lastCreatedStoreId!,
                                style: const TextStyle(color: AppTheme.textGray, fontFamily: 'monospace', fontSize: 9),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final id = _lastCreatedStoreId!;
                            await Clipboard.setData(ClipboardData(text: id));
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ID copiado'), backgroundColor: AppTheme.primaryTeal, behavior: SnackBarBehavior.floating),
                            );
                          },
                          child: const Icon(Icons.copy, color: AppTheme.primaryTeal, size: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(child: AdminModeView(storeId: _selectedStoreId)),
          ],
        );
      }
      if (_selectedIndex == 1) {
        return FleetManagementScreen(
          onStoreCreated: (id, nome) {
            setState(() {
              _lastCreatedStoreId = id;
              _lastCreatedStoreName = nome;
            });
            _loadStores();
          },
        );
      }
      if (_selectedIndex == 2) {
        return StoreRegistrationScreen(
          onStoreCreated: (id, nome) {
            setState(() {
              _lastCreatedStoreId = id;
              _lastCreatedStoreName = nome;
            });
            _loadStores();
          },
        );
      }
      if (_selectedIndex == 3) {
        return _buildPlaceholder(Icons.history);
      }
      if (_selectedIndex == 4) {
        return const BillingScreen();
      }
      if (_selectedIndex == 5) {
        return _buildPlaceholder(Icons.query_stats);
      }
      if (_selectedIndex == 6) {
        return _buildPlaceholder(Icons.security_update_good);
      }
      if (_selectedIndex == 7) {
        return const ContractsView();
      }
      return const Center(child: Text('Tela em construção', style: TextStyle(color: AppTheme.textWhite)));
    } else {
      switch (_selectedIndex) {
        case 0:
          return UserModeView(
            storeId: _selectedUserStoreId,
            storeName: _selectedUserStoreName,
          );
        case 1:
          return InventoryView(storeId: _selectedUserStoreId);
        case 2:
          return StatisticsView(storeId: _selectedUserStoreId, showStoreSelector: false);
        case 3:
          return const LogisticsView();
        case 4:
          return StatisticsView(storeId: _selectedUserStoreId, showStoreSelector: false);
        default:
          return const Center(child: Text('Tela em construção', style: TextStyle(color: AppTheme.textWhite)));
      }
    }
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(bottom: BorderSide(color: AppTheme.accentGray, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isAdminMode ? _buildAdminHeader() : _buildUserHeader(),
          Row(
            children: [
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.darkPanel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF00FF00))),
                    const SizedBox(width: 6),
                    Text('Status: Última leitura ${TimeOfDay.now().format(context)}', style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Última loja cadastrada — badge clicável para copiar o ID (somente em Admin Mode)
              if (isAdminMode && _lastCreatedStoreId != null)
                Tooltip(
                  message: 'Clique para copiar o Store ID',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final id = _lastCreatedStoreId!;
                      await Clipboard.setData(ClipboardData(text: id));
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ID copiado: $id', style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppTheme.primaryTeal,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.teal10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppTheme.primaryTeal, size: 14),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _lastCreatedStoreName ?? 'Nova loja',
                                style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _lastCreatedStoreId!.length > 18
                                    ? '${_lastCreatedStoreId!.substring(0, 18)}…'
                                    : _lastCreatedStoreId!,
                                style: const TextStyle(color: AppTheme.textGray, fontSize: 9, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy, color: AppTheme.primaryTeal, size: 13),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_lastCreatedStoreId != null) const SizedBox(width: 8),
              // Loja selecionada (botão estilizado)
              if (isAdminMode && _selectedStoreName != null) _buildSelectedStoreButton(),
              if (!isAdminMode && _selectedUserStoreName != null) _buildUserSelectedStoreButton(),
              const SizedBox(width: 16),
              _buildModeToggle(),
              const SizedBox(width: 16),
              const Icon(Icons.notifications_none, color: AppTheme.textGray),
              const SizedBox(width: 12),
              const Icon(Icons.settings, color: AppTheme.textGray),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.logout, color: AppTheme.textGray),
                tooltip: 'Sair',
                onPressed: _handleLogout,
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentGray,
                ),
                child: const Icon(Icons.person, color: AppTheme.textWhite, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppTheme.primaryTeal),
          const SizedBox(height: 12),
          Text('Tela em Construção', style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return _buildAppTitle();
  }

  Widget _buildAdminHeader() {
    return Container(
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: AppTheme.textGray, size: 18),
          SizedBox(width: 8),
          Text('Procurar transação...', style: TextStyle(color: AppTheme.accentGray, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return InkWell(
      onTap: toggleMode,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isAdminMode ? AppTheme.teal20 : AppTheme.darkPanel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isAdminMode ? AppTheme.primaryTeal : AppTheme.accentGray),
        ),
        child: Row(
          children: [
            Icon(isAdminMode ? Icons.admin_panel_settings : Icons.person_outline, 
                 size: 16, color: isAdminMode ? AppTheme.primaryTeal : AppTheme.textWhite),
            const SizedBox(width: 6),
            Text(
              isAdminMode ? 'ADM MODE' : 'USER MODE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isAdminMode ? AppTheme.primaryTeal : AppTheme.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    if (supabaseAvailable) {
      await Supabase.instance.client.auth.signOut();
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _shortId(String id) {
    if (id.isEmpty) return '';
    if (id.length <= 14) return id;
    return '${id.substring(0, 8)}…${id.substring(id.length - 4)}';
  }

  /// Abre o modal de seleção de loja (reutilizável por desktop e mobile).
  Future<void> _openStoreSelector() async {
    setState(() => _isStoreSelectorOpen = true);
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        builder: (sheetCtx, scrollController) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkerPanel,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.18)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront, color: AppTheme.primaryTeal),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Selecionar Loja',
                        style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      icon: const Icon(Icons.close, color: AppTheme.textGray),
                    ),
                  ],
                ),
                const Divider(color: AppTheme.accentGray),
                Expanded(
                  child: _stores.isEmpty
                      ? const Center(
                          child: Text('Nenhuma loja cadastrada',
                              style: TextStyle(color: AppTheme.textGray)))
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: _stores.length,
                          separatorBuilder: (_, index) =>
                              const Divider(color: AppTheme.accentGray, height: 1),
                          itemBuilder: (listCtx, i) {
                            final s = _stores[i];
                            final id = '${s['id'] ?? ''}';
                            final name = '${s['nome_loja'] ?? id}';
                            final isSel = id == _selectedStoreId;
                            return ListTile(
                              leading: Icon(Icons.storefront,
                                  color: isSel ? AppTheme.primaryTeal : AppTheme.textWhite),
                              title: Text(name,
                                  style: TextStyle(
                                      color: isSel ? AppTheme.primaryTeal : AppTheme.textWhite)),
                              subtitle: Text(_shortId(id),
                                  style: const TextStyle(
                                      color: AppTheme.textGray, fontFamily: 'monospace')),
                              trailing:
                                  isSel ? const Icon(Icons.check, color: AppTheme.primaryTeal) : null,
                              onTap: () => Navigator.of(listCtx).pop(s),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );

    setState(() => _isStoreSelectorOpen = false);
    if (selected != null) {
      setState(() {
        _selectedStoreId = '${selected['id'] ?? ''}';
        _selectedStoreName = '${selected['nome_loja'] ?? _selectedStoreId}';
      });
    }
  }

  Future<void> _openUserStoreSelector() async {
    setState(() => _isUserStoreSelectorOpen = true);
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        minChildSize: 0.25,
        maxChildSize: 0.9,
        builder: (sheetCtx, scrollController) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkerPanel,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.18)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront, color: AppTheme.primaryTeal),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Selecionar Loja',
                        style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      icon: const Icon(Icons.close, color: AppTheme.textGray),
                    ),
                  ],
                ),
                const Divider(color: AppTheme.accentGray),
                Expanded(
                  child: _userStores.isEmpty
                      ? const Center(
                          child: Text('Nenhuma loja liberada para este CNPJ',
                              style: TextStyle(color: AppTheme.textGray)))
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: _userStores.length,
                          separatorBuilder: (_, index) =>
                              const Divider(color: AppTheme.accentGray, height: 1),
                          itemBuilder: (listCtx, i) {
                            final s = _userStores[i];
                            final id = '${s['id'] ?? ''}';
                            final name = '${s['nome_loja'] ?? id}';
                            final isSel = id == _selectedUserStoreId;
                            return ListTile(
                              leading: Icon(Icons.storefront,
                                  color: isSel ? AppTheme.primaryTeal : AppTheme.textWhite),
                              title: Text(name,
                                  style: TextStyle(
                                      color: isSel ? AppTheme.primaryTeal : AppTheme.textWhite)),
                              subtitle: Text(_shortId(id),
                                  style: const TextStyle(
                                      color: AppTheme.textGray, fontFamily: 'monospace')),
                              trailing:
                                  isSel ? const Icon(Icons.check, color: AppTheme.primaryTeal) : null,
                              onTap: () => Navigator.of(listCtx).pop(s),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );

    setState(() => _isUserStoreSelectorOpen = false);
    if (selected != null) {
      setState(() {
        _selectedUserStoreId = '${selected['id'] ?? ''}';
        _selectedUserStoreName = '${selected['nome_loja'] ?? _selectedUserStoreId}';
      });
    }
  }

  Widget _buildSelectedStoreButton() {
    final shortId = _shortId(_selectedStoreId ?? '');
    return InkWell(
      onTap: _openStoreSelector,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: _isStoreButtonPressed ? 0.985 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.darkPanel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(color: AppTheme.primaryTeal.withValues(alpha: 0.08), blurRadius: 18, spreadRadius: 2),
              BoxShadow(color: AppTheme.primaryTeal.withValues(alpha: 0.04), blurRadius: 36, spreadRadius: 8),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront, color: AppTheme.primaryTeal, size: 16),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedStoreName ?? '', style: const TextStyle(color: AppTheme.textWhite, fontSize: 12, fontWeight: FontWeight.w700)),
                  if (shortId.isNotEmpty) Text(shortId, style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontFamily: 'monospace'))
                ],
              ),
              const SizedBox(width: 10),
              AnimatedRotation(
                turns: _isStoreSelectorOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 280),
                child: const Icon(Icons.swap_horiz, color: AppTheme.primaryTeal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserSelectedStoreButton() {
    final shortId = _shortId(_selectedUserStoreId ?? '');
    return InkWell(
      onTap: _openUserStoreSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkPanel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront, color: AppTheme.primaryTeal, size: 16),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedUserStoreName ?? '', style: const TextStyle(color: AppTheme.textWhite, fontSize: 12, fontWeight: FontWeight.w700)),
                if (shortId.isNotEmpty) Text(shortId, style: const TextStyle(color: AppTheme.primaryTeal, fontSize: 11, fontFamily: 'monospace'))
              ],
            ),
            const SizedBox(width: 10),
            AnimatedRotation(
              turns: _isUserStoreSelectorOpen ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 280),
              child: const Icon(Icons.swap_horiz, color: AppTheme.primaryTeal),
            ),
          ],
        ),
      ),
    );
  }
}