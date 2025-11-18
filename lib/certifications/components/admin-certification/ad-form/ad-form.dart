import 'package:flutter/material.dart';
import '../../../services/car_service.dart';

class AdminAdForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final ValueChanged<Map<String, dynamic>> onSaved;
  const AdminAdForm({super.key, required this.initialData, required this.onSaved});
  @override
  State<AdminAdForm> createState() => _AdminAdFormState();
}

class _AdminAdFormState extends State<AdminAdForm> {
  final _carService = CarService();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _year = TextEditingController();
  bool _saving = false;
  String? _error;

  final Map<String, int> _brandMap = const {
    'toyota': 1, 'nissan': 2, 'hyundai': 3, 'kia': 4, 'chevrolet': 5,
    'suzuki': 6, 'mitsubishi': 7, 'honda': 8, 'volkswagen': 9, 'ford': 10,
    'mercedes': 11, 'mercedes-benz': 11, 'audi': 12, 'bmw': 13,
  };

  @override
  void didUpdateWidget(covariant AdminAdForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prefill();
  }

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    final d = widget.initialData ?? {};
    _title.text = '${d['brand'] ?? ''} ${d['model'] ?? ''}'.trim();
    _year.text = DateTime.now().year.toString();
  }

  int _getFormProgress() {
    final fields = [_title.text.isNotEmpty, _year.text.isNotEmpty, _description.text.isNotEmpty];
    return ((fields.where((f) => f).length / fields.length) * 100).toInt();
  }

  Future<void> _save() async {
    setState(() { _error = null; _saving = true; });
    final d = widget.initialData ?? {};
    try {
      final brandName = (d['brand'] ?? '').toString().toLowerCase().trim();
      final brandId = _brandMap[brandName];
      if (brandId == null) { throw Exception('Marca no reconocida'); }
      final currentYear = DateTime.now().year;
      final year = int.tryParse(_year.text) ?? currentYear;
      if (year < 1900 || year > currentYear + 1) { throw Exception('Año inválido'); }
      final price = double.tryParse((d['price'] ?? '0').toString()) ?? 0;
      if (price < 0) { throw Exception('Precio inválido'); }
      final payload = {
        'title': _title.text,
        'owner': d['reservationName'],
        'ownerEmail': d['reservationEmail'],
        'year': year,
        'brandId': brandId,
        'model': d['model'],
        'description': _description.text,
        'pdfCertification': '',
        'imageUrl': d['imageUrl'] ?? 'https://via.placeholder.com/300x200.png?text=Car+Image',
        'price': price,
        'licensePlate': d['licensePlate'],
        'originalReservationId': int.tryParse(d['id']?.toString() ?? '') ?? d['id'],
      };
      final res = await _carService.createCar(payload);
      widget.onSaved({'id': res['id'] ?? res['data']?['id'], ...payload});
    } catch (e) {
      setState(() => _error = 'Error al guardar');
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formProgress = _getFormProgress();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progreso del formulario', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569), fontSize: 13)),
                  Text('$formProgress%', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3b82f6))),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: formProgress / 100,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF3b82f6)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField('Título del anuncio', _title, Icons.tag, readOnly: false, editable: true, hint: 'Ej: Toyota Corolla 2020'),
        _buildTextField('Propietario', TextEditingController(text: widget.initialData?['reservationName']), Icons.person, readOnly: true, editable: false),
        _buildTextField('Email del propietario', TextEditingController(text: widget.initialData?['reservationEmail']), Icons.email, readOnly: true, editable: false),
        _buildTextField('Año', _year, Icons.calendar_today, readOnly: false, editable: true, hint: DateTime.now().year.toString(), keyboardType: TextInputType.number),
        _buildTextField('Marca', TextEditingController(text: widget.initialData?['brand']), Icons.bookmark, readOnly: true, editable: false),
        _buildTextField('Modelo', TextEditingController(text: widget.initialData?['model']), Icons.settings, readOnly: true, editable: false),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description, size: 16, color: Color(0xFF3b82f6)),
                    const SizedBox(width: 6),
                    const Text('Descripción detallada', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151), fontSize: 14)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), border: Border.all(color: const Color(0xFFFBBF24)), borderRadius: BorderRadius.circular(12)),
                  child: const Text('Editable', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe el estado, características especiales, historial del vehículo...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFBBF24), width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3b82f6), width: 2)),
                filled: true,
                fillColor: const Color(0xFFFFFBEB),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 8),
            Text('${_description.text.length} caracteres', style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFEE2E2), border: Border.all(color: const Color(0xFFEF4444)), borderRadius: BorderRadius.circular(8)),
            child: Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save),
            label: Text(_saving ? 'Guardando...' : 'Guardar datos del auto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10b981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {required bool readOnly, required bool editable, String? hint, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: const Color(0xFF3b82f6)),
                  const SizedBox(width: 6),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151), fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: editable ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
                  border: Border.all(color: editable ? const Color(0xFFFBBF24) : const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(editable ? 'Editable' : 'Auto completo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: editable ? const Color(0xFFD97706) : const Color(0xFF6B7280))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: editable ? const Color(0xFFFBBF24) : const Color(0xFFD1D5DB), width: 2),
              ),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3b82f6), width: 2)),
              filled: true,
              fillColor: readOnly ? const Color(0xFFF9FAFB) : (editable ? const Color(0xFFFFFBEB) : Colors.white),
              contentPadding: const EdgeInsets.all(12),
              suffixIcon: readOnly ? const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.lock, color: Color(0xFF9CA3AF), size: 18)) : null,
            ),
          ),
        ],
      ),
    );
  }
}