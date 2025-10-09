import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salusflow/services/certificate_service.dart';
import 'package:salusflow/models/certificate.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final _cnpjController = TextEditingController();
  final _companyNameController = TextEditingController();
  bool _showHistory = false;

  @override
  void dispose() {
    _cnpjController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final certificateService = Provider.of<CertificateService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificado Digital'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de geração de certificado
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gerar Certificado Digital',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cnpjController,
                      decoration: const InputDecoration(
                        labelText: 'CNPJ',
                        hintText: '00.000.000/0000-00',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Empresa',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: certificateService.isLoading
                            ? null
                            : () => _generateCertificate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: certificateService.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Gerar Certificado'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Certificado atual
            if (certificateService.currentCertificate != null)
              _buildCurrentCertificate(certificateService.currentCertificate!),

            const SizedBox(height: 24),

            // Botões de ação
            if (certificateService.currentCertificate != null)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _validateCertificate(context),
                      icon: const Icon(Icons.verified_user),
                      label: const Text('Validar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _revokeCertificate(context),
                      icon: const Icon(Icons.block),
                      label: const Text('Revogar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Histórico de certificados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Histórico de Certificados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showHistory = !_showHistory;
                    });
                  },
                  icon: Icon(_showHistory ? Icons.expand_less : Icons.expand_more),
                  label: Text(_showHistory ? 'Ocultar' : 'Mostrar'),
                ),
              ],
            ),

            if (_showHistory)
              FutureBuilder<List<DigitalCertificate>>(
                future: certificateService.getCertificateHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Text('Erro ao carregar histórico');
                  }

                  final certificates = snapshot.data ?? [];
                  return Column(
                    children: certificates.map((cert) => _buildCertificateCard(cert)).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentCertificate(DigitalCertificate certificate) {
    return Card(
      elevation: 4,
      color: certificate.isValid ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  certificate.isValid ? Icons.verified : Icons.error,
                  color: certificate.isValid ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  certificate.isValid ? 'Certificado Válido' : 'Certificado Inválido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: certificate.isValid ? Colors.green[700] : Colors.red[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ID:', certificate.id),
            _buildInfoRow('CNPJ:', certificate.cnpj),
            _buildInfoRow('Empresa:', certificate.companyName),
            _buildInfoRow('Emissor:', certificate.issuer),
            _buildInfoRow('Número Serial:', certificate.serialNumber),
            _buildInfoRow('Válido de:', _formatDate(certificate.validFrom)),
            _buildInfoRow('Válido até:', _formatDate(certificate.validTo)),
            _buildInfoRow('Status:', certificate.isExpired ? 'Expirado' : 'Ativo'),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard(DigitalCertificate certificate) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: certificate.isValid ? Colors.green[50] : Colors.grey[100],
      child: ListTile(
        leading: Icon(
          certificate.isValid ? Icons.verified : Icons.error_outline,
          color: certificate.isValid ? Colors.green : Colors.grey,
        ),
        title: Text(certificate.companyName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CNPJ: ${certificate.cnpj}'),
            Text('Válido até: ${_formatDate(certificate.validTo)}'),
            Text(
              certificate.isExpired ? 'Expirado' : 'Ativo',
              style: TextStyle(
                color: certificate.isExpired ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _generateCertificate(BuildContext context) async {
    if (_cnpjController.text.isEmpty || _companyNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final certificateService = Provider.of<CertificateService>(context, listen: false);
      await certificateService.generateSimulatedCertificate(
        _cnpjController.text,
        _companyNameController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificado gerado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar certificado: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _validateCertificate(BuildContext context) async {
    final certificateService = Provider.of<CertificateService>(context, listen: false);
    final certificate = certificateService.currentCertificate;
    
    if (certificate == null) return;

    try {
      final isValid = await certificateService.validateCertificate(certificate.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isValid ? 'Certificado válido!' : 'Certificado inválido!'),
          backgroundColor: isValid ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao validar certificado: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _revokeCertificate(BuildContext context) async {
    final certificateService = Provider.of<CertificateService>(context, listen: false);
    final certificate = certificateService.currentCertificate;
    
    if (certificate == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Certificado'),
        content: const Text('Tem certeza que deseja revogar este certificado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await certificateService.revokeCertificate(certificate.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificado revogado com sucesso!'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao revogar certificado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
