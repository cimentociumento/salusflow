import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salusflow/database/database_helper.dart';
import 'package:salusflow/services/certificate_service.dart';

class AuthService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final CertificateService _certificateService = CertificateService();
  
  String? _userName;
  String? _userCpfCnpj;
  String? _userEmail;
  String? _userType;
  int? _userId;
  bool _isLoading = false;

  String? get userName => _userName;
  String? get userCpf => _userCpfCnpj;
  String? get userCnpj => _userCpfCnpj;
  String? get userEmail => _userEmail;
  String? get userType => _userType;
  int? get userId => _userId;
  bool get isLoading => _isLoading;

  AuthService() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName');
    _userCpfCnpj = prefs.getString('userCpfCnpj');
    _userEmail = prefs.getString('userEmail');
    _userType = prefs.getString('userType');
    _userId = prefs.getInt('userId');
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName ?? '');
    await prefs.setString('userCpfCnpj', _userCpfCnpj ?? '');
    await prefs.setString('userEmail', _userEmail ?? '');
    await prefs.setString('userType', _userType ?? '');
    await prefs.setInt('userId', _userId ?? 0);
  }

  Future<bool> login(String cpfCnpj, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validar credenciais no banco SQLite
      final isValid = await _dbHelper.validateUser(cpfCnpj, password);
      
      if (isValid) {
        final user = await _dbHelper.getUserByCpfCnpj(cpfCnpj);
        if (user != null) {
          _userId = user['id'];
          _userName = user['name'];
          _userCpfCnpj = user['cpf_cnpj'];
          _userEmail = user['email'];
          _userType = user['user_type'];
          await _saveUserData();
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return isValid;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithCertificate(String cnpj, String certificateData) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Validar certificado digital
      final isValidCertificate = await _certificateService.validateCertificate(cnpj, certificateData);
      
      if (isValidCertificate) {
        final user = await _dbHelper.getUserByCpfCnpj(cnpj);
        if (user != null) {
          _userId = user['id'];
          _userName = user['name'];
          _userCpfCnpj = user['cpf_cnpj'];
          _userEmail = user['email'];
          _userType = user['user_type'];
          await _saveUserData();
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return isValidCertificate;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String cpfCnpj, String email, String password, String userType) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Verificar se usuário já existe
      final existingUser = await _dbHelper.getUserByCpfCnpj(cpfCnpj);
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false; // Usuário já existe
      }

      // Criar novo usuário
      final userId = await _dbHelper.insertUser({
        'cpf_cnpj': cpfCnpj,
        'name': name,
        'email': email,
        'password': password, // Em produção, usar hash
        'user_type': userType,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (userId > 0) {
        _userId = userId;
        _userName = name;
        _userCpfCnpj = cpfCnpj;
        _userEmail = email;
        _userType = userType;
        await _saveUserData();

        // Se for pessoa jurídica, gerar certificado digital
        if (userType == 'juridica') {
          await _certificateService.generateCertificate(
            cnpj: cpfCnpj,
            companyName: name,
            userId: userId,
          );
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return userId > 0;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    _userName = null;
    _userCpfCnpj = null;
    _userEmail = null;
    _userType = null;
    _userId = null;
    notifyListeners();
  }

  // Verificar se usuário tem certificado válido
  Future<bool> hasValidCertificate() async {
    if (_userType != 'juridica' || _userCpfCnpj == null) {
      return false;
    }
    return await _certificateService.hasValidCertificate(_userCpfCnpj!);
  }
}