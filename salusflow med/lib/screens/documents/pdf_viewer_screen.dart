import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../services/integration_service.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final IntegrationService _integrationService = IntegrationService();
  Uint8List? _pdfBytes;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizador de Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _uploadPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfBytes != null
              ? SfPdfViewer.memory(_pdfBytes!)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const Text('Nenhum documento carregado'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _uploadPdf,
                        child: const Text('Carregar Documento PDF'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _uploadPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Usando bytes diretamente em vez de path para evitar o erro
      final bytes = await _integrationService.uploadPdfDocument();
      
      if (bytes != null) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
        
        // Notificar o usuário sobre o sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento carregado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Nenhum documento selecionado ou ocorreu um erro.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar o documento: $e';
      });
    }
  }
}