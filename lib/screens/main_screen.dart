import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'package:provider/provider.dart';
import 'dashboard_screen.dart';
import 'assistant_screen.dart';
import 'event_list_screen.dart';
import 'edit_profile_screen.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/app_state.dart';
import 'email_input_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Default to Assistant tab

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const AssistantScreen(),
      const EventListScreen(),
    ];

    // Check networking mode and switch to Tasks tab if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.isNetworkingMode) {
        setState(() {
          _currentIndex =
              0; // Switch to Tasks tab (which shows networking mode)
        });
      }
    });

    // Listen for session expiry (global logout trigger)
    ApiClient.sessionExpiredController.stream.listen((_) {
       print('⚠️ Session expired received in MainScreen. Logging out...');
       _handleSessionExpiry();
    });
  }

  void _handleSessionExpiry() async {
    if (!mounted) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut(); // Clear tokens
    
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const EmailInputScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Auto-switch to Tasks tab when networking mode is enabled
        if (appState.isNetworkingMode && _currentIndex != 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentIndex = 0;
            });
          });
        }

        // Check profile completeness
        final user = appState.currentUser;
        final isProfileComplete = _isProfileComplete(user);

        return Scaffold(
          body: Column(
             children: [
                if (user != null && !isProfileComplete)
                   _buildCompletionBanner(context, user),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
             ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.white,
              elevation: 0,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.task_outlined),
                  activeIcon: Icon(Icons.task),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_outlined),
                  activeIcon: Icon(Icons.auto_awesome),
                  label: 'Assistant',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_outlined),
                  activeIcon: Icon(Icons.event),
                  label: 'Circles',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isProfileComplete(dynamic user) {
     if (user == null) return false;
     
     // Debug profile status
     bool nameOk = user.name != null && user.name!.isNotEmpty;
     bool roleOk = user.role != null && user.role!.isNotEmpty;
     bool companyOk = user.company != null && user.company!.isNotEmpty;
     bool locationOk = user.location != null && user.location!.isNotEmpty;
     bool bioOk = (user.oneLiner != null && user.oneLiner!.isNotEmpty) || 
                  (user.bio != null && user.bio!.isNotEmpty);
                  
     // print('🔍 Profile Check: Name=$nameOk, Role=$roleOk, Co=$companyOk, Loc=$locationOk, Bio=$bioOk');
     
     if (!nameOk) return false;
     if (!roleOk) return false;
     if (!companyOk) return false;
     if (!locationOk) return false;
     if (!bioOk) return false;
         
     return true;
  }

  Widget _buildCompletionBanner(BuildContext context, dynamic user) {
    return SafeArea(
      bottom: false, // Only top is needed usually for top banner
      child: MaterialBanner(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: const Text(
          'Complete your profile to get personalized event recommendations!',
          style: TextStyle(fontSize: 13),
        ),
        leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 24),
        backgroundColor: Colors.amber.shade50,
        actions: [
          TextButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
              // The AppState should already be updated by EditProfileScreen,
              // triggering a rebuild of this widget via Consumer.
            },
            child: const Text('COMPLETE NOW', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
