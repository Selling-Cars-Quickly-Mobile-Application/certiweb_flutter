import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('currentUser');
    if (s != null) {
      _user = jsonDecode(s);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), backgroundColor: const Color(0xFF1E4D2B)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF5F0E1), Color(0xFFEDE4D1)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E4D2B), Color(0xFF2D6B3F)]),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: const Text('Perfil', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            _row('Nombre', (_user?['name'] ?? 'No disponible').toString()),
                            const SizedBox(height: 12),
                            _row('Email', (_user?['email'] ?? 'No disponible').toString()),
                            const SizedBox(height: 12),
                            _row('Plan', (_user?['plan'] ?? 'No disponible').toString()),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'), child: const Text('Volver al inicio')),
                            )
                          ]),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E4D2B).withOpacity(0.2), width: 2)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Icon(Icons.person, color: Color(0xFF1E4D2B), size: 18),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E4D2B))))),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF495057), fontWeight: FontWeight.w500)))
      ]),
    );
  }
}