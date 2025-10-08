import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final List<FamilyMember> _familyMembers = [
    FamilyMember(
      name: 'Maria Silva',
      relationship: 'Mãe',
      phone: '(11) 98765-4321',
      isEmergencyContact: true,
    ),
    FamilyMember(
      name: 'João Souza',
      relationship: 'Irmão',
      phone: '(11) 91234-5678',
      isEmergencyContact: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Familiares e Contatos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Lista de familiares
          Expanded(
            child: _familyMembers.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum familiar cadastrado',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _familyMembers.length,
                    itemBuilder: (context, index) {
                      final member = _familyMembers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(member.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member.relationship),
                              Text(member.phone),
                              if (member.isEmergencyContact)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.emergency,
                                      size: 16,
                                      color: Colors.red[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Contato de emergência',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddEditFamilyMemberDialog(
                              context,
                              member: member,
                              index: index,
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditFamilyMemberDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEditFamilyMemberDialog(
    BuildContext context, {
    FamilyMember? member,
    int? index,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: member?.name ?? '');
    final relationshipController = TextEditingController(
      text: member?.relationship ?? '',
    );
    final phoneController = MaskedTextController(
      mask: '(00) 00000-0000',
      text: member?.phone ?? '',
    );
    bool isEmergencyContact = member?.isEmergencyContact ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            member == null ? 'Adicionar Familiar' : 'Editar Familiar',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: relationshipController,
                    decoration: const InputDecoration(
                      labelText: 'Parentesco',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o parentesco';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o telefone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Contato de emergência'),
                    value: isEmergencyContact,
                    onChanged: (value) {
                      setState(() {
                        isEmergencyContact = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (member != null)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, index!);
                },
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newMember = FamilyMember(
                    name: nameController.text,
                    relationship: relationshipController.text,
                    phone: phoneController.text,
                    isEmergencyContact: isEmergencyContact,
                  );

                  if (member == null) {
                    // Adicionar novo familiar
                    setState(() {
                      _familyMembers.add(newMember);
                    });
                  } else {
                    // Atualizar familiar existente
                    setState(() {
                      _familyMembers[index!] = newMember;
                    });
                  }

                  Navigator.pop(context);

                  // Atualizar a tela
                  this.setState(() {});
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Familiar'),
        content: const Text('Tem certeza que deseja excluir este familiar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _familyMembers.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class FamilyMember {
  final String name;
  final String relationship;
  final String phone;
  final bool isEmergencyContact;

  FamilyMember({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.isEmergencyContact,
  });
}
