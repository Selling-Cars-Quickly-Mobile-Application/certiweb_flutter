import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../../../services/car_service.dart';

class UploadCertificationWidget extends StatefulWidget {
  final int carId;
  const UploadCertificationWidget({super.key, required this.carId});
  @override
  State<UploadCertificationWidget> createState() => _UploadCertificationWidgetState();
}

class _UploadCertificationWidgetState extends State<UploadCertificationWidget> with TickerProviderStateMixin {
  final _service = CarService();
  String? _base64;
  String? _fileName;
  bool _uploading = false;
  bool _processing = false;
  double _uploadProgress = 0;
  String? _error;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _select() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (res != null && res.files.isNotEmpty && res.files.first.bytes != null) {
      setState(() => _processing = true);
      final bytes = res.files.first.bytes!;
      final b64 = base64Encode(bytes);
      setState(() {
        _base64 = 'data:application/pdf;base64,$b64';
        _fileName = res.files.first.name;
        _processing = false;
        _uploadProgress = 0;
      });
    }
  }

  Future<void> _upload() async {
    if (_base64 == null) return;
    setState(() { _uploading = true; _error = null; _uploadProgress = 0; });
    try {
      for (int i = 0; i <= 100; i += 20) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() => _uploadProgress = i / 100);
      }
      await _service.updateCar(widget.carId, {'pdfCertification': _base64});
      setState(() => _uploadProgress = 1.0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF subido correctamente'), backgroundColor: Color(0xFF10b981)));
        _clear();
      }
    } catch (e) {
      setState(() => _error = 'Error al subir PDF');
    } finally {
      setState(() => _uploading = false);
    }
  }

  void _clear() {
    setState(() { _base64 = null; _fileName = null; _uploadProgress = 0; });
  }

  String _getFileSize() {
    if (_base64 == null) return '';
    final sizeInBytes = (_base64!.length * 3) ~/ 4;
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_base64 == null) ...[
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB), width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFF9FAFB),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF3b82f6), Color(0xFF8b5cf6)]),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [BoxShadow(color: const Color(0xFF3b82f6).withOpacity(0.3), blurRadius: 25)],
                  ),
                  child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Seleccionar o arrastrar PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
                const SizedBox(height: 4),
                const Text('Máximo 10 MB en formato PDF', style: TextStyle(fontSize: 14, color: Color(0xFF64748b))),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _select,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Seleccionar archivo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3b82f6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildFeatureChip(Icons.shield, 'Seguro'),
                    _buildFeatureChip(Icons.flash_on, 'Rápido'),
                    _buildFeatureChip(Icons.verified, 'Validado'),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          if (_processing)
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
                  const Row(
                    children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Color(0xFF3b82f6)))),
                      SizedBox(width: 12),
                      Text('Procesando archivo...', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    ],
                  ),
                ],
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFEF4444)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_fileName ?? 'PDF', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1e293b)), overflow: TextOverflow.ellipsis),
                            Text(_getFileSize(), style: const TextStyle(fontSize: 12, color: Color(0xFF64748b))),
                          ],
                        ),
                      ),
                      if (!_uploading)
                        IconButton(
                          onPressed: _clear,
                          icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                          tooltip: 'Eliminar',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF10b981), size: 18),
                        const SizedBox(width: 8),
                        const Text('Archivo válido', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10b981))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_uploading) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subiendo...', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF475569))),
                        Text('${(_uploadProgress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF3b82f6))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: _uploadProgress, minHeight: 6, backgroundColor: const Color(0xFFE2E8F0), valueColor: const AlwaysStoppedAnimation(Color(0xFF3b82f6))),
                    ),
                  ],
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), border: Border.all(color: const Color(0xFFEF4444)), borderRadius: BorderRadius.circular(8)),
                child: Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_base64 == null || _uploading) ? null : _upload,
                icon: const Icon(Icons.cloud_upload),
                label: Text(_uploading ? 'Subiendo...' : 'Subir a base de datos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFD1FAE5), border: Border.all(color: const Color(0xFF10b981)), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF10b981), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PDF listo para subir', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF065f46))),
                        Text('El archivo será validado al subir', style: TextStyle(fontSize: 12, color: Color(0xFF047857))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), border: Border.all(color: const Color(0xFFBFDBFE)), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF3b82f6)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1e40af))),
        ],
      ),
    );
  }
}