import 'package:flutter/material.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<Map<String, dynamic>> _documents = [
    {
      'id': '63452131316',
      'type': 'Exame',
      'description': 'Exame: tal 02/03/2003',
      'institution': 'UFVIM',
      'date': '02/03/2003',
      'isSelected': false,
      'dimensions': '264 x 326',
    },
    {
      'id': '63452131317',
      'type': 'Consulta',
      'description': 'Consulta: tal 12/01/2003',
      'institution': 'UFVIM',
      'date': '12/01/2003',
      'isSelected': true,
      'dimensions': '264 x 326',
    },
    {
      'id': '63452131318',
      'type': 'Exame',
      'description': 'Exame: tal 15/02/2003',
      'institution': 'UFVIM',
      'date': '15/02/2003',
      'isSelected': false,
      'dimensions': '264 x 326',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da tela
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Meus Documentos Médicos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        // Lista de documentos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _documents.length,
            itemBuilder: (context, index) {
              final document = _documents[index];
              return _buildDocumentCard(context, document, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(BuildContext context, Map<String, dynamic> document, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: document['isSelected'] 
            ? BorderSide(color: Colors.blue, width: 2, style: BorderStyle.solid)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _selectDocument(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do documento com logo UFVIM
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'UFVIM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document['description'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${document['id']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (document['isSelected'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        document['dimensions'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDocument(int index) {
    setState(() {
      // Desmarcar todos os documentos
      for (int i = 0; i < _documents.length; i++) {
        _documents[i]['isSelected'] = false;
      }
      // Marcar o documento selecionado
      _documents[index]['isSelected'] = true;
    });
  }
}
