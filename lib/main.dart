import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexus_engine/theme/app_theme.dart';
import 'package:nexus_engine/screens/splash_screen.dart';

/// Flag global para indicar se o Supabase está disponível
bool supabaseAvailable = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // Inicializa Supabase com tratamento de erro para não travar o app
  // String.fromEnvironment lê --dart-define injetados pela Vercel em tempo de build;
  // como fallback, usa .env para desenvolvimento local.
  try {
    const buildUrl = String.fromEnvironment('SUPABASE_URL');
    const buildAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    final url = buildUrl.isNotEmpty ? buildUrl : (dotenv.env['SUPABASE_URL'] ?? '');
    final anonKey = buildAnonKey.isNotEmpty ? buildAnonKey : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');
    if (url.isNotEmpty && anonKey.isNotEmpty) {
      await Supabase.initialize(url: url, anonKey: anonKey)
          .timeout(const Duration(seconds: 8));
      supabaseAvailable = true;
    }
  } catch (e) {
    debugPrint('[NEXUS] Supabase offline – modo local ativo: $e');
  }

  runApp(const NexusEngineApp());
}

class NexusEngineApp extends StatelessWidget {
  const NexusEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Engine',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

//flutter run -d chrome  