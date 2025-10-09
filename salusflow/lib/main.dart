import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salusflow/screens/auth/login_screen.dart';
import 'package:salusflow/screens/auth/register_screen.dart';
import 'package:salusflow/screens/home/home_screen.dart';
import 'package:salusflow/screens/profile/profile_screen.dart';
import 'package:salusflow/services/auth_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SalusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2), // Azul médico
          primary: const Color(0xFF1976D2),
          secondary: const Color(0xFF03A9F4),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

