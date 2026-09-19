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

/// Shows foreground notifications from anywhere in the app.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Has to happen before runApp and exactly once. It used to run inside a
  // widget build, which re-registered the handler on every rebuild.
  NotificationService.registerBackgroundHandler();
  NotificationService.messengerKey = scaffoldMessengerKey;

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
          scaffoldMessengerKey: scaffoldMessengerKey,
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

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _notificationsFor;

  /// Sets notifications up once per signed-in account.
  ///
  /// This used to be called straight from build(), so it re-ran on every
  /// rebuild, adding another token-refresh and another foreground listener
  /// each time.
  void _syncNotifications(String? uid) {
    if (uid == _notificationsFor) return;
    _notificationsFor = uid;
    if (uid == null) return;
    // Deferred so it never runs during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.initialize(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        _syncNotifications(auth.currentUser?.uid);
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
          // Being unable to read the profile is not the same as being signed
          // out. Showing the login screen here invites someone to register a
          // second account for an email they already own.
          final error = auth.loadError;
          if (error != null) {
            return _ProfileLoadFailed(
              message: error,
              onRetry: auth.retryLoad,
              onSignOut: auth.logout,
            );
          }
          return const LoginScreen();
        }
        // Role-based routing
        if (auth.currentUser!.role == UserRole.landlord) {
          return const LandlordDashboard();
        } else {
          return const TenantDashboard();
        }
      },
    );
  }
}

class _ProfileLoadFailed extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  final Future<void> Function() onSignOut;

  const _ProfileLoadFailed({
    required this.message,
    required this.onRetry,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('আবার চেষ্টা করুন'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onSignOut,
                child: const Text('Login screen এ ফিরুন'),
              ),
            ],
          ),
        ),
      ),
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
