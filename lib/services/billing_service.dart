import 'package:nexus_engine/services/supabase_client.dart';

/// Representa um registro da tabela [faturamento] com o nome da loja incluso via join.
class FaturamentoEntry {
  final String id;
  final String lojaId;
  final String nomeCliente;
  final String nomeLoja;
  final double valorTotal;
  final int parcelas;
  final int diaVencimento;
  final String status; // pendente | pago | cancelado
  final DateTime criadoEm;

  const FaturamentoEntry({
    required this.id,
    required this.lojaId,
    required this.nomeCliente,
    required this.nomeLoja,
    required this.valorTotal,
    required this.parcelas,
    required this.diaVencimento,
    required this.status,
    required this.criadoEm,
  });

  factory FaturamentoEntry.fromMap(Map<String, dynamic> m) {
    // O join retorna 'lojas': { 'nome': ... } se existir, ou null
    String nomeLoja = '—';
    if (m.containsKey('lojas') && m['lojas'] != null) {
      final loja = m['lojas'];
      if (loja is Map && loja['nome'] != null) {
        nomeLoja = loja['nome'] as String? ?? '—';
      }
    }
    return FaturamentoEntry(
      id: m['id'] as String? ?? '',
      lojaId: m['loja_id'] as String? ?? '',
      nomeCliente: m['nome_cliente'] as String? ?? '—',
      nomeLoja: nomeLoja,
      valorTotal: (m['valor_total'] as num?)?.toDouble() ?? 0.0,
      parcelas: m['parcelas'] as int? ?? 1,
      diaVencimento: m['dia_vencimento'] as int? ?? 1,
      status: m['status'] as String? ?? 'pendente',
      criadoEm: DateTime.tryParse(m['criado_em'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Totais agregados exibidos nos cards de resumo.
class FaturamentoResumo {
  final double totalPago;
  final double totalPendente;
  final int qtdPendente;
  final double taxaSucesso; // 0–100

  const FaturamentoResumo({
    required this.totalPago,
    required this.totalPendente,
    required this.qtdPendente,
    required this.taxaSucesso,
  });
}

class FaturamentoService {
  static const int pageSize = 10;

  /// Retorna registros de faturamento paginados, do mais recente ao mais antigo.
  /// Inclui o nome da loja via join com a tabela [lojas].
  Future<List<FaturamentoEntry>> fetchPaginado({int page = 0}) async {
    final client = supabase;
    // O join espera que a tabela lojas tenha a coluna 'nome'.
    final response = await client
      .from('faturamento')
      .select('*, lojas(nome)')
      .order('criado_em', ascending: false)
      .range(page * pageSize, (page + 1) * pageSize - 1);
    if (response is List) {
      return response.map((e) => FaturamentoEntry.fromMap(e as Map<String, dynamic>)).toList();
    } else {
      return [];
    }
  }

  /// Calcula os totais agregados consultando toda a tabela de faturamento.
  Future<FaturamentoResumo> fetchResumo() async {
    final client = supabase;
    final response = await client
      .from('faturamento')
      .select('valor_total, status');
    final all = (response as List).cast<Map<String, dynamic>>();

    double totalPago = 0;
    double totalPendente = 0;
    int qtdPendente = 0;

    for (final r in all) {
      final valor = (r['valor_total'] as num?)?.toDouble() ?? 0.0;
      final status = r['status'] as String? ?? 'pendente';
      if (status == 'pago') {
        totalPago += valor;
      } else if (status == 'pendente') {
        totalPendente += valor;
        qtdPendente++;
      }
    }

    final total = totalPago + totalPendente;
    final taxa = total > 0 ? (totalPago / total * 100) : 0.0;

    return FaturamentoResumo(
      totalPago: totalPago,
      totalPendente: totalPendente,
      qtdPendente: qtdPendente,
      taxaSucesso: taxa,
    );
  }

  /// Retorna o total de registros na tabela faturamento.
  Future<int> countTotal() async {
    final client = supabase;
    final response = await client.from('faturamento').select('id');
    return (response as List).length;
  }

  /// Retorna todas as lojas cadastradas para uso em dropdowns.
  Future<List<Map<String, dynamic>>> fetchLojas() async {
    final client = supabase;
    final response = await client
      .from('lojas')
      .select('id, nome')
      .order('nome', ascending: true);
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  /// Insere um novo registro de faturamento.
  Future<void> inserir({
    required String lojaId,
    required String nomeCliente,
    required double valorTotal,
    required int parcelas,
    required int diaVencimento,
    String status = 'pendente',
  }) async {
    final client = supabase;
    await client.from('faturamento').insert({
      'loja_id': lojaId,
      'nome_cliente': nomeCliente,
      'valor_total': valorTotal,
      'parcelas': parcelas,
      'dia_vencimento': diaVencimento,
      'status': status,
    });
  }

  /// Atualiza o status de um registro de faturamento.
  Future<void> atualizarStatus(String id, String novoStatus) async {
    final client = supabase;
    await client
      .from('faturamento')
      .update({'status': novoStatus}).eq('id', id);
  }
}
