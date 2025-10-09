import 'package:flutter/foundation.dart';
import 'package:salusflow/models/certificate.dart';

class CertificateService extends ChangeNotifier {
  DigitalCertificate? _currentCertificate;
  bool _isLoading = false;

  DigitalCertificate? get currentCertificate => _currentCertificate;
  bool get isLoading => _isLoading;

  // Carrega um certificado padrão (simulado) para todos os médicos
  // Chamado automaticamente quando o serviço é criado via Provider
  CertificateService() {
    _bootstrapDefaultCertificate();
  }

  Future<void> _bootstrapDefaultCertificate() async {
    // Simula um certificado já baixado, válido por 1 ano
    final now = DateTime.now();
    _currentCertificate = DigitalCertificate(
      id: 'CERT_DEFAULT',
      cnpj: '11.111.111/0001-00',
      companyName: 'Autoridade Certificadora Simulada - SalusFlow',
      validFrom: now.subtract(const Duration(days: 30)).toIso8601String(),
      validTo: now.add(const Duration(days: 335)).toIso8601String(),
      issuer: 'AC SalusFlow (Simulado)',
      serialNumber: 'SN_DEFAULT_0001',
      publicKey: _generateSimulatedPublicKey(),
      isValid: true,
    );
    notifyListeners();
  }

  // Simular certificado digital para demonstração
  Future<DigitalCertificate> generateSimulatedCertificate(
    String cnpj,
    String companyName,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular delay de geração
      await Future.delayed(const Duration(seconds: 2));

      final now = DateTime.now();
      final validFrom = now;
      final validTo = now.add(const Duration(days: 365)); // Válido por 1 ano

      final certificate = DigitalCertificate(
        id: 'CERT_${cnpj.replaceAll(RegExp(r'[^0-9]'), '')}_${now.millisecondsSinceEpoch}',
        cnpj: cnpj,
        companyName: companyName,
        validFrom: validFrom.toIso8601String(),
        validTo: validTo.toIso8601String(),
        issuer: 'Autoridade Certificadora Simulada - SalusFlow',
        serialNumber: 'SN${now.millisecondsSinceEpoch}',
        publicKey: _generateSimulatedPublicKey(),
        isValid: true,
      );

      _currentCertificate = certificate;
      _isLoading = false;
      notifyListeners();

      return certificate;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  String _generateSimulatedPublicKey() {
    // Simular uma chave pública (em produção seria uma chave real)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA${timestamp.toString().substring(0, 20)}...';
  }

  Future<bool> validateCertificate(String certificateId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular validação
      await Future.delayed(const Duration(seconds: 1));

      if (_currentCertificate != null &&
          _currentCertificate!.id == certificateId) {
        final isValid =
            !_currentCertificate!.isExpired && _currentCertificate!.isValid;
        _isLoading = false;
        notifyListeners();
        return isValid;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> revokeCertificate(String certificateId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular revogação
      await Future.delayed(const Duration(seconds: 1));

      if (_currentCertificate != null &&
          _currentCertificate!.id == certificateId) {
        _currentCertificate = DigitalCertificate(
          id: _currentCertificate!.id,
          cnpj: _currentCertificate!.cnpj,
          companyName: _currentCertificate!.companyName,
          validFrom: _currentCertificate!.validFrom,
          validTo: _currentCertificate!.validTo,
          issuer: _currentCertificate!.issuer,
          serialNumber: _currentCertificate!.serialNumber,
          publicKey: _currentCertificate!.publicKey,
          isValid: false, // Revogado
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<DigitalCertificate>> getCertificateHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simular histórico de certificados
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      final history = <DigitalCertificate>[];

      // Certificado atual
      if (_currentCertificate != null) {
        history.add(_currentCertificate!);
      }

      // Simular certificados anteriores
      for (int i = 1; i <= 3; i++) {
        final pastDate = now.subtract(Duration(days: 365 * i));
        history.add(
          DigitalCertificate(
            id: 'CERT_PAST_$i',
            cnpj: _currentCertificate?.cnpj ?? '11.111.111/0001-00',
            companyName: _currentCertificate?.companyName ?? 'Empresa Exemplo',
            validFrom: pastDate.toIso8601String(),
            validTo: pastDate.add(const Duration(days: 365)).toIso8601String(),
            issuer: 'Autoridade Certificadora Simulada - SalusFlow',
            serialNumber: 'SN_PAST_$i',
            publicKey: _generateSimulatedPublicKey(),
            isValid: false, // Expirado
          ),
        );
      }

      _isLoading = false;
      notifyListeners();
      return history;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  void clearCertificate() {
    _currentCertificate = null;
    notifyListeners();
  }
}
