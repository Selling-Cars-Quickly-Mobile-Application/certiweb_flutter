import 'package:flutter/material.dart';

class CreateCertificateBanner extends StatelessWidget {
  const CreateCertificateBanner({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF5F0E1),
      child: Column(
        children: [
          Image.network(
            'https://img.freepik.com/foto-gratis/coche-lujoso-estacionado-carretera-faro-iluminado-al-atardecer_181624-60607.jpg?semt=ais_hybrid&w=740',
          ),
          const SizedBox(height: 12),
          const Text('Certifica tu vehículo', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/reservation');
            },
            child: const Text('Comenzar certificación'),
          )
        ],
      ),
    );
  }
}