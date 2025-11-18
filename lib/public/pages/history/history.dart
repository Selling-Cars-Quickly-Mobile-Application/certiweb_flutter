import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../certifications/services/reservation_service.dart';
import 'history-item/history-item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _service = ReservationService();
  List<Map<String, dynamic>> _reservations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final sUser = prefs.getString('currentUser');
      final sSession = prefs.getString('currentSession');
      int? userId;
      if (sUser != null) {
        final u = jsonDecode(sUser);
        userId = (u['id'] as num?)?.toInt();
      }
      if (userId == null && sSession != null) {
        final sess = jsonDecode(sSession);
        userId = (sess['userId'] as num?)?.toInt();
      }
      if (userId == null) {
        _error = 'No se pudo verificar el usuario. Por favor, inicie sesión.';
      } else {
        _reservations = await _service.getReservationsByUserId(userId);
      }
    } catch (e) {
      _error = 'No se pudo cargar el historial. Inténtalo más tarde.';
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial'), backgroundColor: const Color(0xFF1E4D2B)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Text('Historial de Reservas', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E4D2B))),
            const SizedBox(height: 24),
            if (_loading)
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                SizedBox(width: 50, height: 50, child: CircularProgressIndicator(strokeWidth: 4)),
                SizedBox(height: 12),
                Text('Cargando historial...')
              ]))
            else if (_error != null)
              Expanded(child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)], border: Border.all(color: Colors.black.withOpacity(0.05))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 32),
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center)
                ]),
              ))
            else if (_reservations.isEmpty)
              Expanded(child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)], border: Border.all(color: Colors.black.withOpacity(0.05))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.inbox, color: Color(0xFF3b82f6), size: 32),
                  const SizedBox(height: 8),
                  const Text('No hay reservas en tu historial'),
                ]),
              ))
            else
              Expanded(child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.9, crossAxisSpacing: 16, mainAxisSpacing: 16),
                itemCount: _reservations.length,
                itemBuilder: (context, i) => HistoryItemWidget(reservation: _reservations[i]),
              ))
          ]),
        ),
      ),
    );
  }
}