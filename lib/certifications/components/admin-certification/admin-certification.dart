import 'package:flutter/material.dart';
import 'accept-reservation/accept-reservation.dart';
import 'ad-form/ad-form.dart';
import 'upload-certification/upload-certification.dart';
import '../../../public/services/admin_auth_service.dart';

class AdminCertificationPage extends StatefulWidget {
  const AdminCertificationPage({super.key});
  @override
  State<AdminCertificationPage> createState() => _AdminCertificationPageState();
}

class _AdminCertificationPageState extends State<AdminCertificationPage> with TickerProviderStateMixin {
  Map<String, dynamic>? _acceptedReservation;
  Map<String, dynamic>? _createdCar;
  int? _createdCarId;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onAccepted(Map<String, dynamic> r) {
    setState(() { _acceptedReservation = r; _createdCarId = null; _createdCar = null; });
  }

  void _onSavedCar(Map<String, dynamic> car) {
    setState(() { 
      _createdCarId = int.tryParse(car['id']?.toString() ?? '') ?? car['id']; 
      _createdCar = car;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auto guardado exitosamente'),
        backgroundColor: Color(0xFF10b981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logout() async {
    await AdminAuthService().logout();
    if (mounted) Navigator.pushReplacementNamed(context, '/admin-login');
  }

  int get _completedSteps {
    int steps = 0;
    if (_acceptedReservation != null) steps++;
    if (_createdCarId != null) steps++;
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Administración de Certificaciones', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Color(0xFFef4444)),
              tooltip: 'Cerrar sesión',
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF3b82f6), Color(0xFF8b5cf6)]),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: const Color(0xFF3b82f6).withOpacity(0.3), blurRadius: 20)],
                                ),
                                child: const Icon(Icons.settings, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Proceso de Certificación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
                                    const SizedBox(height: 4),
                                    Text('Paso $_completedSteps de 3', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748b))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Progress steps
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildProgressStep(1, 'Aceptar', _acceptedReservation != null, _completedSteps > 0 && _acceptedReservation == null),
                          Container(width: 40, height: 3, color: _acceptedReservation != null ? const Color(0xFF10b981) : const Color(0xFFe2e8f0), margin: const EdgeInsets.symmetric(horizontal: 8)),
                          _buildProgressStep(2, 'Guardar', _createdCarId != null, _acceptedReservation != null && _createdCarId == null),
                          Container(width: 40, height: 3, color: _createdCarId != null ? const Color(0xFF10b981) : const Color(0xFFe2e8f0), margin: const EdgeInsets.symmetric(horizontal: 8)),
                          _buildProgressStep(3, 'Subir PDF', false, _createdCarId != null),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Step 1: Accept Reservation
              _buildStepCard(
                stepNumber: 1,
                title: 'Aceptar Reserva',
                isCompleted: _acceptedReservation != null,
                isLocked: false,
                child: AcceptReservationWidget(onAccepted: _onAccepted),
              ),
              const SizedBox(height: 24),
              // Step 2: Fill Form and Save
              _buildStepCard(
                stepNumber: 2,
                title: 'Guardar Datos del Auto',
                isCompleted: _createdCarId != null,
                isLocked: _acceptedReservation == null,
                child: _acceptedReservation == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Icons.lock_outline, size: 48, color: const Color(0xFF9ca3af)),
                            const SizedBox(height: 12),
                            const Text('Primero acepta una reserva', style: TextStyle(color: Color(0xFF64748b), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : AdminAdForm(initialData: _acceptedReservation, onSaved: _onSavedCar),
              ),
              const SizedBox(height: 24),
              // Step 3: Upload PDF
              _buildStepCard(
                stepNumber: 3,
                title: 'Subir PDF de Certificación',
                isCompleted: false,
                isLocked: _createdCarId == null,
                child: _createdCarId == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 48, color: const Color(0xFF9ca3af)),
                            const SizedBox(height: 12),
                            const Text('Guarda los datos del auto primero', style: TextStyle(color: Color(0xFF64748b), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : UploadCertificationWidget(carId: _createdCarId!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(int number, String label, bool completed, bool active) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: completed ? const Color(0xFF10b981) : (active ? const Color(0xFFF0F9FF) : Colors.white),
            border: Border.all(
              color: completed ? const Color(0xFF10b981) : (active ? const Color(0xFF3b82f6) : const Color(0xFFe2e8f0)),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: completed ? [BoxShadow(color: const Color(0xFF10b981).withOpacity(0.3), blurRadius: 20)] : [],
          ),
          child: completed
              ? const Icon(Icons.check, color: Colors.white, size: 24)
              : Text(number.toString(), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: active ? const Color(0xFF3b82f6) : const Color(0xFF94a3b8))),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: completed ? const Color(0xFF059669) : const Color(0xFF64748b))),
      ],
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required bool isCompleted,
    required bool isLocked,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF3b82f6), Color(0xFF8b5cf6)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(stepNumber.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
                ),
                if (isCompleted)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF10b981), size: 20),
                      SizedBox(width: 8),
                      Text('Completado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF065f46))),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Opacity(opacity: isLocked ? 0.6 : 1.0, child: child),
          ),
        ],
      ),
    );
  }
}