import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/profile_repository.dart';
import 'services/auth_service.dart';
import 'screens/main_screen.dart';
import 'screens/email_input_screen.dart'; // New simple login
// import 'screens/auth_entry_screen.dart'; // Old OTP-based auth (deactivated)
import 'utils/theme.dart';
import 'config/api_config.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/notification_service.dart';
import 'models/user.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().init();

  runApp(const GoalNetApp());
}

class GoalNetApp extends StatelessWidget {
  const GoalNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => ProfileRepository()),
        Provider(create: (context) => AuthService()),
      ],
      child: MaterialApp(
        title: 'GoalNet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthCheckScreen(),
      ),
    );
  }
}

/// Initial screen that checks authentication status
/// Routes to AuthEntryScreen or MainScreen based on auth state
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    // Restore session from secure storage
    final sessionRestored = await authService.restoreSession();

    if (!mounted) return;

    if (authService.isAuthenticated) {
      // Sync user to AppState
      if (authService.currentUser != null) {
        final user = User.fromMap(authService.currentUser!);
        Provider.of<AppState>(context, listen: false).setUser(user);
      }

      // User is authenticated, go to main app
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // User is not authenticated, show email/OTP login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const EmailInputScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading screen while checking auth
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
