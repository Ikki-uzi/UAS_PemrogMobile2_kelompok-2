import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:money_manager/config/theme.dart';
import 'package:money_manager/firebase_options.dart';
import 'package:money_manager/screens/login_screen.dart';
import 'package:money_manager/screens/register_screen.dart';
import 'package:money_manager/screens/splash_screen.dart';
import 'package:money_manager/screens/main_screen.dart';
import 'package:money_manager/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Inisialisasi Format Tanggal (Sangat penting untuk fitur kalender & laporan nanti)
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        // Kamu bisa tambah provider lain di sini nanti jika diperlukan
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
      debugShowCheckedModeBanner: false,
      title: 'Money Manager',
      // Menggunakan theme yang sudah kamu definisikan di folder config
      theme: AppTheme.lightTheme,
      // Jika nanti ingin support Dark Mode:
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: AppTheme.primaryColor,
        // Tambahkan kustomisasi dark mode lainnya di sini
      ),
      themeMode: ThemeMode.system, // Otomatis ikut settingan HP
      // Set splash screen sebagai home
      home: const SplashScreen(),

      // Define routes untuk navigation
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendengarkan status login user
    final authService = context.watch<AuthService>();

    if (authService.user != null) {
      // Jika sudah login, arahkan ke MainScreen (bukan HomeScreen langsung)
      // supaya Bottom Navigation Bar-nya muncul
      return const MainScreen();
    } else {
      // Jika belum login, arahkan ke Login
      return const LoginScreen();
    }
  }
}
