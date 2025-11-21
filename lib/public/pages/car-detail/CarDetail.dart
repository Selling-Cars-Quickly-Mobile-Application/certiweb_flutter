import 'package:flutter/material.dart';
 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../../../certifications/services/car_service.dart';

class CarDetailPage extends StatefulWidget {
  const CarDetailPage({super.key});
  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  final _service = CarService();
  Map<String, dynamic>? _car;
  String? _carPdf;
  bool _loading = true;
  bool _loadingPdf = false;
  String? _error;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final id = args?['id'];
    _fetchCar(id);
  }

  Future<void> _fetchCar(dynamic id) async {
    setState(() { _loading = true; _error = null; });
    try {
      if (id == null) {
        throw Exception('ID de auto no válido');
      }
      final res = await _service.getCarById(id);
      _car = res['data'] is Map<String, dynamic> ? Map<String, dynamic>.from(res['data']) : Map<String, dynamic>.from(res);
      if ((_car?['hasPdfCertification'] ?? false) == true) {
        await _fetchPdf(id);
      }
    } catch (e) {
      _error = 'No se pudo cargar el auto';
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchPdf(dynamic id) async {
    setState(() { _loadingPdf = true; });
    try {
      final pdfRes = await _service.getCarPdf(id);
      final cert = pdfRes['pdfCertification'];
      final base64 = (cert is Map) ? cert['base64Data']?.toString() : cert?.toString();
      if (base64 != null && base64.isNotEmpty) {
        _carPdf = base64.startsWith('data:') ? base64 : 'data:application/pdf;base64,$base64';
      }
    } finally {
      setState(() { _loadingPdf = false; });
    }
  }

  void _previewPdfInApp() {
    if (_carPdf == null || _carPdf!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay PDF para visualizar')));
      return;
    }
    if (kIsWeb) {
      final url = Uri.parse(_carPdf!);
      launchUrl(url);
      return;
    }
    Navigator.pushNamed(context, '/car-pdf', arguments: {'data': _carPdf});
  }

  Future<void> _contactSellerByEmail() async {
    final brand = (_car?['brand'] ?? '').toString();
    final model = (_car?['model'] ?? '').toString();
    final plate = (_car?['licensePlate'] ?? (_car?['placa'] ?? '')).toString();
    final email = ((_car?['sellerEmail'] ?? _car?['ownerEmail'] ?? _car?['email'] ?? _car?['propietarioEmail'])?.toString()) ?? '';
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay correo del anunciante')));
      return;
    }
    final subject = 'Interés en vehículo $brand $model';
    final body = 'Hola, me interesa el auto.\nMarca: $brand\nModelo: $model\nPlaca: $plate';
    final uri = Uri(scheme: 'mailto', path: email, queryParameters: {'subject': subject, 'body': body});
    final ok = await launchUrl(uri);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el cliente de correo')));
    }
  }

  

  String _formatCurrency(dynamic value) {
    final numValue = value is String ? double.tryParse(value) : (value is num ? value.toDouble() : null);
    if (numValue == null) return value?.toString() ?? '';
    return 'S/ ${numValue.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del vehículo'), backgroundColor: const Color(0xFF1E4D2B)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _car == null
                  ? const Center(child: Text('Vehículo no encontrado'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(((_car?['imageUrl']) ?? '').toString().isEmpty ? 'https://via.placeholder.com/600x400?text=No+Image' : (_car?['imageUrl']).toString(), fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 16),
                        Text((_car?['title'] ?? '').toString(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF2c3e50))),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0x11007bff), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x33007bff))),
                          child: Wrap(spacing: 12, runSpacing: 8, children: [
                            Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.sell, color: Color(0xFF007bff)), const SizedBox(width: 6), Text('Marca ${(_car?['brand'] ?? '').toString()}')]),
                            Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.directions_car, color: Color(0xFF007bff)), const SizedBox(width: 6), Text('Modelo ${(_car?['model'] ?? '').toString()}')]),
                            Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.calendar_today, color: Color(0xFF007bff)), const SizedBox(width: 6), Text('Año ${(_car?['year'] ?? '').toString()}')]),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        Text(_formatCurrency(_car?['price']), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF28a745))),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)], border: Border.all(color: Colors.black.withOpacity(0.05))),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Información del propietario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF34495e))),
                            const SizedBox(height: 8),
                            Text('Propietario ${( _car?['owner'] ?? '' ).toString()}'),
                            Text('Placa ${( _car?['licensePlate'] ?? '' ).toString()}'),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)], border: Border.all(color: Colors.black.withOpacity(0.05))),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF34495e))),
                            const SizedBox(height: 8),
                            Text(((_car?['description']) ?? 'Sin descripción').toString(), style: const TextStyle(color: Color(0xFF444444))),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        if ((_car?['hasPdfCertification'] ?? false) == true)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)], border: Border.all(color: Colors.black.withOpacity(0.05))),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Certificación técnica (PDF)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF34495e))),
                              const SizedBox(height: 12),
                              if (_loadingPdf)
                                const Center(child: CircularProgressIndicator())
                              else if (_carPdf != null)
                                Row(children: [
                                  ElevatedButton(onPressed: _previewPdfInApp, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E4D2B), foregroundColor: Colors.white), child: const Text('Ver')),
                                  const SizedBox(width: 10),
                                  ElevatedButton(onPressed: _contactSellerByEmail, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E4D2B), foregroundColor: Colors.white), child: const Text('Contactar')),
                                ])
                              else
                                const Text('Error al cargar la certificación PDF'),
                            ]),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)], border: Border.all(color: Colors.black.withOpacity(0.05))),
                            child: const Text('Este vehículo no tiene certificación PDF'),
                          ),
                        const SizedBox(height: 24),
                        Center(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E4D2B), foregroundColor: Colors.white), child: const Text('Volver'))),
                      ]),
                    ),
    );
  }
}
