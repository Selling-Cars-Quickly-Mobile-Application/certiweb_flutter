import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soporte'), backgroundColor: const Color(0xFFCD853F)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF5F0E1), Color(0xFFF0E6D2)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFCD853F), Color(0xFFDAA520)]),
                    ),
                    child: Row(children: const [
                      CircleAvatar(backgroundColor: Color(0x33FFFFFF), child: Icon(Icons.help, color: Colors.white)),
                      SizedBox(width: 12),
                      Text('Soporte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22))
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Estamos aquí para ayudarte.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF5D4E37))),
                      const SizedBox(height: 24),
                      const Text('Contacto', style: TextStyle(color: Color(0xFF8B4513), fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _contactItem(Icons.email, 'Email', 'soporte@certiweb.com'),
                      const SizedBox(height: 8),
                      _contactItem(Icons.phone, 'Teléfono', '+123 456 7890'),
                      const SizedBox(height: 8),
                      _contactItem(Icons.schedule, 'Horario', 'Lun-Vie 9:00 - 18:00'),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF0E6D2), Color(0xFFE6D7C3)]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCD853F).withOpacity(0.2)),
                        ),
                        child: const Text('Consulta nuestras preguntas frecuentes o contáctanos para más información.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5D4E37))),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                        icon: const Icon(Icons.home),
                        label: const Text('Volver al inicio'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCD853F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _contactItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFAF8F3), Color(0xFFF5F0E1)]),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: Color(0xFFCD853F), width: 4)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFFCD853F)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Color(0xFF5D4E37)))
        ]))
      ]),
    );
  }
}