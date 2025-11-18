import 'package:flutter/material.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Términos de Uso'), backgroundColor: const Color(0xFF654321)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF5F0E1), Color(0xFFF0E6D2)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF654321), Color(0xFF8B4513)]),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                        Text('Términos de Uso', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22)),
                        SizedBox(height: 4),
                        Text('Actualizado recientemente', style: TextStyle(color: Colors.white70))
                      ]))
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _section(1, 'Introducción', 'Estos términos regulan el uso de CertiWeb.'),
                      _section(2, 'Privacidad', 'Tratamos tus datos con seguridad y conforme a la normativa.'),
                      _section(3, 'Responsabilidades', 'El uso de la plataforma implica aceptar estas condiciones.'),
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
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF654321), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
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

  static Widget _section(int number, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFCD853F).withOpacity(0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF8F5F0), Color(0xFFF0E6D2)]),
          ),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFCD853F), Color(0xFFDAA520)]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(number.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF654321), fontWeight: FontWeight.w600, fontSize: 16)))
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(content, style: const TextStyle(color: Color(0xFF5D4E37))),
        )
      ]),
    );
  }
}