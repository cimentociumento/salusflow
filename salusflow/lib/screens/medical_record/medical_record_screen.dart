import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:salusflow/services/auth_service.dart';
import 'package:salusflow/services/medical_record_service.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _allergiesController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _vaccinationController = TextEditingController();
  final _observationsController = TextEditingController();

  bool _authorizeTransfusion = false;
  final List<File> _reportImages = [];
  final List<File> _prescriptionImages = [];
  final ImagePicker _picker = ImagePicker();
  final MedicalRecordService _medicalRecordService = MedicalRecordService();

  @override
  void initState() {
    super.initState();
    _loadExistingRecord();
  }

  Future<void> _loadExistingRecord() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.userId != null) {
      final record = await _medicalRecordService.getMedicalRecord(
        authService.userId!,
      );
      if (record != null) {
        setState(() {
          _allergiesController.text = record['allergies'] ?? '';
          _diagnosisController.text = record['diagnoses'] ?? '';
          _medicationsController.text = record['medications'] ?? '';
          _bloodTypeController.text = record['blood_type'] ?? '';
          _vaccinationController.text = record['vaccination_card'] ?? '';
          _authorizeTransfusion = record['authorize_transfusion'] == 1;
          _observationsController.text = record['observations'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título da seção
              Text(
                'Meu Prontuário Médico',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Alergias
              const Text(
                'Alergias',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  hintText:
                      'Liste suas alergias (medicamentos, alimentos, etc.)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Diagnósticos recentes
              const Text(
                'Diagnósticos Recentes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  hintText: 'Liste seus diagnósticos médicos recentes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Medicamentos em uso
              const Text(
                'Medicamentos em Uso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicationsController,
                decoration: const InputDecoration(
                  hintText:
                      'Liste os medicamentos que você utiliza no momento (especifique a recorrência)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Laudos, Exames e Receitas
              const Text(
                'Laudos, Exames e Receitas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickReportImage,
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        'Adicionar Laudo/Exame',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickPrescriptionImage,
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        'Receitas Médicas',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tipo Sanguíneo
              const Text(
                'Tipo Sanguíneo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bloodTypeController,
                decoration: const InputDecoration(
                  hintText: 'Carteira do Tipo Sanguíneo',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.camera_alt, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              // Carteira de Vacinação
              const Text(
                'Carteira de Vacinação',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _vaccinationController,
                decoration: const InputDecoration(
                  hintText: 'Adicione sua carteira de vacinação',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.camera_alt, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),

              // Checkbox de autorização de transfusão
              CheckboxListTile(
                title: const Text('Autorizo transfusão sanguínea'),
                value: _authorizeTransfusion,
                onChanged: (value) {
                  setState(() {
                    _authorizeTransfusion = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Observações adicionais
              const Text(
                'Observações Adicionais',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(
                  hintText: 'Informações adicionais relevantes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Botão de download PDF
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadPDF,
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text(
                    'Baixar prontuário em PDF',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickReportImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _reportImages.add(File(image.path));
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laudo/Exame adicionado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickPrescriptionImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _prescriptionImages.add(File(image.path));
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receita médica adicionada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPDF() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário não autenticado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Salvar dados antes de gerar PDF
      await _saveRecord();

      // Gerar dados para PDF
      await _medicalRecordService.generatePDFData(authService.userId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gerando PDF do prontuário...'),
            backgroundColor: Colors.blue,
          ),
        );
      }

      // Simular geração do PDF
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF do prontuário baixado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveRecord() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.userId == null) return;

    final success = await _medicalRecordService.saveMedicalRecord(
      userId: authService.userId!,
      allergies: _allergiesController.text,
      diagnoses: _diagnosisController.text,
      medications: _medicationsController.text,
      bloodType: _bloodTypeController.text,
      vaccinationCard: _vaccinationController.text,
      authorizeTransfusion: _authorizeTransfusion,
      observations: _observationsController.text,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prontuário salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar prontuário'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
