import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../shared/services/imgbb_api_service.dart';
import '../../../../config/dio_client.dart';

class VehicleSpecData {
  String brand = '';
  String model = '';
  String licensePlate = '';
  String ownerEmail = '';
  String sellingPrice = '';
  Uint8List? imageBytes;
  String? imageUrl;
  String? imageId;
  bool imageUploaded = false;
}

class VehicleSpec extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onUpdate;
  const VehicleSpec({super.key, required this.onUpdate});
  @override
  State<VehicleSpec> createState() => _VehicleSpecState();
}

class _VehicleSpecState extends State<VehicleSpec> {
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _plate = TextEditingController();
  final _ownerEmail = TextEditingController();
  final _price = TextEditingController();
  String? _imageUrl;
  String? _imageId;
  bool _uploading = false;
  bool _imageCargada = false;
  final _img = ImgbbApiService();
  final _dio = DioClient.instance.dio;

  final List<Map<String, String>> _brands = [
    {'nombre': 'Toyota', 'codigo': 'toyota'},
    {'nombre': 'Nissan', 'codigo': 'nissan'},
    {'nombre': 'Hyundai', 'codigo': 'hyundai'},
    {'nombre': 'Kia', 'codigo': 'kia'},
    {'nombre': 'Chevrolet', 'codigo': 'chevrolet'},
    {'nombre': 'Suzuki', 'codigo': 'suzuki'},
    {'nombre': 'Mitsubishi', 'codigo': 'mitsubishi'},
    {'nombre': 'Honda', 'codigo': 'honda'},
    {'nombre': 'Volkswagen', 'codigo': 'volkswagen'},
    {'nombre': 'Ford', 'codigo': 'ford'},
    {'nombre': 'Mercedes-Benz', 'codigo': 'mercedes'},
    {'nombre': 'Audi', 'codigo': 'audi'},
    {'nombre': 'BMW', 'codigo': 'bmw'},
  ];

  List<String> _validModels = [];
  bool _loadingModels = false;
  String? _selectedBrand;
  String? _modelError;

