import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salusflow/services/auth_service.dart';
import 'package:salusflow/screens/documents/documents_screen.dart';
import 'package:salusflow/screens/partners/partners_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(
        onNavigate: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const DocumentsScreen(),
      const PartnersScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SalusFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            label: 'Documentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Parceiros',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeContent({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cartão de boas-vindas conforme wireframe
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bem-vindo(a)',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authService.userName ?? 'Ciclano de Tal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CPF: ${authService.userCpf ?? "111.111.111-11"}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Seção de acesso rápido conforme wireframe
          const Text(
            'Acesso Rápido',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Layout conforme o wireframe - dois cards lado a lado
          Row(
            children: [
              Expanded(
                child: _buildSquareAccessCard(
                  context,
                  'Meu Documentos',
                  Icons.folder_open,
                  Colors.blue,
                  () => onNavigate(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSquareAccessCard(
                  context,
                  'Parceiros',
                  Icons.business,
                  Colors.amber,
                  () => onNavigate(2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSquareAccessCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
