import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';

class IntegrationService {
  // Caminho para o banco de dados do SalusFlow (paciente)
  static const String patientDbName = 'salusflow.db';
  
  // Caminho para o banco de dados do SalusFlow Med (médico)
  static const String doctorDbName = 'salusflow.db';
  
  // Obtém o caminho do banco de dados do paciente
  Future<String> getPatientDbPath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, patientDbName);
  }
  
  // Abre conexão com o banco de dados do paciente
  Future<Database> openPatientDatabase() async {
    final path = await getPatientDbPath();
    return openDatabase(path, readOnly: true);
  }
  
  // Verifica permissões do médico para acessar dados do paciente
  Future<bool> checkDoctorPermission(int doctorId, int patientId) async {
    final db = await openPatientDatabase();
    try {
      final result = await db.query(
        'doctor_permissions',
        where: 'doctor_id = ? AND user_id = ? AND is_active = 1',
        whereArgs: [doctorId, patientId],
      );
      return result.isNotEmpty;
    } finally {
      await db.close();
    }
  }
  
  // Obtém prontuário médico do paciente se o médico tiver permissão
  Future<Map<String, dynamic>?> getPatientMedicalRecord(int doctorId, int patientId) async {
    final hasPermission = await checkDoctorPermission(doctorId, patientId);
    if (!hasPermission) return null;
    
    final db = await openPatientDatabase();
    try {
      final result = await db.query(
        'medical_records',
        where: 'user_id = ?',
        whereArgs: [patientId],
      );
      return result.isNotEmpty ? result.first : null;
    } finally {
      await db.close();
    }
  }
  
  // Obtém lista de pacientes que deram permissão ao médico
  Future<List<Map<String, dynamic>>> getAuthorizedPatients(int doctorId) async {
    final db = await openPatientDatabase();
    try {
      final permissions = await db.rawQuery('''
        SELECT dp.*, u.name, u.cpf_cnpj, u.email, u.birth_date
        FROM doctor_permissions dp
        JOIN users u ON dp.user_id = u.id
        WHERE dp.doctor_id = ? AND dp.is_active = 1
      ''', [doctorId]);
      
      return permissions.map((permission) {
        return {
          'id': permission['user_id'],
          'name': permission['name'],
          'cpf': permission['cpf_cnpj'],
          'email': permission['email'],
          'birthDate': permission['birth_date'],
          'permissionId': permission['id'],
        };
      }).toList();
    } finally {
      await db.close();
    }
  }
  
  // Upload de documento PDF
  Future<Uint8List?> uploadPdfDocument() async {
    try {
      // Usando bytes diretamente em vez de path para evitar o erro
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Importante: garante que os bytes sejam retornados
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Retorna os bytes diretamente, sem tentar acessar o path
        return file.bytes;
      }
      return null;
    } catch (e) {
      print('Erro ao fazer upload do PDF: $e');
      return null;
    }
  }
}