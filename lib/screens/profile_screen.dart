import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import 'edit_profile_screen.dart';
import 'email_input_screen.dart';

/// Profile screen showing current user information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  @override
  void initState() {
    super.initState();
    // Refresh user data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await Provider.of<AppState>(context, listen: false).refreshUser();
    } catch (e) {
      print('Error refreshing profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
            onPressed: () async {
              // Wait for result from Edit Screen
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
              
              // If saved, refresh data
              if (result == true && mounted) {
                _loadData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final user = appState.currentUser;

          if (user == null) {
            return const Center(
              child: Text('No user logged in'),
            );
          }
          
          print('📱 Profile Screen Building - Phone: ${user.phoneNumber}');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null || user.photoUrl!.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.primaryColor,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXl),

                // Name
                _buildInfoCard(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: user.name,
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Email
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Role
                _buildInfoCard(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: user.role,
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Phone Number
                _buildInfoCard(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: user.phoneNumber ?? '',
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Company
                _buildInfoCard(
                  icon: Icons.business_outlined,
                  label: 'Company',
                  value: user.company ?? '',
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Location
                _buildInfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: user.location ?? '',
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // One Liner / Bio
                _buildInfoCard(
                  icon: Icons.info_outlined,
                  label: 'About',
                  value: user.oneLiner ?? user.bio ?? '',
                  maxLines: 3,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: TextStyle(
                    fontSize: 16,
                    color: value.isEmpty ? Colors.grey : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog
                
                // Perform logout
                final authService = AuthService();
                await authService.signOut();
                
                // Clear app state
                if (context.mounted) {
                  final appState = Provider.of<AppState>(context, listen: false);
                  appState.clearUser();
                  
                  // Navigate to login screen and remove all previous routes
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const EmailInputScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
