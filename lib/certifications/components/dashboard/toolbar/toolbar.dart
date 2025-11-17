import 'package:flutter/material.dart';
import '../../../../public/services/auth_service.dart';
import '../../../services/user_service.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({super.key});
  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  String _userName = 'Usuario';
  final _userService = UserService();
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final u = await _userService.getCurrentUser();
      setState(() => _userName = (u['name'] ?? 'Usuario').toString());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1e4d2b), Color(0xFF2d5a3d)]),
      ),
      child: Row(
        children: [
          Row(
            children: const [
              Icon(Icons.directions_car, color: Colors.white),
              SizedBox(width: 8),
              Text('CertiWeb', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white),
              const SizedBox(width: 8),
              Text(_userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              _auth.logout();
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }
}