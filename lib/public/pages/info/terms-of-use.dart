import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsOfUsePage extends StatefulWidget {
  const TermsOfUsePage({super.key});

  @override
  State<TermsOfUsePage> createState() => _TermsOfUsePageState();
}

class _TermsOfUsePageState extends State<TermsOfUsePage> {
  String _mode = 'view'; // 'view' or 'accept'

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['mode'] != null) {
      _mode = args['mode'].toString();
    }
  }

  Future<void> _acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('termsAccepted', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _declineTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir de la aplicación'),
        content: const Text('Es necesario aceptar los términos de uso para utilizar CertiWeb. ¿Estás seguro de que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SystemNavigator.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAcceptMode = _mode == 'accept';

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
                      _section(1, 'Aceptación de Términos', 'Al acceder y utilizar la aplicación CertiWeb, aceptas completamente estos términos de uso. Si no estás de acuerdo con alguna parte, no debes usar la aplicación. Nos reservamos el derecho de modificar estos términos en cualquier momento. El uso continuado de la aplicación tras cambios constituye aceptación de los nuevos términos.'),
                      _section(2, 'Privacidad y Protección de Datos', 'CertiWeb protege tu información personal conforme a la normativa de protección de datos vigente. Recopilamos solo datos necesarios para el funcionamiento de la aplicación. Tus datos no serán compartidos con terceros sin tu consentimiento. Utilizamos cifrado y medidas de seguridad para proteger tu información. Puedes solicitar acceso, corrección o eliminación de tus datos en cualquier momento.'),
                      _section(3, 'Responsabilidades del Usuario', 'Eres responsable de mantener la confidencialidad de tu contraseña y credenciales. No compartas tu cuenta con terceros. Garantizas que la información proporcionada es veraz y completa. No utilizarás la aplicación para actividades ilegales o fraudulentas. Asumes toda responsabilidad por las acciones realizadas en tu cuenta.'),
                      _section(4, 'Uso Prohibido', 'Está prohibido: enviar virus, malware o código malicioso; acceder sin autorización a sistemas de CertiWeb; interferir con el funcionamiento de la aplicación; usar datos de otros usuarios; realizar actividades discriminatorias, abusivas o ilegales; violar derechos de propiedad intelectual; intentar eludir medidas de seguridad.'),
                      _section(5, 'Limitación de Responsabilidad', 'CertiWeb se proporciona "tal como está" sin garantías implícitas. No nos hacemos responsables por daños indirectos, incidentales, especiales o consecuentes derivados del uso de la aplicación. Nos esforzamos por mantener la disponibilidad del servicio, pero no garantizamos funcionamiento ininterrumpido. Eres responsable de mantener copias de seguridad de tus datos.'),
                      _section(6, 'Modificaciones del Servicio', 'Nos reservamos el derecho de modificar, suspender o discontinuar partes de la aplicación en cualquier momento. También podemos cambiar requisitos técnicos, características o funcionalidades. Notificaremos cambios significativos cuando sea posible. El uso continuado implica aceptación de los cambios.'),
                      _section(7, 'Terminación de Acceso', 'Podemos suspender o terminar tu acceso a CertiWeb si incumples estos términos, realizas actividades ilegales, abusas del servicio o por razones de seguridad. Puedes eliminar tu cuenta en cualquier momento a través de la configuración de la aplicación. La eliminación de cuenta implicará pérdida de acceso a tus datos.'),
                      _section(8, 'Ley Aplicable', 'Estos términos se rigen por la ley aplicable en la jurisdicción donde opera CertiWeb. Cualquier disputa será resuelta en los tribunales competentes de dicha jurisdicción. Aceptas someterte a la jurisdicción exclusiva de estos tribunales.'),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: isAcceptMode
                        ? Column(
                            children: [
                              const Text(
                                'Para continuar utilizando la aplicación, debes aceptar los términos de uso.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF5D4E37), fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _declineTerms,
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red),
                                        foregroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      ),
                                      child: const Text('Rechazar y Salir'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _acceptTerms,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF654321),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      ),
                                      child: const Text('Aceptar'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context), // Just go back if viewing
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Volver'),
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