import 'package:salusflow/database/database_helper.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Conceder permissão para uma clínica acessar o prontuário
  Future<bool> grantPermission({
    required int userId,
    required int clinicId,
    String? notes,
  }) async {
    try {
      final permissionData = {
        'user_id': userId,
        'clinic_id': clinicId,
        'is_active': 1,
        'notes': notes,
        'granted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Verificar se já existe uma permissão
      final existingPermission = await _dbHelper.getPermission(userId, clinicId);

      if (existingPermission != null) {
        // Atualizar permissão existente
        return await _dbHelper.updatePermission(userId, clinicId, {'is_active': 1, 'updated_at': DateTime.now().toIso8601String()});
      } else {
        // Criar nova permissão
        final result = await _dbHelper.insertPermission(permissionData);
        return result > 0;
      }
    } catch (e) {
      print('Erro ao conceder permissão: $e');
      return false;
    }
  }

  // Revogar permissão de uma clínica
  Future<bool> revokePermission({
    required int userId,
    required int clinicId,
  }) async {
    try {
      // Verificar se existe uma permissão
      final existingPermission = await _dbHelper.getPermission(userId, clinicId);

      if (existingPermission != null) {
        // Desativar permissão existente
        return await _dbHelper.updatePermission(userId, clinicId, {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()});
      }
      return false;
    } catch (e) {
      print('Erro ao revogar permissão: $e');
      return false;
    }
  }

  // Obter todas as permissões de um usuário
  Future<List<Map<String, dynamic>>> getUserPermissions(int userId) async {
    try {
      return await _dbHelper.getUserPermissions(userId);
    } catch (e) {
      print('Erro ao obter permissões: $e');
      return [];
    }
  }

  // Verificar se uma clínica tem permissão para acessar o prontuário de um usuário
  Future<bool> hasPermission({
    required int userId,
    required int clinicId,
  }) async {
    try {
      final permission = await _dbHelper.getPermission(userId, clinicId);
      return permission != null && permission['is_active'] == 1;
    } catch (e) {
      print('Erro ao verificar permissão: $e');
      return false;
    }
  }

  // Obter todas as clínicas com permissão ativa para um usuário
  Future<List<Map<String, dynamic>>> getActiveClinicPermissions(int userId) async {
    try {
      return await _dbHelper.getActiveClinicPermissions(userId);
    } catch (e) {
      print('Erro ao obter clínicas com permissão: $e');
      return [];
    }
  }
}