import 'package:flutter/material.dart';
import '../../../certifications/services/car_service.dart';

class CarListPage extends StatefulWidget {
  const CarListPage({super.key});
  @override
  State<CarListPage> createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  final _service = CarService();
  List<Map<String, dynamic>> _cars = [];
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
      final data = await _service.getAllCars();
      _cars = data;
    } catch (e) {
      _error = 'No se pudo cargar la lista de autos';
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatCurrency(dynamic value) {
    final numValue = value is String ? double.tryParse(value) : (value is num ? value.toDouble() : null);
    if (numValue == null) return value?.toString() ?? '';
    return 'S/ ${numValue.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final crossAxisCount = isMobile ? 1 : 3;
    return Scaffold(
      appBar: AppBar(title: const Text('Vehículos certificados'), backgroundColor: const Color(0xFF1E4D2B)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [SizedBox(width: 50, height: 50, child: CircularProgressIndicator()), SizedBox(height: 12), Text('Cargando...')]))
            : _error != null
                ? Center(child: Text(_error!))
                : _cars.isEmpty
                    ? const Center(child: Text('No hay autos disponibles'))
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: isMobile ? 0.85 : 0.9),
                        itemCount: _cars.length,
                        itemBuilder: (context, i) {
                          final car = _cars[i];
                          final imageUrl = (car['imageUrl'] ?? '').toString();
                          final title = (car['title'] ?? '').toString();
                          final brand = (car['brand'] ?? '').toString();
                          final model = (car['model'] ?? '').toString();
                          final year = (car['year'] ?? '').toString();
                          final price = car['price'];
                          final description = (car['description'] ?? '').toString();
                          return InkWell(
                            onTap: () => Navigator.pushNamed(context, '/car-detail', arguments: {'id': car['id']}),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.network(
                                      imageUrl.isEmpty ? 'https://via.placeholder.com/600x400?text=No+Image' : imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2c3e50))),
                                    const SizedBox(height: 6),
                                    Text('$brand - $model', style: const TextStyle(color: Color(0xFF1E4D2B), fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('Año $year', style: const TextStyle(color: Color(0xFF6c757d))),
                                    const SizedBox(height: 8),
                                    Text(description.isEmpty ? 'Sin descripción' : (description.length > 100 ? '${description.substring(0, 100)}...' : description), style: const TextStyle(color: Color(0xFF495057))),
                                  ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Text(_formatCurrency(price), style: const TextStyle(color: Color(0xFF28a745), fontWeight: FontWeight.w800)),
                                    ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/car-detail', arguments: {'id': car['id']}), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E4D2B), foregroundColor: Colors.white), child: const Text('Ver detalles')),
                                  ]),
                                )
                              ]),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}