import 'package:flutter/material.dart';
import '../../../services/reservation_service.dart';

class AcceptReservationWidget extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onAccepted;
  const AcceptReservationWidget({super.key, required this.onAccepted});
  @override
  State<AcceptReservationWidget> createState() => _AcceptReservationWidgetState();
}

class _AcceptReservationWidgetState extends State<AcceptReservationWidget> {
  final _service = ReservationService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _pending = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final all = await _service.getAllReservations();
      setState(() {
        _pending = all.where((r) => (r['status'] ?? '') == 'pending').toList();
      });
    } catch (e) {
      setState(() => _error = 'Error cargando reservas');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _accept(Map<String, dynamic> r) async {
    try {
      await _service.updateReservationStatus(r['id'], 'accepted');
      widget.onAccepted({...r, 'status': 'accepted'});
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva aceptada'), backgroundColor: Color(0xFF10b981)),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al aceptar'), backgroundColor: Color(0xFFef4444)),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Color(0xFF3b82f6)),
            const SizedBox(height: 12),
            const Text('Cargando reservas...', style: TextStyle(color: Color(0xFF64748b))),
          ],
        ),
      );
    }
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFfee2e2),
          border: Border.all(color: const Color(0xFFef4444)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFef4444), size: 32),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Color(0xFFdc2626), fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFef4444)),
            ),
          ],
        ),
      );
    }
    if (_pending.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: const Color(0xFF94a3b8)),
            const SizedBox(height: 12),
            const Text('No hay reservas pendientes', style: TextStyle(color: Color(0xFF64748b), fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Row(
        children: List.generate(_pending.length, (i) {
          final r = _pending[i];
          return Padding(
            padding: EdgeInsets.only(right: i < _pending.length - 1 ? 16 : 0),
            child: SizedBox(
              width: 320,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF3b82f6), Color(0xFF8b5cf6)]),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_car, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              r['reservationName']?.toString() ?? 'N/A',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Marca', r['brand']?.toString() ?? 'N/A'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Modelo', r['model']?.toString() ?? 'N/A'),
                          const SizedBox(height: 8),
                          _buildInfoRow('Placa', r['licensePlate']?.toString() ?? 'N/A', isBold: true),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _accept(r),
                              icon: const Icon(Icons.check),
                              label: const Text('Aceptar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10b981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          );
        }),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748b), fontWeight: FontWeight.w600, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1e293b),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            fontSize: 13,
            backgroundColor: isBold ? const Color(0xFFF1F5F9) : null,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}