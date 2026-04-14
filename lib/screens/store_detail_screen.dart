import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexus_engine/main.dart' show supabaseAvailable;
import 'package:nexus_engine/theme/app_theme.dart';

class StoreDetailScreen extends StatefulWidget {
  final Map<String, dynamic> store;
  final VoidCallback? onUpdated;

  const StoreDetailScreen({super.key, required this.store, this.onUpdated});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  bool _isSaving = false;
  bool _isUploading = false;
  SupabaseClient? _client;
  // Controllers dinâmicos para demais campos da tabela `lojas`
  final Map<String, TextEditingController> _otherCtrls = {};
  Map<String, dynamic> _storeData = {};
  final Set<String> _readOnlyKeys = {'id', 'created_at'};

  // Stats da loja (tabela_nexus)
  int _totalSkus = 0;
  double _estoqueTotal = 0;
  double _valorTotal = 0;
  bool _loadingStats = true;

  String get _storeId => '${widget.store['id'] ?? ''}';
  String get _storeName => '${widget.store['nome_loja'] ?? 'Loja'}';

  @override
  void initState() {
    super.initState();
    _storeData = Map<String, dynamic>.from(widget.store);
    _nomeCtrl.text = '${_storeData['nome_loja'] ?? ''}';
    _cnpjCtrl.text = '${_storeData['cnpj'] ?? ''}';
    _initClient();
    _initControllersFromStore(_storeData);
    // Tenta buscar versão mais recente no Supabase e carrega estatísticas
    _fetchStoreFromDb();
    _loadStats();
  }

  @override
  void didUpdateWidget(covariant StoreDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = oldWidget.store['id']?.toString();
    final newId = widget.store['id']?.toString();
    if (oldId != newId) {
      _storeData = Map<String, dynamic>.from(widget.store);
      _nomeCtrl.text = '${_storeData['nome_loja'] ?? ''}';
      _cnpjCtrl.text = '${_storeData['cnpj'] ?? ''}';
      _disposeOtherCtrls();
      _initControllersFromStore(_storeData);
      _initClient();
      _fetchStoreFromDb();
      _loadStats();
    }
  }

