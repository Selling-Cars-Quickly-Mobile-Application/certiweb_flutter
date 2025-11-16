import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _rememberMe = false;
  bool _loading = false;
  String? _error;
  String? _success;
  final _auth = AuthService();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F0E1), Color(0xFFEDE4D1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E4D2B), Color(0xFF2D6B3F)],
                        ),
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Text(
                            'Iniciar sesión',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 28,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            _email,
                            'Correo electrónico',
                            'correo@ejemplo.com',
                            keyboardType: TextInputType.emailAddress,
                            icon: Icons.mail_outline,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            _password,
                            'Contraseña',
                            '••••••••',
                            icon: Icons.lock_outline,
                            obscureText: true,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      activeColor: const Color(0xFF1E4D2B),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Recordarme',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    color: Color(0xFF1E4D2B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (_error != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5252).withValues(alpha: 0.1),
                                border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Color(0xFFFF5252), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: Color(0xFFFF5252),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_success != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _success!,
                                      style: const TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1E4D2B), Color(0xFF2D6B3F)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E4D2B).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _loading ? 'Iniciando sesión...' : 'Entrar',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              const Text(
                                '¿No tienes cuenta?',
                                style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  backgroundColor: const Color(0xFF1E4D2B).withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'Regístrate',
                                  style: TextStyle(
                                    color: Color(0xFF1E4D2B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController c,
    String label,
    String hint, {
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: c,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF6B7280)) : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E4D2B), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ],
    );
  }

  bool _isEmail(String s) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);

  Future<void> _handleLogin() async {
    setState(() { _error = null; _success = null; _loading = true; });
    try {
      if (_email.text.isEmpty || _password.text.isEmpty || !_isEmail(_email.text)) {
        setState(() { _error = 'Por favor, completa los campos con datos válidos.'; _loading = false; });
        return;
      }
      final userResult = await _auth.login(_email.text, _password.text);
      if (userResult['success'] == true) {
        setState(() { _success = 'Inicio de sesión exitoso'; });
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
        return;
      }
      final adminResult = await _auth.loginAdmin(_email.text, _password.text);
      if (adminResult['success'] == true) {
        setState(() { _success = 'Inicio de sesión de administrador'; });
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
        return;
      }
      setState(() { _error = 'Credenciales incorrectas. Verifica correo y contraseña.'; });
    } catch (e) {
      setState(() { _error = 'Error de conexión. Intenta de nuevo.'; });
    } finally {
      setState(() { _loading = false; });
    }
  }
}