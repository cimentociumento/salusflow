import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salusflow/screens/auth/doctor_login_screen.dart';
import 'package:salusflow/screens/home/doctor_home_screen.dart';
import 'package:salusflow/screens/profile/profile_screen.dart';
import 'package:salusflow/screens/certificate/certificate_screen.dart';
import 'package:salusflow/services/auth_service.dart';
import 'package:salusflow/services/certificate_service.dart';
import 'package:salusflow/screens/documents/pdf_viewer_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CertificateService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SalusFlow Med',
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
      home: const DoctorLoginScreen(),
      routes: {
        '/login': (context) => const DoctorLoginScreen(),
        '/home': (context) => const DoctorHomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/certificate': (context) => const CertificateScreen(),
        '/documents': (context) => const PdfViewerScreen(),
      },
    );
  }
}
