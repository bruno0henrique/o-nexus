import 'package:flutter/material.dart';
import 'package:nexus_engine/screens/main_application.dart';
import 'package:nexus_engine/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexus_engine/main.dart' show supabaseAvailable;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (!supabaseAvailable) {
      setState(() {
        _errorMessage = 'Supabase indisponivel no momento. Verifique a configuracao.';
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Preencha email e senha para continuar.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainApplication()),
      );
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Nao foi possivel autenticar agora. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'O NEXUS',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textWhite,
                            letterSpacing: 2),
                      ),
                      Text(
                        'SYNTHETIC HORIZON PROTOCOL',
                        style: TextStyle(fontSize: 10, color: AppTheme.textGray, letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 64),
                Container(
                  width: 400,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.darkPanel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accentGray), // Removed withOpacity
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.teal10,
                        blurRadius: 40,
                        spreadRadius: -10,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Terminal Access',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
                          ),
                          Icon(Icons.security, color: AppTheme.primaryTeal, size: 32),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Authorized personnel only. Please verify identity.',
                        style: TextStyle(color: AppTheme.textGray, fontSize: 12),
                      ),
                      const SizedBox(height: 32),
                      const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 10, color: AppTheme.textGray, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: AppTheme.textWhite),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                        decoration: InputDecoration(
                          hintText: 'operator@nexus.horizon',
                          hintStyle: const TextStyle(color: AppTheme.accentGray),
                          prefixIcon: const Icon(Icons.alternate_email, color: AppTheme.textGray),
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('PASSWORD', style: TextStyle(fontSize: 10, color: AppTheme.textGray, letterSpacing: 1.5)),
                          Text('FORGOT PASSWORD?', style: TextStyle(fontSize: 10, color: AppTheme.primaryTeal, letterSpacing: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppTheme.textWhite),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          hintText: '• • • • • • • • • • •',
                          hintStyle: const TextStyle(color: AppTheme.accentGray),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textGray),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: AppTheme.textGray),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        ),
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(_errorMessage, style: const TextStyle(color: AppTheme.criticalRed, fontSize: 12)),
                        ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: AppTheme.background,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoading) ...[
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppTheme.background,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text('ENTRANDO...', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              ] else ...[
                                const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: RichText(
                          text: const TextSpan(
                            text: 'New to the system? ',
                            style: TextStyle(color: AppTheme.textGray, fontSize: 12),
                            children: [
                              TextSpan(
                                text: 'Request Access',
                                style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        color: AppTheme.darkerPanel,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('© 2024 O NEXUS SYNTHETIC HORIZON', style: TextStyle(color: AppTheme.textGray, fontSize: 10)),
            Row(
              children: [
                Text('PRIVACY POLICY', style: TextStyle(color: AppTheme.textGray, fontSize: 10, letterSpacing: 1)),
                SizedBox(width: 16),
                Text('TERMS OF SERVICE', style: TextStyle(color: AppTheme.textGray, fontSize: 10, letterSpacing: 1)),
                SizedBox(width: 16),
                Text('SYSTEM STATUS', style: TextStyle(color: AppTheme.textGray, fontSize: 10, letterSpacing: 1)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
