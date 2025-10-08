import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'salusflow.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de usuários
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cpf_cnpj TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        user_type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabela de prontuários médicos
    await db.execute('''
      CREATE TABLE medical_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        allergies TEXT,
        diagnoses TEXT,
        medications TEXT,
        blood_type TEXT,
        vaccination_card TEXT,
        authorize_transfusion INTEGER DEFAULT 0,
        observations TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Tabela de certificados digitais
    await db.execute('''
      CREATE TABLE digital_certificates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        certificate_id TEXT UNIQUE NOT NULL,
        cnpj TEXT NOT NULL,
        company_name TEXT NOT NULL,
        valid_from TEXT NOT NULL,
        valid_to TEXT NOT NULL,
        issuer TEXT NOT NULL,
        serial_number TEXT NOT NULL,
        public_key TEXT NOT NULL,
        is_valid INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    
    // Tabela de permissões de acesso
    await db.execute('''
      CREATE TABLE permissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        clinic_id INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        notes TEXT,
        granted_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (clinic_id) REFERENCES users (id)
      )
    ''');

    // Inserir dados de exemplo
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // Usuário de exemplo - Pessoa Física
    await db.insert('users', {
      'cpf_cnpj': '123.456.789-00',
      'name': 'João Silva',
      'email': 'joao@email.com',
      'password': '123456', // Em produção, usar hash
      'user_type': 'fisica',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Usuário de exemplo - Pessoa Jurídica
    await db.insert('users', {
      'cpf_cnpj': '12.345.678/0001-90',
      'name': 'Clínica SalusFlow',
      'email': 'contato@salusflow.com',
      'password': '123456', // Em produção, usar hash
      'user_type': 'juridica',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Certificado digital de exemplo
    await db.insert('digital_certificates', {
      'user_id': 2, // Clínica SalusFlow
      'certificate_id': 'CERT-001-2024',
      'cnpj': '12.345.678/0001-90',
      'company_name': 'Clínica SalusFlow',
      'valid_from': '2024-01-01T00:00:00.000Z',
      'valid_to': '2025-12-31T23:59:59.000Z',
      'issuer': 'Autoridade Certificadora Nacional',
      'serial_number': 'SN-123456789',
      'public_key': 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...',
      'is_valid': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Prontuário de exemplo
    await db.insert('medical_records', {
      'user_id': 1, // João Silva
      'allergies': 'Penicilina, Amendoim',
      'diagnoses': 'Hipertensão arterial, Diabetes tipo 2',
      'medications': 'Losartana 50mg (1x ao dia), Metformina 850mg (2x ao dia)',
      'blood_type': 'O+',
      'vaccination_card': 'Cartão de vacinação atualizado',
      'authorize_transfusion': 1,
      'observations': 'Paciente com histórico familiar de diabetes',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Métodos para usuários
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByCpfCnpj(String cpfCnpj) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'cpf_cnpj = ?',
      whereArgs: [cpfCnpj],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> validateUser(String cpfCnpj, String password) async {
    final user = await getUserByCpfCnpj(cpfCnpj);
    return user != null && user['password'] == password;
  }
  
  // Obter todas as pessoas jurídicas
  Future<List<Map<String, dynamic>>> getAllJuridicalUsers() async {
    final db = await database;
    return await db.query(
      'users',
      where: 'user_type = ?',
      whereArgs: ['juridica'],
    );
  }

  // Métodos para prontuários
  Future<int> insertMedicalRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('medical_records', record);
  }

  Future<Map<String, dynamic>?> getMedicalRecordByUserId(int userId) async {
    final db = await database;
    final result = await db.query(
      'medical_records',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateMedicalRecord(
    int userId,
    Map<String, dynamic> record,
  ) async {
    final db = await database;
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'medical_records',
      record,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Métodos para certificados digitais
  Future<int> insertCertificate(Map<String, dynamic> certificate) async {
    final db = await database;
    return await db.insert('digital_certificates', certificate);
  }

  Future<Map<String, dynamic>?> getCertificateByCnpj(String cnpj) async {
    final db = await database;
    final result = await db.query(
      'digital_certificates',
      where: 'cnpj = ? AND is_valid = 1',
      whereArgs: [cnpj],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllCertificates() async {
    final db = await database;
    return await db.query('digital_certificates');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
  
  // Métodos para permissões
  Future<int> insertPermission(Map<String, dynamic> permission) async {
    final db = await database;
    return await db.insert('permissions', permission);
  }
  
  Future<Map<String, dynamic>?> getPermission(int userId, int clinicId) async {
    final db = await database;
    final result = await db.query(
      'permissions',
      where: 'user_id = ? AND clinic_id = ?',
      whereArgs: [userId, clinicId],
    );
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<bool> updatePermission(int userId, int clinicId, Map<String, dynamic> data) async {
    final db = await database;
    final result = await db.update(
      'permissions',
      data,
      where: 'user_id = ? AND clinic_id = ?',
      whereArgs: [userId, clinicId],
    );
    return result > 0;
  }
  
  Future<List<Map<String, dynamic>>> getUserPermissions(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.*, u.name as clinic_name, u.cpf_cnpj as clinic_cpf_cnpj
      FROM permissions p
      JOIN users u ON p.clinic_id = u.id
      WHERE p.user_id = ?
      ORDER BY p.updated_at DESC
    ''', [userId]);
  }
  
  Future<List<Map<String, dynamic>>> getActiveClinicPermissions(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.*, u.name as clinic_name, u.cpf_cnpj as clinic_cpf_cnpj
      FROM permissions p
      JOIN users u ON p.clinic_id = u.id
      WHERE p.user_id = ? AND p.is_active = 1
      ORDER BY p.updated_at DESC
    ''', [userId]);
  }
}