  void _initClient() {
    if (supabaseAvailable) {
      try {
        _client = Supabase.instance.client;
        return;
      } catch (_) {}
    }
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
    if (url.isNotEmpty && key.isNotEmpty) {
      try {
        _client = SupabaseClient(url, key);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cnpjCtrl.dispose();
    _disposeOtherCtrls();
    super.dispose();
  }

  void _disposeOtherCtrls() {
    for (final c in _otherCtrls.values) {
      c.dispose();
    }
    _otherCtrls.clear();
  }

  void _initControllersFromStore(Map<String, dynamic> store) {
    // Gera controllers para todas as colunas exceto id, nome_loja e cnpj
    for (final entry in store.entries) {
      final key = entry.key;
      if (key == 'id' || key == 'nome_loja' || key == 'cnpj') continue;
      final value = entry.value;
      _otherCtrls[key] = TextEditingController(text: value == null ? '' : value.toString());
    }
  }

  Future<void> _fetchStoreFromDb() async {
    if (_client == null || _storeId.isEmpty) {
      if (mounted) setState(() {});
      return;
    }
    try {
      final res = await _client!.from('lojas').select().eq('id', _storeId).maybeSingle();
      if (res is Map) {
        final map = Map<String, dynamic>.from(res as Map);
        if (mounted) {
          setState(() {
            _storeData = map;
            // atualiza controllers principais e adicionais
            _nomeCtrl.text = map['nome_loja']?.toString() ?? '';
            _cnpjCtrl.text = map['cnpj']?.toString() ?? '';
            _disposeOtherCtrls();
            _initControllersFromStore(map);
          });
        }
      } else {
        if (mounted) setState(() {});
      }
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  // ── Carrega estatísticas reais da loja na tabela_nexus ─────────────────────
  Future<void> _loadStats() async {
    if (_client == null || _storeId.isEmpty) {
      setState(() => _loadingStats = false);
      return;
    }
    try {
      final rows = await _client!
          .from('tabela_nexus')
          .select('estoque_atual,preco_venda')
          .eq('loja_id', _storeId);
      final list = List<Map<String, dynamic>>.from(rows as List);
      double est = 0, val = 0;
      for (final r in list) {
        final q = (r['estoque_atual'] ?? 0) as num;
        final p = (r['preco_venda'] ?? 0) as num;
        est += q;
        val += q * p;
      }
      if (mounted) {
        setState(() {
          _totalSkus = list.length;
          _estoqueTotal = est.toDouble();
          _valorTotal = val.toDouble();
          _loadingStats = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  // ── Salva alterações na tabela lojas ───────────────────────────────────────
  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;
    if (_client == null) {
      _showPopup(success: false, message: 'Supabase não disponível.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final payload = <String, dynamic>{
        'nome_loja': _nomeCtrl.text.trim(),
        'cnpj': _cnpjCtrl.text.trim(),
      };

      // Inclui demais campos editáveis
      _otherCtrls.forEach((key, ctrl) {
        if (_readOnlyKeys.contains(key)) return;
        final orig = _storeData.containsKey(key) ? _storeData[key] : null;
        final raw = ctrl.text.trim();
        if (orig is num) {
          payload[key] = double.tryParse(raw.replaceAll(',', '.')) ?? 0;
        } else if (orig is bool) {
          payload[key] = raw.toLowerCase() == 'true';
        } else if (orig is DateTime) {
          final parsed = DateTime.tryParse(raw);
          payload[key] = parsed?.toIso8601String() ?? raw;
        } else {
          payload[key] = raw.isEmpty ? null : raw;
        }
      });

      await _client!.from('lojas').update(payload).eq('id', _storeId);
      if (!mounted) return;
      await _fetchStoreFromDb();
      _showPopup(success: true, message: 'Loja "${payload['nome_loja']}" atualizada com sucesso!');
      widget.onUpdated?.call();
    } catch (e) {
      if (mounted) _showPopup(success: false, message: 'Erro ao salvar:\n$e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Upload e importação de CSV ─────────────────────────────────────────────
  Future<void> _uploadCsv() async {
    if (_client == null) {
      _showPopup(success: false, message: 'Supabase não disponível.');
      return;
    }

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
    } catch (e) {
      if (mounted) _showPopup(success: false, message: 'Erro ao abrir seletor:\n$e');
      return;
    }

    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null) {
      _showPopup(success: false, message: 'Não foi possível ler o arquivo.');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final content = utf8.decode(bytes, allowMalformed: true);
      final eol = content.contains('\r\n')
          ? '\r\n'
          : content.contains('\r')
              ? '\r'
              : '\n';

      final rows = CsvToListConverter(eol: eol, shouldParseNumbers: false)
          .convert(content);

      if (rows.isEmpty) {
        _showPopup(success: false, message: 'Arquivo CSV vazio.');
        setState(() => _isUploading = false);
        return;
      }

      // Normaliza cabeçalhos
      final headers = rows.first
          .map((h) => h.toString().trim().toLowerCase().replaceAll(' ', '_'))
          .toList();

      // Mapeamento flexível de nomes alternativos → coluna do banco
      const colMap = <String, String>{
        'sku_id': 'sku_id',
        'sku': 'sku_id',
        'cod': 'sku_id',
        'codigo': 'sku_id',
        'código': 'sku_id',
        'produto': 'produto',
        'produto_nome': 'produto',
        'descricao': 'produto',
        'descrição': 'produto',
        'description': 'produto',
        'categoria': 'categoria',
        'category': 'categoria',
        'cat': 'categoria',
        'preco_custo': 'preco_custo',
        'custo': 'preco_custo',
        'preco_venda': 'preco_venda',
        'venda': 'preco_venda',
        'preco': 'preco_venda',
        'price': 'preco_venda',
        'estoque_atual': 'estoque_atual',
        'estoque': 'estoque_atual',
        'qty': 'estoque_atual',
        'quantidade': 'estoque_atual',
        'stock': 'estoque_atual',
        'giro_30d': 'giro_30d',
        'giro': 'giro_30d',
        'data_vencimento': 'data_vencimento',
        'vencimento': 'data_vencimento',
        'validade': 'data_vencimento',
        'expiry': 'data_vencimento',
      };

      // Mapeia índice da coluna pelo nome mapeado
      final colIndices = <String, int>{};
      for (int i = 0; i < headers.length; i++) {
        final mapped = colMap[headers[i]];
        if (mapped != null) colIndices[mapped] = i;
      }

      const numericCols = {
        'preco_custo',
        'preco_venda',
        'estoque_atual',
        'giro_30d'
      };

      // Monta registros; loja_id sempre é o desta tela
      final records = <Map<String, dynamic>>[];
      for (int r = 1; r < rows.length; r++) {
        final row = rows[r];
        if (row.every((v) => v.toString().trim().isEmpty)) continue;
        final rec = <String, dynamic>{'loja_id': _storeId};
        colIndices.forEach((col, idx) {
          if (idx < row.length) {
            final raw = row[idx].toString().trim();
            if (numericCols.contains(col)) {
              rec[col] = double.tryParse(raw.replaceAll(',', '.')) ?? 0.0;
            } else {
              rec[col] = raw.isEmpty ? null : raw;
            }
          }
        });
        if (rec['sku_id'] != null) records.add(rec);
      }

      if (records.isEmpty) {
        _showPopup(
          success: false,
          message:
              'Nenhum registro válido encontrado.\n\n'
              'Verifique se o CSV possui coluna sku_id (ou: sku, cod, código).',
        );
        setState(() => _isUploading = false);
        return;
      }

      // Upsert em lotes de 100 (sku_id + loja_id = chave composta)
      const batchSize = 100;
      int total = 0;
      for (int i = 0; i < records.length; i += batchSize) {
        final batch =
            records.sublist(i, (i + batchSize).clamp(0, records.length));
        await _client!
            .from('tabela_nexus')
            .upsert(batch, onConflict: 'sku_id,loja_id');
        total += batch.length;
      }

      if (!mounted) return;
      _showPopup(
        success: true,
        message: '$total registros sincronizados com sucesso para\n"$_storeName"!',
      );
      _loadStats();
    } catch (e) {
      if (mounted) _showPopup(success: false, message: 'Erro ao importar CSV:\n$e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Popup neon de sucesso/erro ─────────────────────────────────────────────
  void _showPopup({required bool success, required String message}) {
    final color = success ? AppTheme.primaryTeal : AppTheme.criticalRed;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color, width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              success ? 'Sucesso' : 'Erro',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(message,
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK',
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.darkerPanel,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.textWhite, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _storeName,
              style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              _storeId.isEmpty
                  ? ''
                  : '#${_storeId.substring(0, _storeId.length >= 8 ? 8 : _storeId.length).toUpperCase()}',
              style: const TextStyle(
                  color: AppTheme.primaryTeal,
                  fontSize: 11,
                  fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: AppTheme.primaryTeal, strokeWidth: 2),
              ),
            ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.accentGray),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final wide = constraints.maxWidth > 700;
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildEditForm()),
                    const SizedBox(width: 20),
                    Expanded(flex: 4, child: _buildCsvSection()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildEditForm(),
                  const SizedBox(height: 20),
                  _buildCsvSection(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Stats ──────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 520;

      final cards = [
        _statCard(
          'Total de SKUs',
          _loadingStats ? '...' : '$_totalSkus',
          Icons.inventory_2_outlined,
          AppTheme.primaryTeal,
        ),
        _statCard(
          'Estoque Total',
          _loadingStats ? '...' : '${_estoqueTotal.toStringAsFixed(0)} un',
          Icons.warehouse_outlined,
          AppTheme.primaryTeal,
        ),
        _statCard(
          'Valor em Estoque',
          _loadingStats ? '...' : 'R\$ ${_fmtVal(_valorTotal)}',
          Icons.attach_money,
          AppTheme.warningOrange,
        ),
      ];

      if (!narrow) {
        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i < cards.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      }

      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    });
  }

  String _fmtVal(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(2);
  }

  Widget _statCard(String label, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textGray, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Formulário de edição ────────────────────────────────────────────────────
  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGray),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('INFORMAÇÕES DA LOJA'),
            const SizedBox(height: 18),
            _formField(
              'Nome da Loja',
              _nomeCtrl,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            _formField('CNPJ', _cnpjCtrl),
            const SizedBox(height: 12),

            // Campos dinâmicos adicionais  
            if (_otherCtrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Outras informações', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
              const SizedBox(height: 8),
              ..._otherCtrls.entries.map((e) {
                final key = e.key;
                final ctrl = e.value;
                final label = key.replaceAll('_', ' ').toUpperCase();
                final readOnly = _readOnlyKeys.contains(key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _formField(label, ctrl, readOnly: readOnly),
                );
              }),
            ],

            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              final narrow = constraints.maxWidth < 420;
              final button = ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveStore,
                icon: _isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            color: AppTheme.background, strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt, size: 16),
                label: const Text('Salvar Alterações'),
              );
              return narrow
                  ? SizedBox(width: double.infinity, child: button)
                  : Align(alignment: Alignment.centerRight, child: button);
            }),
          ],
        ),
      ),
    );
  }

  // ── Seção de upload CSV ────────────────────────────────────────────────────
  Widget _buildCsvSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('SINCRONIZAÇÃO DE DADOS'),
          const SizedBox(height: 4),
          const Text(
            'Importe um CSV para sincronizar o inventário no Supabase. '
            'A coluna sku_id é obrigatória. Os dados serão vinculados '
            'exclusivamente a esta loja.',
            style: TextStyle(color: AppTheme.textGray, fontSize: 11),
          ),
          const SizedBox(height: 18),

          // Área de drop / clique
          GestureDetector(
            onTap: _isUploading ? null : _uploadCsv,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppTheme.darkerPanel,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isUploading
                      ? AppTheme.primaryTeal
                      : AppTheme.primaryTeal.withValues(alpha: 0.30),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _isUploading
                        ? Icons.sync_rounded
                        : Icons.upload_file_rounded,
                    color: AppTheme.primaryTeal,
                    size: 36,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isUploading
                        ? 'Enviando dados para o Supabase…'
                        : 'Clique para selecionar um arquivo CSV',
                    style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Formato aceito: .csv',
                    style:
                        TextStyle(color: AppTheme.textGray, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dica de colunas esperadas
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Colunas esperadas  (* = obrigatória)',
                  style: TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    'sku_id*',
                    'produto',
                    'categoria',
                    'preco_custo',
                    'preco_venda',
                    'estoque_atual',
                    'giro_30d',
                    'data_vencimento',
                  ].map((col) {
                    final req = col.endsWith('*');
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: req
                            ? AppTheme.teal10
                            : AppTheme.accentGray.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                        border: req
                            ? Border.all(
                                color: AppTheme.primaryTeal
                                    .withValues(alpha: 0.4))
                            : null,
                      ),
                      child: Text(
                        col,
                        style: TextStyle(
                            color: req
                                ? AppTheme.primaryTeal
                                : AppTheme.textGray,
                            fontSize: 10,
                            fontFamily: 'monospace'),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets auxiliares ─────────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
              color: AppTheme.primaryTeal,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
      ],
    );
  }

  Widget _formField(String label, TextEditingController ctrl,
      {bool readOnly = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textGray, fontSize: 11, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          readOnly: readOnly,
          style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.darkerPanel,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.accentGray)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.accentGray)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryTeal)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.criticalRed)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.criticalRed)),
          ),
        ),
      ],
    );
  }
}
