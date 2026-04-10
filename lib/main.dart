import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/landlord/landlord_dashboard.dart';
import 'screens/tenant/tenant_dashboard.dart';
import 'models/user_model.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HouseManagerApp());
}

class HouseManagerApp extends StatelessWidget {
  const HouseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(
            create: (_) => SettingsService()..loadSettings()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, _) => MaterialApp(
          title: 'House Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme.copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.themeColor,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: AppTheme.darkTheme.copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: settings.themeColor,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: settings.themeMode,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D9E75),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(Icons.home_rounded,
                        color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 24),
                  const Text('House Manager',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Loading...',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }
        if (auth.currentUser == null) {
          return const LoginScreen();
        }
        // Role-based routing
        if (auth.currentUser!.role == UserRole.landlord) {
          // Initialize notifications
          NotificationService().initialize(auth.currentUser!.uid);
          return const LandlordDashboard();
        } else {
          NotificationService().initialize(auth.currentUser!.uid);
          return const TenantDashboard();
        }
      },
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D9E75),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
        cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.grey.shade50,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1D9E75), width: 1.5),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D9E75),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      );
}
