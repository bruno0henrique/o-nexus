import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexus_engine/main.dart' show supabaseAvailable;

class AdminService {
  SupabaseClient? _client;

  AdminService() {
    // Tenta usar a instância global inicializada (anon key) se disponível.
    if (supabaseAvailable) {
      try {
        _client = Supabase.instance.client;
        return;
      } catch (e) {
        debugPrint('[AdminService] Falha ao obter cliente Supabase global: $e');
      }
    }

    // Se não houve inicialização global, tenta criar um cliente com SERVICE_ROLE_KEY caso exista.
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final serviceKey = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
    if (url.isNotEmpty && serviceKey.isNotEmpty) {
      try {
        _client = SupabaseClient(url, serviceKey);
      } catch (e) {
        debugPrint('[AdminService] Falha ao criar SupabaseClient com SERVICE_ROLE_KEY');
      }
    }
  }

  /// Busca IDs únicos de loja na tabela tabela_nexus.
  /// Retorna lista de maps com chave `loja_id`.
  Future<List<Map<String, dynamic>>> fetchMercadinhos() async {
    if (_client == null) {
      throw Exception('Supabase não disponível. Verifique sua conexão e credenciais.');
    }
    final response = await _client!
      .from('tabela_nexus')
      .select('loja_id')
      .order('loja_id', ascending: true);
    final rows = _normalizeResponse(response);
    // Deduplica por loja_id.
    final seen = <String>{};
    final unique = <Map<String, dynamic>>[];
    for (final row in rows) {
      final id = '${row['loja_id'] ?? ''}';
      if (id.isNotEmpty && seen.add(id)) {
        unique.add({'loja_id': id});
      }
    }
    return unique;
  }

  /// Busca registros da tabela tabela_nexus, filtrado por loja_id quando fornecido.
  Future<List<Map<String, dynamic>>> fetchAuditoria({String? mercadinhoId}) async {
    if (_client == null) {
      throw Exception('Supabase não disponível. Verifique sua conexão e credenciais.');
    }
    if (mercadinhoId == null || mercadinhoId.isEmpty) {
        final response = await _client!
          .from('tabela_nexus')
          .select()
          .order('sku_id', ascending: true);
      return _normalizeResponse(response);
    }
    final response = await _client!
      .from('tabela_nexus')
      .select()
      .eq('loja_id', mercadinhoId)
      .order('sku_id', ascending: true);
    return _normalizeResponse(response);
  }

  /// Busca lojas registradas na tabela `lojas` (id, nome_loja).
  Future<List<Map<String, dynamic>>> fetchStores() async {
    if (_client == null) {
      throw Exception('Supabase não disponível. Verifique sua conexão e credenciais.');
    }
    try {
      final response = await _client!
          .from('lojas')
          .select('id,nome_loja,url_contrato')
          .order('nome_loja', ascending: true);
      final rows = _normalizeResponse(response);
      return rows;
    } catch (e) {
      debugPrint('[AdminService] fetchStores error: ${e.toString()}');
      return <Map<String, dynamic>>[];
    }
  }

  /// Normaliza a resposta do Supabase para uma lista de mapas.
  /// Aceita várias formas que podem vir do cliente JS/Dart e retorna
  /// uma `List<Map<String,dynamic>>`. Se a resposta indicar erro,
  /// lança uma Exception com a mensagem apropriada.
  List<Map<String, dynamic>> _normalizeResponse(dynamic response) {
    if (response == null) return <Map<String, dynamic>>[];

    // Flutter Web: evitar chamar .map() diretamente em objetos JS wrapping Dart lists
    // pois isso lança "TypeError: Cannot read properties of undefined (reading 'Symbol(dartx.map)')"
    // Usar for-loop é seguro em todas as plataformas.
    if (response is List) {
      final result = <Map<String, dynamic>>[];
      for (final e in response) {
        if (e is Map) {
          result.add(Map<String, dynamic>.from(e));
        }
      }
      return result;
    }

    if (response is Map) {
      // Supabase JS envelope: { data: [...], error: null }
      final data = response['data'];
      if (data is List) {
        final result = <Map<String, dynamic>>[];
        for (final e in data) {
          if (e is Map) result.add(Map<String, dynamic>.from(e));
        }
        return result;
      }
      // Erro explícito
      final error = response['error'];
      if (error != null) throw Exception(error.toString());
      // Registro único
      try {
        return [Map<String, dynamic>.from(response)];
      } catch (_) {}
    }

    return <Map<String, dynamic>>[];
  }
}
