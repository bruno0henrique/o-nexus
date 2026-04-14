import 'package:flutter/material.dart';
import 'package:nexus_engine/screens/login_screen.dart';
import 'package:nexus_engine/screens/main_application.dart';
import 'package:nexus_engine/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexus_engine/main.dart' show supabaseAvailable;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final hasSession = supabaseAvailable &&
        Supabase.instance.client.auth.currentSession != null;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            hasSession ? const MainApplication() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryTeal, width: 4),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'O NEXUS',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: AppTheme.primaryTeal,
                        blurRadius: 10,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'THE SYNTHETIC HORIZON',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textGray,
                    letterSpacing: 6,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SYSTEM.STATUS', style: TextStyle(fontSize: 10, color: AppTheme.textGray)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Terminal Active',
                          style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text('AUTHORIZED ACCESS ONLY', style: TextStyle(fontSize: 10, color: AppTheme.textGray)),
                Text('HORIZON-V2.04', style: TextStyle(fontSize: 10, color: AppTheme.textGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
