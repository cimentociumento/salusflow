import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salusflow/database/database_helper.dart';

class AuthService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  String? _userName;
  String? _userCpfCnpj;
  String? _userEmail;
  String? _userType;
  String? _userBirthDate;
  int? _userId;
  bool _isLoading = false;

  String? get userName => _userName;
  String? get userCpf => _userCpfCnpj;
  String? get userCnpj => _userCpfCnpj;
  String? get userEmail => _userEmail;
  String? get userType => _userType;
  String? get userBirthDate => _userBirthDate;
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
    _userBirthDate = prefs.getString('userBirthDate');
    _userId = prefs.getInt('userId');
    notifyListeners();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName ?? '');
    await prefs.setString('userCpfCnpj', _userCpfCnpj ?? '');
    await prefs.setString('userEmail', _userEmail ?? '');
    await prefs.setString('userType', _userType ?? '');
    await prefs.setString('userBirthDate', _userBirthDate ?? '');
    await prefs.setInt('userId', _userId ?? 0);
  }

  Future<bool> login(String cpfCnpj, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Normaliza entradas
      final id = cpfCnpj.trim();
      final pass = password.trim();

      // Validar credenciais no banco SQLite
      final isValid = await _dbHelper.validateUser(id, pass);
      
      if (isValid) {
        final user = await _dbHelper.getUserByCpfCnpj(id);
        if (user != null) {
          _userId = user['id'];
          _userName = user['name'];
          _userCpfCnpj = user['cpf_cnpj'];
          _userEmail = user['email'];
          _userType = user['user_type'];
          _userBirthDate = user['birth_date'];
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


  Future<bool> register(String name, String cpfCnpj, String email, String password, String birthDate) async {
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

      // Determinar tipo de usuário baseado no formato do identificador
      String userType = 'fisica';
      if (cpfCnpj.startsWith('CRM') || cpfCnpj.contains('/')) {
        userType = 'medico';
      }

      // Criar novo usuário
      int userId = 0;
      try {
        // Tenta inserir com birth_date se for pessoa física
        if (userType == 'fisica' && birthDate.isNotEmpty) {
          userId = await _dbHelper.insertUser({
            'cpf_cnpj': cpfCnpj,
            'name': name,
            'email': email,
            'password': password, // Em produção, usar hash
            'user_type': userType,
            'birth_date': birthDate,
            'created_at': DateTime.now().toIso8601String(),
          });
        } else {
          // Para médicos ou sem birth_date
          userId = await _dbHelper.insertUser({
            'cpf_cnpj': cpfCnpj,
            'name': name,
            'email': email,
            'password': password,
            'user_type': userType,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        debugPrint('Erro ao inserir usuário: ${e.toString()}');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (userId > 0) {
        _userId = userId;
        _userName = name;
        _userCpfCnpj = cpfCnpj;
        _userEmail = email;
        _userType = userType;
        _userBirthDate = birthDate;
        await _saveUserData();
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
    _userBirthDate = null;
    _userId = null;
    notifyListeners();
  }

}