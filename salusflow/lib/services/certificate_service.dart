import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:salusflow/models/certificate.dart';
import 'package:salusflow/database/database_helper.dart';

class CertificateService {
  static final CertificateService _instance = CertificateService._internal();
  factory CertificateService() => _instance;
  CertificateService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Simular validação de certificado digital
  Future<bool> validateCertificate(String cnpj, String certificateData) async {
    try {
      // Buscar certificado no banco
      final certificate = await _dbHelper.getCertificateByCnpj(cnpj);
      
      if (certificate == null) {
        return false;
      }

      // Verificar se o certificado não está expirado
      final validTo = DateTime.parse(certificate['valid_to']);
      if (DateTime.now().isAfter(validTo)) {
        return false;
      }

      // Simular validação de assinatura digital
      final isValidSignature = _validateDigitalSignature(certificateData, certificate['public_key']);
      
      return certificate['is_valid'] == 1 && isValidSignature;
    } catch (e) {
      return false;
    }
  }

  // Simular validação de assinatura digital
  bool _validateDigitalSignature(String data, String publicKey) {
    // Em um sistema real, isso seria uma validação criptográfica complexa
    // Aqui simulamos com hash simples
    final hash = sha256.convert(utf8.encode(data + publicKey)).toString();
    return hash.isNotEmpty;
  }

  // Gerar certificado digital simulado
  Future<DigitalCertificate> generateCertificate({
    required String cnpj,
    required String companyName,
    required int userId,
  }) async {
    final now = DateTime.now();
    final validTo = now.add(const Duration(days: 365)); // Válido por 1 ano

    final certificate = DigitalCertificate(
      id: 'CERT-${now.millisecondsSinceEpoch}',
      cnpj: cnpj,
      companyName: companyName,
      validFrom: now.toIso8601String(),
      validTo: validTo.toIso8601String(),
      issuer: 'Autoridade Certificadora Nacional',
      serialNumber: 'SN-${now.millisecondsSinceEpoch}',
      publicKey: _generatePublicKey(),
      isValid: true,
    );

    // Salvar no banco
    await _dbHelper.insertCertificate({
      'user_id': userId,
      'certificate_id': certificate.id,
      'cnpj': certificate.cnpj,
      'company_name': certificate.companyName,
      'valid_from': certificate.validFrom,
      'valid_to': certificate.validTo,
      'issuer': certificate.issuer,
      'serial_number': certificate.serialNumber,
      'public_key': certificate.publicKey,
      'is_valid': certificate.isValid ? 1 : 0,
      'created_at': now.toIso8601String(),
    });

    return certificate;
  }

  // Gerar chave pública simulada
  String _generatePublicKey() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = sha256.convert(utf8.encode(random)).toString();
    return 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA$hash';
  }

  // Buscar certificado por CNPJ
  Future<DigitalCertificate?> getCertificateByCnpj(String cnpj) async {
    final certificateData = await _dbHelper.getCertificateByCnpj(cnpj);
    
    if (certificateData == null) {
      return null;
    }

    return DigitalCertificate(
      id: certificateData['certificate_id'],
      cnpj: certificateData['cnpj'],
      companyName: certificateData['company_name'],
      validFrom: certificateData['valid_from'],
      validTo: certificateData['valid_to'],
      issuer: certificateData['issuer'],
      serialNumber: certificateData['serial_number'],
      publicKey: certificateData['public_key'],
      isValid: certificateData['is_valid'] == 1,
    );
  }

  // Listar todos os certificados
  Future<List<DigitalCertificate>> getAllCertificates() async {
    final certificatesData = await _dbHelper.getAllCertificates();
    
    return certificatesData.map((data) => DigitalCertificate(
      id: data['certificate_id'],
      cnpj: data['cnpj'],
      companyName: data['company_name'],
      validFrom: data['valid_from'],
      validTo: data['valid_to'],
      issuer: data['issuer'],
      serialNumber: data['serial_number'],
      publicKey: data['public_key'],
      isValid: data['is_valid'] == 1,
    )).toList();
  }

  // Revogar certificado
  Future<bool> revokeCertificate(String certificateId) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'digital_certificates',
        {'is_valid': 0},
        where: 'certificate_id = ?',
        whereArgs: [certificateId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Verificar se empresa tem certificado válido
  Future<bool> hasValidCertificate(String cnpj) async {
    final certificate = await getCertificateByCnpj(cnpj);
    return certificate != null && certificate.isValid && !certificate.isExpired;
  }
}
