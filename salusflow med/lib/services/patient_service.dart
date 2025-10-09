import '../database/database_helper.dart';

class PatientService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Obtém todos os pacientes que deram permissão ao médico
  Future<List<Map<String, dynamic>>> getAuthorizedPatients(int doctorId) async {
    final db = await _dbHelper.database;
    
    // Consulta pacientes com permissão ativa
    final List<Map<String, dynamic>> permissions = await db.rawQuery('''
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
  }
  
  // Obtém os detalhes do prontuário médico de um paciente
  Future<Map<String, dynamic>?> getPatientMedicalRecord(int patientId) async {
    return await _dbHelper.getMedicalRecordByUserId(patientId);
  }
  
  // Verifica se o médico tem permissão para acessar o prontuário do paciente
  Future<bool> hasPermission(int doctorId, int patientId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'doctor_permissions',
      where: 'doctor_id = ? AND user_id = ? AND is_active = 1',
      whereArgs: [doctorId, patientId],
    );
    return result.isNotEmpty;
  }
}