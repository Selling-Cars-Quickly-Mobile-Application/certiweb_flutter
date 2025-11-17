import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../certifications/services/reservation_service.dart';
import '../../../../certifications/services/user_service.dart';

class ReservationCalendar extends StatefulWidget {
  final Map<String, dynamic> vehicleData;
  const ReservationCalendar({super.key, required this.vehicleData});
  @override
  State<ReservationCalendar> createState() => _ReservationCalendarState();
}

class CalendarSelection { DateTime? selectedDateTime; }

class _ReservationCalendarState extends State<ReservationCalendar> {
  final CalendarSelection _selection = CalendarSelection();
  final _userService = UserService();
  final _reservationService = ReservationService();
  final _hours = const [
    {'display': '9:00 AM', 'hour': 9},
    {'display': '11:00 AM', 'hour': 11},
    {'display': '1:00 PM', 'hour': 13},
    {'display': '3:00 PM', 'hour': 15},
    {'display': '5:00 PM', 'hour': 17},
  ];
  bool _saving = false;
  String? _error;
  String? _success;

  bool _isWeekday(DateTime d) => d.weekday != DateTime.saturday && d.weekday != DateTime.sunday;

  String _formatDate(DateTime date) {
    const days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return '${days[date.weekday % 7]}, ${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _formatTime(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  Future<void> _confirm() async {
    setState(() { _error = null; _success = null; });
    if (_selection.selectedDateTime == null) { setState(() => _error = 'Seleccione fecha y hora'); return; }
    final v = widget.vehicleData;
    if ((v['placa'] ?? '').toString().isEmpty || (v['marca'] ?? '').toString().isEmpty || (v['modelo'] ?? '').toString().isEmpty) { setState(() => _error = 'Faltan datos del vehículo'); return; }
    final imgs = (v['imagenes'] ?? []) as List;
    if (imgs.isEmpty || (imgs.first['url'] ?? '').toString().isEmpty) { setState(() => _error = 'Suba al menos una imagen'); return; }
    final dynamic priceDyn = (v['precioVender'] ?? 0);
    final num priceNum = priceDyn is num ? priceDyn : num.tryParse(priceDyn.toString()) ?? 0;
    final int price = priceNum.round();
    if (price <= 0) { setState(() => _error = 'Ingrese precio válido'); return; }
    setState(() => _saving = true);
    try {
      final u = await _userService.getCurrentUser();
      final dt = _selection.selectedDateTime!;
      const validHours = [9, 11, 13, 15, 17];
      if (!validHours.contains(dt.hour) || dt.minute != 0 || dt.second != 0) {
        setState(() => _error = 'Seleccione una hora válida: 9, 11, 13, 15 o 17');
        return;
      }
      final dtUtc = DateTime.utc(dt.year, dt.month, dt.day, dt.hour, 0, 0, 0);
      final userIdDyn = u['id'];
      final userId = (userIdDyn is String) ? int.tryParse(userIdDyn) ?? userIdDyn : userIdDyn;
      final payload = {
        'userId': userId,
        'reservationName': u['name'],
        'reservationEmail': u['email'],
        'imageUrl': imgs.first['url'],
        'brand': v['marca'],
        'model': v['modelo'],
        'licensePlate': v['placa'],
        'inspectionDateTime': dtUtc.toIso8601String(),
        'price': price.toString(),
      };
      assert(() { print('POST /reservations payload: '+payload.toString()); return true; }());
      await _reservationService.createReservation(payload);
      setState(() => _success = 'Reserva creada');
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      String msg = 'Error al crear la reserva';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] is String) {
          msg = data['message'];
        } else if (data is String && data.isNotEmpty) {
          msg = data;
        }
      }
      setState(() => _error = msg);
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8FFFE), Color(0xFFF0F9F4)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Seleccionar Fecha y Hora',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF1E4D2B),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E4D2B), Color(0xFF2D6B3F)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 600;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCalendarSection()),
                            const SizedBox(width: 24),
                            Expanded(child: _buildTimeSection()),
                          ],
                        )
                      : Column(
                          children: [
                            _buildCalendarSection(),
                            const SizedBox(height: 24),
                            _buildTimeSection(),
                          ],
                        );
                },
              ),
              const SizedBox(height: 32),
              if (_selection.selectedDateTime != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE6F7E6), Color(0xFFD4EDDA)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1E4D2B).withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E4D2B).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha y Hora Seleccionada',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: const Color(0xFF1E4D2B),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF1E4D2B), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formatDate(_selection.selectedDateTime!),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF1E4D2B), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _formatTime(_selection.selectedDateTime!.hour),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_success != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _success!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _confirm,
                  icon: _saving ? null : const Icon(Icons.check),
                  label: Text(_saving ? 'Guardando...' : 'Confirmar Reserva'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E4D2B).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E4D2B), Color(0xFF2D6B3F)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Seleccionar Fecha',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1E4D2B),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            selectableDayPredicate: _isWeekday,
            onDateChanged: (d) {
              final currentHour = _selection.selectedDateTime?.hour ?? 9;
              final newDt = DateTime(d.year, d.month, d.day, currentHour, 0);
              setState(() => _selection.selectedDateTime = newDt);
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4D2B).withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Solo se pueden seleccionar días de semana (Lunes a Viernes)',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E4D2B).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E4D2B), Color(0xFF2D6B3F)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Seleccionar Hora',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1E4D2B),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _hours.length,
            itemBuilder: (context, index) {
              final horario = _hours[index];
              final hour = horario['hour'] as int;
              final isSelected = _selection.selectedDateTime?.hour == hour;
              return GestureDetector(
                onTap: () {
                  DateTime newDateTime;
                  if (_selection.selectedDateTime == null) {
                    final now = DateTime.now();
                    newDateTime = DateTime(now.year, now.month, now.day, hour, 0);
                    if (newDateTime.weekday == DateTime.saturday) {
                      newDateTime = newDateTime.add(const Duration(days: 2));
                    } else if (newDateTime.weekday == DateTime.sunday) {
                      newDateTime = newDateTime.add(const Duration(days: 1));
                    }
                  } else {
                    final d = _selection.selectedDateTime!;
                    newDateTime = DateTime(d.year, d.month, d.day, hour, 0);
                  }
                  setState(() => _selection.selectedDateTime = newDateTime);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF1E4D2B), Color(0xFF2D6B3F)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
                          ),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E4D2B)
                          : const Color(0xFFE9ECEF),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1E4D2B).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      horario['display'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4D2B).withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Horarios disponibles: 9:00 AM, 11:00 AM, 1:00 PM, 3:00 PM, 5:00 PM',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
