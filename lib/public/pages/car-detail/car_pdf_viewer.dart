import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdfx/pdfx.dart';

class CarPdfViewerPage extends StatefulWidget {
  const CarPdfViewerPage({super.key});
  @override
  State<CarPdfViewerPage> createState() => _CarPdfViewerPageState();
}

class _CarPdfViewerPageState extends State<CarPdfViewerPage> {
  PdfControllerPinch? _controller;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final s = args?['data']?.toString();
    _loadDoc(s);
  }

  Future<void> _loadDoc(String? data) async {
    setState(() { _loading = true; _error = null; });
    try {
      if (data == null || data.isEmpty) {
        throw Exception('PDF no disponible');
      }
      final pure = data.startsWith('data:') ? data.split(',').last : data;
      final bytes = base64Decode(pure);
      _controller = PdfControllerPinch(document: PdfDocument.openData(Uint8List.fromList(bytes)));
    } catch (e) {
      _error = 'No se pudo cargar el PDF';
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certificación PDF'), backgroundColor: const Color(0xFF1E4D2B)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _controller == null
                  ? const Center(child: Text('PDF no disponible'))
                  : PdfViewPinch(controller: _controller!),
    );
  }
}