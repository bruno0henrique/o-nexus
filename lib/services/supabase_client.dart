import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Instância global do cliente Supabase.
/// Use [supabase] para acessar o cliente em qualquer parte do app.
///
/// As credenciais são lidas automaticamente do arquivo `.env`:
///   SUPABASE_URL e SUPABASE_ANON_KEY
SupabaseClient get supabase => Supabase.instance.client;

/// Retorna a URL do Supabase configurada no .env
String get supabaseUrl => dotenv.env['SUPABASE_URL']!;

/// Retorna a chave anônima do Supabase configurada no .env
String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