  Future<void> _fetchValidModels(String brand) async {
    setState(() => _loadingModels = true);
    try {
      final response = await _dio.get('/cars');
      final cars = List<Map<String, dynamic>>.from(response.data);
      _validModels = cars
          .where((car) => (car['brand'] ?? '').toString().toLowerCase() == brand.toLowerCase())
          .map((car) => (car['model'] ?? '').toString())
          .toSet()
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar modelos: $e')),
        );
      }
      _validModels = [];
    } finally {
      setState(() => _loadingModels = false);
    }
  }

  String brandToCode(String name) {
    switch (name) {
      case 'Toyota': return 'toyota';
      case 'Nissan': return 'nissan';
      case 'Hyundai': return 'hyundai';
      case 'Kia': return 'kia';
      case 'Chevrolet': return 'chevrolet';
      case 'Suzuki': return 'suzuki';
      case 'Mitsubishi': return 'mitsubishi';
      case 'Honda': return 'honda';
      case 'Volkswagen': return 'volkswagen';
      case 'Ford': return 'ford';
      case 'Mercedes-Benz': return 'mercedes';
      case 'Audi': return 'audi';
      case 'BMW': return 'bmw';
      default: return name.toLowerCase();
    }
  }

  bool _isValidPlate(String plate) {
    final regex = RegExp(r'^[A-Z0-9]{3}-[A-Z0-9]{3}$');
    return regex.hasMatch(plate);
  }

  String _formatPlate(String value) {
    value = value.toUpperCase();
    value = value.replaceAll(RegExp(r'[^A-Z0-9-]'), '');
    String valueSinGuion = value.replaceAll('-', '');
    if (valueSinGuion.length > 3) {
      value = valueSinGuion.substring(0, 3) + '-' + valueSinGuion.substring(3);
    } else {
      value = valueSinGuion;
    }
    if (value.length > 7) {
      value = value.substring(0, 7);
    }
    return value;
  }

  Future<void> _pickAndUpload() async {
    setState(() => _uploading = true);
    try {
      final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (res != null && res.files.isNotEmpty && res.files.first.bytes != null) {
        final f = res.files.first;
        final ext = (f.extension ?? '').toLowerCase();
        if (ext != 'jpg' && ext != 'jpeg') {
          if (mounted) {
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(content: Text('Solo se permiten imágenes JPG')));
          }
          return;
        }
        final Uint8List bytes = f.bytes!;
        final filename = f.name;
        final data = await _img.uploadImageBytes(bytes, filename);
        setState(() {
          _imageUrl = data['url']?.toString();
          _imageId = data['id']?.toString();
          _imageCargada = true;
        });
        _emit();
      }
    } finally {
      setState(() => _uploading = false);
    }
  }

  void _emit() {
    widget.onUpdate({
      'marca': _brand.text,
      'modelo': _model.text,
      'placa': _plate.text,
      'precioVender': num.tryParse(_price.text) ?? 0,
      'propietarioEmail': _ownerEmail.text,
      'imagenes': [
        if (_imageUrl != null) {'url': _imageUrl, 'id': _imageId}
      ]
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Subir Foto del Vehículo',
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
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 500),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _imageCargada ? const Color(0xFF1E4D2B) : const Color(0xFFE0E0E0),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: _imageCargada
                            ? const Color(0xFFF0F9F4)
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1E4D2B), Color(0xFF2D6B3F)],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Foto del Vehículo',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _uploading ? null : _pickAndUpload,
                                  icon: const Icon(Icons.upload_file),
                                  label: Text(_uploading ? 'Subiendo...' : 'Seleccionar Archivo'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E4D2B),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_imageCargada && _imageUrl != null)
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF1E4D2B).withOpacity(0.2),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Column(
                                      children: [
                                        Image.network(
                                          _imageUrl!,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 200,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(Icons.error),
                                              ),
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(
                                            'Imagen cargada correctamente (ID: $_imageId)',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF666666),
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Datos del Vehículo',
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
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        // Marca (mostrar nombre, guardar código)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Color(0xFF1E4D2B), Color(0xFF2D6B3F)],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Marca', style: TextStyle(color: Color(0xFF1E4D2B), fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _brand.text.isEmpty ? null : _brand.text,
                              decoration: InputDecoration(
                                hintText: 'Selecciona una marca',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 2)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 2)),
                                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E4D2B), width: 2), borderRadius: BorderRadius.all(Radius.circular(10))),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              items: _brands
                                  .map((b) => DropdownMenuItem(
                                        value: b['codigo'],
                                        child: Text(b['nombre']!),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _brand.text = value;
                                  _selectedBrand = value;
                                  _model.text = '';
                                  _modelError = null;
                                  _fetchValidModels(value);
                                  _emit();
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCustomField(
                              label: 'Modelo',
                              controller: _model,
                              hint: 'Ej: Civic, Accent, X50',
                              onChanged: (value) {
                                if (_selectedBrand != null && value.isNotEmpty && _validModels.isNotEmpty) {
                                  if (!_validModels.contains(value)) {
                                    _modelError = 'Modelo inválido para $_selectedBrand. Opciones disponibles: ${_validModels.join(', ')}';
                                  } else {
                                    _modelError = null;
                                  }
                                } else {
                                  _modelError = null;
                                }
                                _emit();
                              },
                            ),
                            if (_modelError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _modelError!,
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCustomField(
                          label: 'Placa',
                          controller: _plate,
                          hint: 'Ej: ABC-123',
                          maxLength: 7,
                          onChanged: (value) {
                            _plate.text = _formatPlate(value);
                            _plate.selection = TextSelection.fromPosition(
                              TextPosition(offset: _plate.text.length),
                            );
                            _emit();
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCustomField(
                          label: 'Email del Propietario',
                          controller: _ownerEmail,
                          hint: 'ejemplo@correo.com',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => _emit(),
                        ),
                        const SizedBox(height: 16),
                        _buildCustomField(
                          label: 'Precio de Venta',
                          controller: _price,
                          hint: 'Ej: 50000000',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _emit(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    ValueChanged<String>? onChanged,
    bool isDropdown = false,
    List<String>? items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
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
              label,
              style: const TextStyle(
                color: Color(0xFF1E4D2B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isDropdown && items != null)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              value: controller.text.isEmpty ? null : controller.text,
              decoration: InputDecoration(
                hintText: 'Selecciona una marca',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE9ECEF),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE9ECEF),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E4D2B),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.text = value;
                  onChanged?.call(value);
                }
              },
            ),
          )
        else
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF1E4D2B),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
      ],
    );
  }
}