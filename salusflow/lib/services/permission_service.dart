import 'package:flutter/foundation.dart';
import 'package:salusflow/database/database_helper.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Conceder permissão para um médico acessar o prontuário
  Future<bool> grantPermission({
    required int userId,
    required int doctorId,
    required String doctorName,
    required String doctorAddress,
  }) async {
    try {
      final permissionData = {
        'user_id': userId,
        'doctor_id': doctorId,
        'doctor_name': doctorName,
        'doctor_address': doctorAddress,
        'is_active': 1,
        'granted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Verificar se já existe uma permissão
      final existingPermission = await _dbHelper.getDoctorPermission(userId, doctorId);

      if (existingPermission != null) {
        // Atualizar permissão existente
        return await _dbHelper.updateDoctorPermission(userId, doctorId, {'is_active': 1, 'updated_at': DateTime.now().toIso8601String()});
      } else {
        // Criar nova permissão
        final result = await _dbHelper.insertDoctorPermission(permissionData);
        return result > 0;
      }
    } catch (e) {
      debugPrint('Erro ao conceder permissão: $e');
      return false;
    }
  }

  // Revogar permissão de um médico
  Future<bool> revokePermission({
    required int userId,
    required int doctorId,
  }) async {
    try {
      // Verificar se existe uma permissão
      final existingPermission = await _dbHelper.getDoctorPermission(userId, doctorId);

      if (existingPermission != null) {
        // Desativar permissão existente
        return await _dbHelper.updateDoctorPermission(userId, doctorId, {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()});
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao revogar permissão: $e');
      return false;
    }
  }

  // Obter todas as permissões de um usuário
  Future<List<Map<String, dynamic>>> getUserPermissions(int userId) async {
    try {
      return await _dbHelper.getUserDoctorPermissions(userId);
    } catch (e) {
      debugPrint('Erro ao obter permissões: $e');
      return [];
    }
  }

  // Verificar se um médico tem permissão para acessar o prontuário de um usuário
  Future<bool> hasPermission({
    required int userId,
    required int doctorId,
  }) async {
    try {
      final permission = await _dbHelper.getDoctorPermission(userId, doctorId);
      return permission != null && permission['is_active'] == 1;
    } catch (e) {
      debugPrint('Erro ao verificar permissão: $e');
      return false;
    }
  }

  // Obter todos os médicos com permissão ativa para um usuário
  Future<List<Map<String, dynamic>>> getActiveDoctorPermissions(int userId) async {
    try {
      return await _dbHelper.getActiveDoctorPermissions(userId);
    } catch (e) {
      debugPrint('Erro ao obter médicos com permissão: $e');
      return [];
    }
  }
}