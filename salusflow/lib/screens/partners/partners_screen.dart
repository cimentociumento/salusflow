import 'package:flutter/material.dart';

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': 1,
      'name': 'Claudio Peralta',
      'address': 'Rua das Flores,123 - Centro',
      'hasPermission': true,
    },
    {
      'id': 2,
      'name': 'Arnaldo da Silva',
      'address': 'Av. Brasil,789 - Jardins',
      'hasPermission': true,
    },
    {
      'id': 3,
      'name': 'Davi Ulisses Moreto GussO',
      'address': 'Av. Paulista, 1000 - Bela Vista',
      'hasPermission': true,
    },
    {
      'id': 4,
      'name': 'Heitor Scalco Neto',
      'address': 'Rua Consolação, 250 - Centro',
      'hasPermission': true,
    },
    {
      'id': 5,
      'name': 'Murilo Nhoqui',
      'address': 'Rua Augusta, 500 - Cosnsolação',
      'hasPermission': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título e subtítulo
        Padding(
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
            ],
          ),
        ),

        // Seção de Médicos
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Médicos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),

        // Lista de médicos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _doctors.length,
            itemBuilder: (context, index) {
              final doctor = _doctors[index];
              return _buildDoctorCard(context, doctor, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doctor, int index) {
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
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor['address'],
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch(
              value: doctor['hasPermission'],
              onChanged: (value) {
                setState(() {
                  doctor['hasPermission'] = value;
                });
                _showPermissionChangeDialog(context, doctor['name'], value);
              },
              activeThumbColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionChangeDialog(BuildContext context, String doctorName, bool hasPermission) {
    final message = hasPermission 
        ? 'Permissão concedida para $doctorName acessar seus documentos médicos.'
        : 'Permissão revogada para $doctorName acessar seus documentos médicos.';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: hasPermission ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}