import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexus_engine/main.dart' show supabaseAvailable;
import 'package:nexus_engine/theme/app_theme.dart';

class StoreRegistrationScreen extends StatefulWidget {
  /// Chamado após cadastro bem-sucedido com (storeId, storeName).
  final void Function(String storeId, String storeName)? onStoreCreated;

  const StoreRegistrationScreen({super.key, this.onStoreCreated});

  @override
  State<StoreRegistrationScreen> createState() => _StoreRegistrationScreenState();
}

class _StoreRegistrationScreenState extends State<StoreRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isFetchingCep = false;

  final _razaoCtrl = TextEditingController();
  final _inscricaoCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _enderecoCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _gestorCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bairroCtrl = TextEditingController();
  final _inscricaoMunicipalCtrl = TextEditingController();
  final _telefoneSuporteCtrl = TextEditingController();
  late FocusNode _cepFocusNode;
  String _plano = 'Basic';
  String? _segmento;
  String? _uf;

  // Contrato PDF
  PlatformFile? _contratoFile;
  bool _isUploadingPdf = false;
  final List<String> _segmentos = ['Alimentos', 'Moda', 'Bebidas', 'Higiene'];
  final List<String> _ufs = [
    'AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'
  ];

  SupabaseClient? _client;

  @override
  void initState() {
    super.initState();
    // Inicializa _cepFocusNode cedo, garantindo que esteja pronto
    // mesmo que haja um retorno prematuro durante a inicialização.
    _cepFocusNode = FocusNode();
    _cepFocusNode.addListener(() {
      if (!_cepFocusNode.hasFocus) {
        final digits = _cepCtrl.text.replaceAll(RegExp(r'\D'), '');
        if (digits.length == 8) _fetchAddressFromCep(digits);
      }
    });
    // Prefer the globally initialized client quando disponível
    if (supabaseAvailable) {
      try {
        _client = Supabase.instance.client;
        return;
      } catch (_) {}
    }

    // Caso não exista inicialização global, tente construir com SERVICE_ROLE_KEY (dev mode)
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final serviceKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
    if (url.isNotEmpty && serviceKey.isNotEmpty) {
      try {
        _client = SupabaseClient(url, serviceKey);
      } catch (_) {}
    }
    // Focus node já inicializado no topo do initState
  }

  @override
  void dispose() {
    _contratoFile = null;
    _razaoCtrl.dispose();
    _inscricaoCtrl.dispose();
    _nomeCtrl.dispose();
    _cnpjCtrl.dispose();
    _enderecoCtrl.dispose();
    _numeroCtrl.dispose();
    _cepCtrl.dispose();
    _cidadeCtrl.dispose();
    _telefoneCtrl.dispose();
    _gestorCtrl.dispose();
    _emailCtrl.dispose();
    _bairroCtrl.dispose();
    _inscricaoMunicipalCtrl.dispose();
    _telefoneSuporteCtrl.dispose();
    _cepFocusNode.dispose();
    super.dispose();
  }


  // ── Submit ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_client == null) {
      _showSnackBar('Supabase não disponível. Verifique sua conexão.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Monta payload completo com os campos exibidos no formulário.
      // Upload do contrato PDF se selecionado
      String? contratoPublicUrl;
      if (_contratoFile != null) {
        final bytes = _contratoFile!.bytes;
        final fileName = _contratoFile!.name;
        if (bytes != null) {
          final path = 'contratos/${DateTime.now().millisecondsSinceEpoch}_$fileName';
          await _client!.storage.from('contratos').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'application/pdf', upsert: false),
          );
          contratoPublicUrl = _client!.storage.from('contratos').getPublicUrl(path);
        }
      }

      final payload = {
        'nome_loja': _nomeCtrl.text.trim(),
        'cnpj': _cnpjCtrl.text.trim(),
        'razao_social': _razaoCtrl.text.trim(),
        'inscricao_estadual': _inscricaoCtrl.text.trim(),
        'inscricao_municipal': _inscricaoMunicipalCtrl.text.trim(),
        'segmento': _segmento ?? '',
        'cep': _cepCtrl.text.trim(),
        'endereco': _enderecoCtrl.text.trim(),
        'bairro': _bairroCtrl.text.trim(),
        'numero': _numeroCtrl.text.trim(),
        'cidade': _cidadeCtrl.text.trim(),
        'uf': _uf ?? '',
        'gestor_responsavel': _gestorCtrl.text.trim(),
        'email_admin': _emailCtrl.text.trim(),
        'telefone': _telefoneCtrl.text.trim(),
        'telefone_suporte': _telefoneSuporteCtrl.text.trim(),
        'plano': _plano,
        'status_instancia': 'Ativo',
        if (contratoPublicUrl != null) 'url_contrato': contratoPublicUrl,
      };

      // Insere na tabela `lojas` — Supabase gera o UUID (id) automaticamente.
      // O backend (schema) pode ser ajustado depois para aceitar essas colunas.
      final inserted = await _client!.from('lojas').insert(payload).select('id,nome_loja').single();

      final storeId = '${inserted['id'] ?? ''}';

      if (!mounted) return;
      _showSnackBar('Loja cadastrada com sucesso! ID: $storeId');
      widget.onStoreCreated?.call(storeId, _nomeCtrl.text.trim());
      _formKey.currentState!.reset();
      _razaoCtrl.clear();
      _inscricaoCtrl.clear();
      _nomeCtrl.clear();
      _cnpjCtrl.clear();
      _cepCtrl.clear();
      _enderecoCtrl.clear();
      _numeroCtrl.clear();
      _cidadeCtrl.clear();
      _telefoneCtrl.clear();
      _gestorCtrl.clear();
      _emailCtrl.clear();
      _bairroCtrl.clear();
      _inscricaoMunicipalCtrl.clear();
      _telefoneSuporteCtrl.clear();
      setState(() {
        _plano = 'Basic';
        _segmento = null;
        _uf = null;
        _contratoFile = null;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao cadastrar: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: isError ? AppTheme.criticalRed : AppTheme.primaryTeal.withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: isError ? 5 : 4),
      ),
    );
  }

  Future<void> _onCepSearchPressed() async {
    final digits = _cepCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      _showSnackBar('Preencha o CEP com 8 dígitos', isError: true);
      return;
    }
    await _fetchAddressFromCep(digits);
  }

  Future<void> _fetchAddressFromCep(String cepDigits) async {
    if (_isFetchingCep) return;
    setState(() => _isFetchingCep = true);
    try {
      final uri = Uri.parse('https://viacep.com.br/ws/$cepDigits/json/');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) {
        _showSnackBar('Erro ao consultar CEP (status ${resp.statusCode})', isError: true);
        return;
      }
      final jsonBody = json.decode(resp.body);
      if (jsonBody == null || jsonBody is! Map || jsonBody['erro'] == true) {
        _showSnackBar('CEP não encontrado', isError: true);
        return;
      }

      final logradouro = (jsonBody['logradouro'] ?? '').toString();
      final bairro = (jsonBody['bairro'] ?? '').toString();
      final cidade = (jsonBody['localidade'] ?? '').toString();
      final uf = (jsonBody['uf'] ?? '').toString();

      if (!mounted) return;
      setState(() {
        if (logradouro.isNotEmpty) _enderecoCtrl.text = logradouro;
        if (bairro.isNotEmpty) _bairroCtrl.text = bairro;
        if (cidade.isNotEmpty) _cidadeCtrl.text = cidade;
        if (uf.isNotEmpty) _uf = uf;
      });
    } catch (e) {
      if (mounted) _showSnackBar('Falha ao buscar CEP: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isFetchingCep = false);
    }
  }

  // ── Validadores ───────────────────────────────────────────────────────

  String? _requiredField(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label é obrigatório';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email é obrigatório';
    final emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRe.hasMatch(v.trim())) return 'Email inválido';
    return null;
  }

  String? _validateCnpj(String? v) {
    if (v == null || v.trim().isEmpty) return 'CNPJ é obrigatório';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return 'CNPJ deve ter 14 dígitos';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Telefone é obrigatório';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Telefone inválido';
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 20,
                vertical: isWide ? 32 : 24,
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.darkPanel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.02),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormHeader(),
                        const SizedBox(height: 8),
                        const Text('Campos marcados com * são obrigatórios', style: TextStyle(color: AppTheme.textGray, fontSize: 12)),
                        const SizedBox(height: 20),
                        _buildSectionLabel('IDENTIFICAÇÃO FISCAL'),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _razaoCtrl,
                          label: 'Razão Social *',
                          hint: 'Nome jurídico da empresa',
                          icon: Icons.badge_rounded,
                          validator: (v) => _requiredField(v, 'Razão Social'),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _nomeCtrl,
                          label: 'Nome da Loja *',
                          hint: 'Nome fantasia da loja',
                          icon: Icons.store,
                          validator: (v) => _requiredField(v, 'Nome da Loja'),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _cnpjCtrl,
                          label: 'CNPJ *',
                          hint: '00.000.000/0000-00',
                          icon: Icons.business,
                          keyboardType: TextInputType.number,
                          inputFormatters: [_CnpjFormatter()],
                          validator: _validateCnpj,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _inscricaoCtrl,
                          label: 'Inscrição Estadual',
                          hint: 'Inscrição Estadual (se aplicável)',
                          icon: Icons.account_balance_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _inscricaoMunicipalCtrl,
                          label: 'Inscrição Municipal',
                          hint: 'Inscrição Municipal (se aplicável)',
                          icon: Icons.account_balance,
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          label: 'Segmento de Atuação *',
                          value: _segmento,
                          items: _segmentos,
                          icon: Icons.work_outline,
                          validator: (v) => v == null || v.isEmpty ? 'Escolha um segmento' : null,
                          onChanged: (v) => setState(() => _segmento = v),
                        ),

                        const SizedBox(height: 18),
                        _buildSectionLabel('LOCALIZAÇÃO'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _cepCtrl,
                                label: 'CEP *',
                                hint: '00000-000',
                                icon: Icons.place_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [_CepFormatter()],
                                validator: (v) => _requiredField(v, 'CEP'),
                                focusNode: _cepFocusNode,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: OutlinedButton(
                                onPressed: () => _onCepSearchPressed(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppTheme.primaryTeal.withValues(alpha: 0.25)),
                                  backgroundColor: AppTheme.darkerPanel,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: _isFetchingCep
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2.0, color: AppTheme.primaryTeal),
                                      )
                                    : Icon(Icons.search, color: AppTheme.primaryTeal, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _enderecoCtrl,
                          label: 'Logradouro / Endereço *',
                          hint: 'Rua, avenida, etc.',
                          icon: Icons.location_city,
                          validator: (v) => _requiredField(v, 'Endereço'),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _bairroCtrl,
                          label: 'Bairro',
                          hint: 'Bairro',
                          icon: Icons.map_outlined,
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 520;
                          if (narrow) {
                            return Column(
                              children: [
                                _buildTextField(
                                  controller: _numeroCtrl,
                                  label: 'Número *',
                                  hint: 'Nº',
                                  icon: Icons.format_list_numbered,
                                  validator: (v) => _requiredField(v, 'Número'),
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: _cidadeCtrl,
                                  label: 'Cidade *',
                                  hint: 'Cidade',
                                  icon: Icons.location_city_outlined,
                                  validator: (v) => _requiredField(v, 'Cidade'),
                                ),
                                const SizedBox(height: 12),
                                _buildDropdownField(
                                  label: 'UF *',
                                  value: _uf,
                                  items: _ufs,
                                  icon: Icons.map_outlined,
                                  validator: (v) => v == null || v.isEmpty ? 'Escolha UF' : null,
                                  onChanged: (v) => setState(() => _uf = v),
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _numeroCtrl,
                                  label: 'Número *',
                                  hint: 'Nº',
                                  icon: Icons.format_list_numbered,
                                  validator: (v) => _requiredField(v, 'Número'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: _buildTextField(
                                  controller: _cidadeCtrl,
                                  label: 'Cidade *',
                                  hint: 'Cidade',
                                  icon: Icons.location_city_outlined,
                                  validator: (v) => _requiredField(v, 'Cidade'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: _buildDropdownField(
                                  label: 'UF *',
                                  value: _uf,
                                  items: _ufs,
                                  icon: Icons.map_outlined,
                                  validator: (v) => v == null || v.isEmpty ? 'Escolha UF' : null,
                                  onChanged: (v) => setState(() => _uf = v),
                                ),
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 18),
                        _buildSectionLabel('CONTATO E GESTÃO'),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _gestorCtrl,
                          label: 'Gestor Responsável *',
                          hint: 'Nome do gestor',
                          icon: Icons.person_outline,
                          validator: (v) => _requiredField(v, 'Gestor'),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _emailCtrl,
                          label: 'Email Admin *',
                          hint: 'admin@exemplo.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _telefoneCtrl,
                          label: 'Telefone / WhatsApp *',
                          hint: '(00) 00000-0000',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_PhoneFormatter()],
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _telefoneSuporteCtrl,
                          label: 'Telefone Suporte',
                          hint: '(00) 00000-0000',
                          icon: Icons.support_agent_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [_PhoneFormatter()],
                        ),

                        const SizedBox(height: 18),
                        _buildSectionLabel('CONTRATO'),
                        const SizedBox(height: 12),
                        _buildContratoUploader(),
                        const SizedBox(height: 18),
                        _buildSectionLabel('CONFIGURAÇÕES DE PLANO'),
                        const SizedBox(height: 12),
                        _buildPlanSelector(),
                        const SizedBox(height: 14),
                        const Text('Status da instância será definido como Ativo por padrão', style: TextStyle(color: AppTheme.textGray, fontSize: 11)),
                        const SizedBox(height: 20),
                        _buildSubmitButton(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Componentes de UI ─────────────────────────────────────────────────

  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NOVA LOJA',
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.primaryTeal,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Processar Nova Loja',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.textWhite,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Cadastre um novo cliente no ecossistema Nexus.',
          style: TextStyle(color: AppTheme.textGray, fontSize: 12),
        ),
        const SizedBox(height: 16),
        const Divider(color: AppTheme.accentGray, height: 1),
      ],
    );
  }

  Widget _buildContratoUploader() {
    return InkWell(
      onTap: _isUploadingPdf
          ? null
          : () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
                withData: true,
              );
              if (result != null && result.files.isNotEmpty) {
                setState(() {
                  _contratoFile = result.files.single;
                });
              }
            },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _contratoFile != null
                ? AppTheme.primaryTeal
                : AppTheme.accentGray,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: AppTheme.darkerPanel,
        ),
        child: Row(
          children: [
            Icon(
              _contratoFile != null
                  ? Icons.picture_as_pdf
                  : Icons.attach_file,
              color: _contratoFile != null
                  ? AppTheme.primaryTeal
                  : AppTheme.textGray,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _contratoFile != null
                    ? _contratoFile!.name
                    : 'Selecionar PDF do contrato (opcional)',
                style: TextStyle(
                  color: _contratoFile != null
                      ? AppTheme.textWhite
                      : AppTheme.textGray,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_contratoFile != null)
              GestureDetector(
                onTap: () => setState(() {
                  _contratoFile = null;
                }),
                child: const Icon(Icons.close,
                    color: AppTheme.textGray, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.primaryTeal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppTheme.textGray, fontSize: 13),
        hintStyle: TextStyle(color: AppTheme.textGray.withValues(alpha: 0.5), fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primaryTeal, size: 18),
        filled: true,
        fillColor: AppTheme.darkerPanel,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.accentGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.accentGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primaryTeal),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.criticalRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.criticalRed),
        ),
        suffixIcon: suffixIcon,
        errorStyle: const TextStyle(color: AppTheme.criticalRed, fontSize: 11),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textGray, fontSize: 13),
        filled: true,
        fillColor: AppTheme.darkerPanel,
        prefixIcon: Icon(icon, color: AppTheme.primaryTeal, size: 18),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accentGray)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.accentGray)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primaryTeal)),
      ),
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildPlanSelector() {
    const plans = ['Basic', 'Pro', 'Enterprise'];
    const plansInfo = {
      'Basic': 'Até 500 SKUs',
      'Pro': 'Até 5.000 SKUs',
      'Enterprise': 'Ilimitado',
    };

    return LayoutBuilder(builder: (context, constraints) {
      final narrow = constraints.maxWidth < 520;
      final itemWidth = narrow ? double.infinity : (constraints.maxWidth - 20) / plans.length;

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(plans.length, (i) {
          return SizedBox(
            width: itemWidth,
            child: GestureDetector(
              onTap: () => setState(() => _plano = plans[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: _plano == plans[i] ? AppTheme.teal10 : AppTheme.darkerPanel,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _plano == plans[i] ? AppTheme.primaryTeal : AppTheme.accentGray,
                    width: _plano == plans[i] ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      plans[i],
                      style: TextStyle(
                        color: _plano == plans[i] ? AppTheme.primaryTeal : AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      plansInfo[plans[i]]!,
                      style: const TextStyle(color: AppTheme.textGray, fontSize: 11),
                    ),
                    if (_plano == plans[i]) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryTeal,
          foregroundColor: AppTheme.background,
          disabledBackgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppTheme.background,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_business, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'CADASTRAR LOJA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Input formatters ────────────────────────────────────────────────────

class _CnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 14) return oldValue;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5) buf.write('.');
      if (i == 8) buf.write('/');
      if (i == 12) buf.write('-');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) return oldValue;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) buf.write('(');
      if (i == 2) buf.write(') ');
      if (digits.length <= 10 && i == 6) buf.write('-');
      if (digits.length == 11 && i == 7) buf.write('-');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _CepFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 8) return oldValue;
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 5) buf.write('-');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
