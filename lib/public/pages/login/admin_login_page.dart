import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_auth_service.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AdminAuthService();
  String? _error;
  bool _loading = false;

  Future<void> _login() async {
    setState(() { _error = null; _loading = true; });
    try {
      final res = await _auth.login(_email.text.trim(), _password.text);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('adminToken');
      if (token != null && token.isNotEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/admin-certification');
        return;
      }
      setState(() => _error = 'Inicio de sesión fallido');
    } catch (e) {
      setState(() => _error = 'Credenciales inválidas');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Admin Login', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 16),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _loading ? null : _login, child: Text(_loading ? 'Ingresando...' : 'Ingresar')),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('Volver al login de usuario')),
            ],
          ),
        ),
      ),
    );
  }
}