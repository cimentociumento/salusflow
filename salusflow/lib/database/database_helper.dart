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
    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adicionar coluna birth_date se não existir
      await db.execute('ALTER TABLE users ADD COLUMN birth_date TEXT');
    }
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
        birth_date TEXT,
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

    
    // Tabela de permissões de acesso para médicos
    await db.execute('''
      CREATE TABLE doctor_permissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        doctor_id INTEGER NOT NULL,
        doctor_name TEXT NOT NULL,
        doctor_address TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        granted_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Inserir dados de exemplo
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    // Usuário de exemplo - Pessoa Física
    await db.insert('users', {
      'cpf_cnpj': '111.111.111-11',
      'name': 'Ciclano de Tal',
      'email': 'fulano.de.tal@hotmail.com',
      'password': '123456', // Em produção, usar hash
      'user_type': 'fisica',
      'birth_date': '1990-05-15',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Prontuário de exemplo
    await db.insert('medical_records', {
      'user_id': 1, // Ciclano de Tal
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

    // Permissões de médicos de exemplo
    final doctors = [
      {'id': 1, 'name': 'Claudio Peralta', 'address': 'Rua das Flores,123 - Centro'},
      {'id': 2, 'name': 'Arnaldo da Silva', 'address': 'Av. Brasil,789 - Jardins'},
      {'id': 3, 'name': 'Davi Ulisses Moreto GussO', 'address': 'Av. Paulista, 1000 - Bela Vista'},
      {'id': 4, 'name': 'Heitor Scalco Neto', 'address': 'Rua Consolação, 250 - Centro'},
      {'id': 5, 'name': 'Murilo Nhoqui', 'address': 'Rua Augusta, 500 - Cosnsolação'},
    ];

    for (var doctor in doctors) {
      await db.insert('doctor_permissions', {
        'user_id': 1,
        'doctor_id': doctor['id'],
        'doctor_name': doctor['name'],
        'doctor_address': doctor['address'],
        'is_active': (doctor['id'] as int) <= 4 ? 1 : 0, // Primeiros 4 ativos, último inativo
        'granted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
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


  Future<void> close() async {
    final db = await database;
    await db.close();
  }
  
  // Métodos para permissões de médicos
  Future<int> insertDoctorPermission(Map<String, dynamic> permission) async {
    final db = await database;
    return await db.insert('doctor_permissions', permission);
  }
  
  Future<Map<String, dynamic>?> getDoctorPermission(int userId, int doctorId) async {
    final db = await database;
    final result = await db.query(
      'doctor_permissions',
      where: 'user_id = ? AND doctor_id = ?',
      whereArgs: [userId, doctorId],
    );
    return result.isNotEmpty ? result.first : null;
  }
  
  Future<bool> updateDoctorPermission(int userId, int doctorId, Map<String, dynamic> data) async {
    final db = await database;
    final result = await db.update(
      'doctor_permissions',
      data,
      where: 'user_id = ? AND doctor_id = ?',
      whereArgs: [userId, doctorId],
    );
    return result > 0;
  }
  
  Future<List<Map<String, dynamic>>> getUserDoctorPermissions(int userId) async {
    final db = await database;
    return await db.query(
      'doctor_permissions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
  }
  
  Future<List<Map<String, dynamic>>> getActiveDoctorPermissions(int userId) async {
    final db = await database;
    return await db.query(
      'doctor_permissions',
      where: 'user_id = ? AND is_active = 1',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
  }
}
