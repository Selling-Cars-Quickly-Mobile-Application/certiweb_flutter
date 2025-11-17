import 'package:flutter/material.dart';
import '../../../../config/dio_client.dart';
import 'package:dio/dio.dart';

class SearchFilters extends StatefulWidget {
  const SearchFilters({super.key});
  @override
  State<SearchFilters> createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  final Dio _dio = DioClient.instance.dio;
  List<Map<String, dynamic>> _cars = [];
  String? _brand;
  String? _model;
  bool _loading = false;
  final List<String> _pre = [
    'Toyota','Hyundai','Kia','Chevrolet','Suzuki','Mitsubishi','Honda','Volkswagen','Ford','Mercedes-Benz','BMW','Audi'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _dio.get('/cars');
      _cars = List<Map<String, dynamic>>.from(res.data);
    } catch (_) {
      _cars = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> get _brands {
    final s = {..._pre, ..._cars.map((c) => (c['brand'] ?? '').toString())};
    return s
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
        .toList();
  }

  List<String> get _models {
    if (_brand == null) return [];
    final b = _brand!.toLowerCase();
    final m = _cars
        .where((c) => (c['brand'] ?? '').toString().toLowerCase() == b)
        .map((c) => (c['model'] ?? '').toString());
    return m.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [Icon(Icons.search), SizedBox(width: 8), Text('Filtros de búsqueda', style: TextStyle(fontWeight: FontWeight.w600))]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              items: _brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (v) {
                setState(() {
                  _brand = v;
                  _model = null;
                });
              },
              initialValue: _brand,
              decoration: const InputDecoration(labelText: 'Marca'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              items: _models.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => setState(() => _model = v),
              initialValue: _model,
              decoration: const InputDecoration(labelText: 'Modelo'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _brand = null;
                      _model = null;
                    });
                  },
                  child: const Text('Limpiar'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _brand == null
                      ? null
                      : () {
                          final qp = {'brand': _brand, if (_model != null) 'model': _model};
                          Navigator.pushNamed(context, '/cars', arguments: qp);
                        },
                  child: _loading ? const Text('Cargando...') : const Text('Buscar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}