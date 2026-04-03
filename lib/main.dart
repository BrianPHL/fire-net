import 'package:fire_net/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'core/screens/splash_screen.dart';
import 'routes/app_routes.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/user/screens/home_screen.dart';
import 'features/user/screens/alerts_screen.dart';
import 'features/user/screens/alert_history_screen.dart';
import 'features/user/screens/alert_detail_screen.dart';
import 'features/user/screens/sensors_screen.dart';
import 'features/user/screens/sensor_detail_screen.dart';
import 'features/engineer/screens/dashboard_screen.dart';
import 'features/engineer/screens/sensor_management_screen.dart';
import 'features/engineer/screens/system_config_screen.dart';
import 'features/engineer/screens/system_diagnostics_screen.dart';
import 'models/alert.dart';
import 'models/sensor_node.dart';
import 'services/onboarding_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? startupError;

  try {
    await dotenv.load(fileName: '.env');

    final missingKeys = _requiredFirebaseEnvKeys
        .where((key) => (dotenv.env[key] ?? '').trim().isEmpty)
        .toList();

    if (missingKeys.isNotEmpty) {
      throw StateError(
        'Missing Firebase env keys: ${missingKeys.join(', ')}',
      );
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (error) {
      if (error.code != 'duplicate-app') {
        rethrow;
      }
    }

    // Initialize theme provider
    await ThemeProvider().init();
  } catch (error, stackTrace) {
    debugPrint('Startup initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    startupError = error.toString();
  }

  runApp(FireNetApp(startupError: startupError));
}

const List<String> _requiredFirebaseEnvKeys = [
  'FIREBASE_PROJECT_ID',
  'FIREBASE_MESSAGING_SENDER_ID',
  'FIREBASE_STORAGE_BUCKET',
  'FIREBASE_DATABASE_URL',
  'FIREBASE_ANDROID_API_KEY',
  'FIREBASE_ANDROID_APP_ID',
];

class FireNetApp extends StatelessWidget {
  const FireNetApp({super.key, this.startupError});

  final String? startupError;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) {
        // Return the singleton instance which was already initialized in main()
        return ThemeProvider();
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // Set system UI overlay style based on theme
          final isDark = themeProvider.isDarkMode;
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: startupError == null
                ? const SplashScreenWrapper()
                : StartupErrorScreen(errorMessage: startupError!),
            initialRoute: startupError == null ? null : null,
            onGenerateRoute: startupError == null ? _onGenerateRoute : null,
          );
        },
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Onboarding route
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      // Auth routes
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      // User routes
      case AppRoutes.userHome:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.alerts:
        return MaterialPageRoute(builder: (_) => const AlertsScreen());

      case AppRoutes.alertHistory:
        return MaterialPageRoute(builder: (_) => const AlertHistoryScreen());

      case AppRoutes.sensors:
        return MaterialPageRoute(builder: (_) => const SensorsScreen());

      case AppRoutes.alertDetail:
        final alert = settings.arguments as Alert?;
        if (alert != null) {
          return MaterialPageRoute(
            builder: (_) => AlertDetailScreen(alert: alert),
          );
        }
        return _errorRoute('Alert not found');

      case AppRoutes.sensorDetail:
        final sensor = settings.arguments as SensorNode?;
        if (sensor != null) {
          return MaterialPageRoute(
            builder: (_) => SensorDetailScreen(sensor: sensor),
          );
        }
        // Fallback to mock data if no sensor passed
        return MaterialPageRoute(
          builder: (_) =>
              SensorDetailScreen(sensor: SensorNode.getMockNodes().first),
        );

      // Engineer routes
      case AppRoutes.engineerDashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case AppRoutes.sensorManagement:
        return MaterialPageRoute(
          builder: (_) => const SensorManagementScreen(),
        );

      case AppRoutes.systemConfig:
        return MaterialPageRoute(builder: (_) => const SystemConfigScreen());

      case AppRoutes.systemDiagnostics:
        return MaterialPageRoute(
          builder: (_) => const SystemDiagnosticsScreen(),
        );

      default:
        return _errorRoute('Page not found');
    }
  }

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.danger,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  final _authService = AuthService();
  late final Future<bool> _onboardingFuture;
  String? _lastResolvedUid;
  Future<String>? _routeForUserFuture;

  @override
  void initState() {
    super.initState();
    _onboardingFuture = OnboardingService.isOnboardingComplete();
  }

  Future<String> _resolveRouteForAuthenticatedUser(User user) async {
    final hasValidSession = await _authService.hasValidSession(user: user);
    if (!hasValidSession) {
      return AppRoutes.login;
    }

    try {
      final role = await _authService.getRoleForUser(uid: user.uid);
      return _authService.routeForRole(role);
    } on FirebaseAuthException {
      await _authService.signOut();
      return AppRoutes.login;
    } catch (error) {
      debugPrint('Startup role resolution failed: $error');
      await _authService.signOut();
      return AppRoutes.login;
    }
  }

  Widget _screenForRoute(String routeName) {
    switch (routeName) {
      case AppRoutes.userHome:
        return const HomeScreen();
      case AppRoutes.engineerDashboard:
        return const DashboardScreen();
      case AppRoutes.onboarding:
        return const OnboardingScreen();
      case AppRoutes.login:
      default:
        return const LoginScreen();
    }
  }

  Future<String> _getRouteFutureForUser(User user) {
    if (_lastResolvedUid != user.uid || _routeForUserFuture == null) {
      _lastResolvedUid = user.uid;
      _routeForUserFuture = _resolveRouteForAuthenticatedUser(user);
    }
    return _routeForUserFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _onboardingFuture,
      builder: (context, onboardingSnapshot) {
        if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final onboardingComplete = onboardingSnapshot.data ?? false;
        if (!onboardingComplete) {
          return const OnboardingScreen();
        }

        return StreamBuilder<User?>(
          stream: _authService.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            final user = authSnapshot.data;
            if (user == null) {
              _lastResolvedUid = null;
              _routeForUserFuture = null;
              return const LoginScreen();
            }

            return FutureBuilder<String>(
              future: _getRouteFutureForUser(user),
              builder: (context, routeSnapshot) {
                if (routeSnapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }

                final routeName = routeSnapshot.data ?? AppRoutes.login;
                return _screenForRoute(routeName);
              },
            );
          },
        );
      },
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Startup Error')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: AppColors.danger,
            ),
            const SizedBox(height: 16),
            const Text(
              'App failed to initialize.',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
