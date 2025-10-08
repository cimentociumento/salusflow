import 'package:flutter/material.dart';
import 'package:salusflow/database/database_helper.dart';
import 'package:salusflow/services/permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  final PermissionService _permissionService = PermissionService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _partners = [];
  bool _isLoading = false;
  int _userId = 1; // Valor padrão, será atualizado no initState

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id') ?? 1;
    });
    _loadPartners();
  }

  Future<void> _loadPartners() async {
    setState(() {
      _isLoading = true;
    });

    // Obter todas as pessoas jurídicas do banco de dados
    final juridicalUsers = await _dbHelper.getAllJuridicalUsers();
    
    // Categorizar as pessoas jurídicas (simplificado para demonstração)
    final realPartners = juridicalUsers.map((user) {
      // Determinar o tipo com base no nome (simplificado)
      String type = 'clinic';
      if (user['name'].toString().toLowerCase().contains('hospital')) {
        type = 'hospital';
      } else if (user['name'].toString().toLowerCase().contains('lab') || 
                user['name'].toString().toLowerCase().contains('laboratório')) {
        type = 'lab';
      }
      
      return {
        'id': user['id'],
        'name': user['name'],
        'address': 'Endereço não disponível', // Em um app real, teria um campo de endereço
        'type': type,
        'cpf_cnpj': user['cpf_cnpj'],
      };
    }).toList();

    // Obter permissões ativas do usuário
    final activePermissions = await _permissionService.getActiveClinicPermissions(_userId);
    final activeClinicIds = activePermissions.map((p) => p['clinic_id'] as int).toList();

    // Atualizar status de permissão para cada parceiro
    final updatedPartners = realPartners.map((partner) {
      return {
        ...partner,
        'has_permission': activeClinicIds.contains(partner['id']),
      };
    }).toList();

    setState(() {
      _partners = updatedPartners;
      _isLoading = false;
    });
  }

  Future<void> _togglePermission(int clinicId, bool currentStatus) async {
    setState(() {
      _isLoading = true;
    });

    bool success;
    if (currentStatus) {
      // Revogar permissão
      success = await _permissionService.revokePermission(
        userId: _userId,
        clinicId: clinicId,
      );
    } else {
      // Conceder permissão
      success = await _permissionService.grantPermission(
        userId: _userId,
        clinicId: clinicId,
      );
    }

    if (success) {
      // Atualizar a lista de parceiros
      await _loadPartners();
    } else {
      // Mostrar mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar permissão. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parceiros de Saúde',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Instituições que podem acessar seu prontuário médico',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Lista de hospitais
                  const Text(
                    'Hospitais',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._partners
                      .where((p) => p['type'] == 'hospital')
                      .map(
                        (partner) => _buildPartnerCard(
                          context,
                          partner['name'],
                          partner['address'],
                          partner['type'],
                          partner['has_permission'],
                          partner['id'],
                        ),
                      ),

                  const SizedBox(height: 16),
                  const Text(
                    'Clínicas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._partners
                      .where((p) => p['type'] == 'clinic')
                      .map(
                        (partner) => _buildPartnerCard(
                          context,
                          partner['name'],
                          partner['address'],
                          partner['type'],
                          partner['has_permission'],
                          partner['id'],
                        ),
                      ),

                  const SizedBox(height: 16),
                  const Text(
                    'Laboratórios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._partners
                      .where((p) => p['type'] == 'lab')
                      .map(
                        (partner) => _buildPartnerCard(
                          context,
                          partner['name'],
                          partner['address'],
                          partner['type'],
                          partner['has_permission'],
                          partner['id'],
                        ),
                      ),

                  const SizedBox(height: 32),

                  // Seção de informações sobre permissões
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sobre as permissões de acesso',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'As instituições com permissão ativa podem apenas visualizar seu prontuário médico. Apenas você pode adicionar ou alterar informações no seu prontuário.',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Você pode ativar ou desativar o acesso a qualquer momento.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // Seção de termos de compartilhamento
                  const Text(
                    'Termos de Compartilhamento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ao compartilhar seus dados com parceiros, você concorda que:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildTermItem(
                            '1. Seus dados serão utilizados apenas para fins médicos e de atendimento.',
                          ),
                          _buildTermItem(
                            '2. Você pode revogar o acesso a qualquer momento.',
                          ),
                          _buildTermItem(
                            '3. Apenas profissionais autorizados terão acesso às suas informações.',
                          ),
                          _buildTermItem(
                            '4. Seus dados são protegidos por criptografia e medidas de segurança.',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showTermsDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Ver Termos Completos'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPartnerDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPartnerCard(
    BuildContext context,
    String name,
    String address,
    String type,
    bool hasPermission,
    int clinicId,
  ) {
    IconData icon;
    Color color;

    switch (type) {
      case 'hospital':
        icon = Icons.local_hospital;
        color = Colors.red;
        break;
      case 'clinic':
        icon = Icons.medical_services;
        color = Colors.blue;
        break;
      case 'lab':
        icon = Icons.science;
        color = Colors.purple;
        break;
      default:
        icon = Icons.business;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    address,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch(
              value: hasPermission,
              onChanged: (value) {
                _togglePermission(clinicId, hasPermission);
              },
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termos de Compartilhamento'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Termos de Compartilhamento de Dados Médicos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Ao utilizar o aplicativo MediRecord e autorizar o compartilhamento de seus dados médicos com instituições parceiras, você concorda com os seguintes termos:\n\n'
                '1. Seus dados médicos serão compartilhados apenas com as instituições que você explicitamente autorizar.\n\n'
                '2. O compartilhamento tem como finalidade exclusiva o seu atendimento médico e a continuidade do seu cuidado.\n\n'
                '3. Você pode revogar a autorização de acesso a qualquer momento através do aplicativo.\n\n'
                '4. Apenas profissionais de saúde devidamente cadastrados e autorizados terão acesso às suas informações.\n\n'
                '5. Seus dados são protegidos por criptografia e medidas de segurança conforme a LGPD (Lei Geral de Proteção de Dados).\n\n'
                '6. As instituições parceiras comprometem-se a utilizar seus dados apenas para fins médicos e não podem compartilhá-los com terceiros sem sua autorização expressa.\n\n'
                '7. O aplicativo mantém registros de todos os acessos realizados ao seu prontuário para fins de auditoria e segurança.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showAddPartnerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Parceiro'),
        content: const SingleChildScrollView(
          child: Text(
            'Em um aplicativo real, aqui você poderia buscar e adicionar novos parceiros de saúde (hospitais, clínicas e laboratórios) para compartilhar seu prontuário médico.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
