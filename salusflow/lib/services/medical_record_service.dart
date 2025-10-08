import 'package:salusflow/database/database_helper.dart';

class MedicalRecordService {
  static final MedicalRecordService _instance =
      MedicalRecordService._internal();
  factory MedicalRecordService() => _instance;
  MedicalRecordService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Salvar ou atualizar prontuário médico
  Future<bool> saveMedicalRecord({
    required int userId,
    String? allergies,
    String? diagnoses,
    String? medications,
    String? bloodType,
    String? vaccinationCard,
    bool authorizeTransfusion = false,
    String? observations,
  }) async {
    try {
      // Verificar se já existe um prontuário para este usuário
      final existingRecord = await _dbHelper.getMedicalRecordByUserId(userId);

      final recordData = {
        'user_id': userId,
        'allergies': allergies,
        'diagnoses': diagnoses,
        'medications': medications,
        'blood_type': bloodType,
        'vaccination_card': vaccinationCard,
        'authorize_transfusion': authorizeTransfusion ? 1 : 0,
        'observations': observations,
      };

      if (existingRecord != null) {
        // Atualizar prontuário existente
        final result = await _dbHelper.updateMedicalRecord(userId, recordData);
        return result > 0;
      } else {
        // Criar novo prontuário
        recordData['created_at'] = DateTime.now().toIso8601String();
        recordData['updated_at'] = DateTime.now().toIso8601String();

        final result = await _dbHelper.insertMedicalRecord(recordData);
        return result > 0;
      }
    } catch (e) {
      return false;
    }
  }

  // Buscar prontuário por ID do usuário
  Future<Map<String, dynamic>?> getMedicalRecord(int userId) async {
    try {
      return await _dbHelper.getMedicalRecordByUserId(userId);
    } catch (e) {
      return null;
    }
  }

  // Buscar prontuário por CPF/CNPJ
  Future<Map<String, dynamic>?> getMedicalRecordByCpfCnpj(
    String cpfCnpj,
  ) async {
    try {
      final user = await _dbHelper.getUserByCpfCnpj(cpfCnpj);
      if (user != null) {
        return await _dbHelper.getMedicalRecordByUserId(user['id']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Gerar dados do prontuário para PDF
  Future<Map<String, dynamic>> generatePDFData(int userId) async {
    try {
      final cpfCnpj = await _getCpfCnpjByUserId(userId);
      final user = cpfCnpj != null
          ? await _dbHelper.getUserByCpfCnpj(cpfCnpj)
          : null;
      final record = await _dbHelper.getMedicalRecordByUserId(userId);

      return {
        'user': user,
        'record': record,
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {};
    }
  }

  // Buscar CPF/CNPJ por ID do usuário
  Future<String?> _getCpfCnpjByUserId(int userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'users',
        columns: ['cpf_cnpj'],
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result.isNotEmpty ? result.first['cpf_cnpj'] as String? : null;
    } catch (e) {
      return null;
    }
  }

  // Verificar se usuário tem prontuário
  Future<bool> hasMedicalRecord(int userId) async {
    try {
      final record = await _dbHelper.getMedicalRecordByUserId(userId);
      return record != null;
    } catch (e) {
      return false;
    }
  }

  // Deletar prontuário
  Future<bool> deleteMedicalRecord(int userId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.delete(
        'medical_records',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }
}
