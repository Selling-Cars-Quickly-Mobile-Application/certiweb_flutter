import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/toolbar/toolbar.dart';
import 'vehicle-spec/vehicle-spec.dart';
import 'calendar/calendar.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});
  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  Map<String, dynamic> _vehicleData = {};
  @override
  void initState() {
    super.initState();
    _guardAuth();
  }

  Future<void> _guardAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Toolbar(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: VehicleSpec(onUpdate: (v) => setState(() => _vehicleData = v)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ReservationCalendar(vehicleData: _vehicleData),
          ),
        ],
      ),
    );
  }
}