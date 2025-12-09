import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/tagged_person.dart' as tagged;
import '../utils/theme.dart';
import '../widgets/network_code_card.dart';
import '../widgets/network_code_selector_sheet.dart';
import '../widgets/scan_result_bottom_sheet.dart';
import 'package:goal_networking_app/services/networking_service.dart';
import 'qr_scanner_view.dart';

class NetworkingModeView extends StatelessWidget {
  const NetworkingModeView({super.key});

  void _showCodeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLg),
        ),
      ),
      builder: (context) => const NetworkCodeSelectorSheet(),
    );
  }

  void _openScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerView(
          onScan: (code) => _handleScannedCode(context, code),
        ),
      ),
    );
  }

  Future<void> _handleScannedCode(BuildContext context, String code) async {
    // Close scanner first
    Navigator.pop(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final userId = appState.currentUser?.id ?? 'user_1';

      // 1. Check if it's a User QR Profile (starts with 'qr_')
      if (code.startsWith('qr_')) {
        final profile = await NetworkingService().findQRProfileById(code);
        
        // Close loading
        if (context.mounted) Navigator.pop(context);

        if (profile != null && context.mounted) {
          _showScanResultSheet(
            context: context,
            profileName: profile['title'] ?? 'User Profile',
            profileSummary: profile['description'] ?? 'No description',
            networkCodeLabel: profile['context'] ?? 'Networking',
            networkCodeId: profile['id'],
            isUserProfile: true,
            onConnect: (tags) async {
              await NetworkingService().scanQRCode(
                scannerId: userId,
                qrProfileId: code,
              );
              // Add tags logic here if needed
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Connected successfully!'), backgroundColor: Colors.green),
                );
              }
            },
            onFollow: (tags) async {
              try {
                await NetworkingService().followProfile(
                  userId: userId,
                  followingId: profile['userId'],
                  label: profile['title'] ?? 'User Profile',
                  type: 'profile',
                  tags: tags,
                );
                
                // Refresh app state
                if (context.mounted) {
                  final appState = Provider.of<AppState>(context, listen: false);
                  // Trigger reload of followings (we might need to expose a public method for this or just rely on notifyListeners if we update the list directly)
                  // Since we don't have a public reload method, we can just rely on the service being updated.
                  // Ideally AppState should listen to changes or we call a method on AppState.
                  // For now, let's just show success.
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Followed user!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          );
          return;
        }
      }

      // 2. Assume it's a Network Code
      final networkCode = await NetworkingService().findNetworkCodeByCode(code);
      
      if (networkCode != null && context.mounted) {
          // Fetch the creator's user information
          final creatorId = networkCode['userId'] ?? networkCode['createdBy'];
          final creator = creatorId != null 
              ? await NetworkingService().getUser(creatorId) 
              : null;
          
          // Close loading before showing sheet
          if (Navigator.canPop(context)) Navigator.pop(context);

          // Show creator's info if available, otherwise show network code info
          final displayName = creator?['name'] ?? networkCode['name'] ?? 'Unknown';
          final displaySummary = creator?['oneLiner'] ?? creator?['role'] ?? networkCode['description'] ?? 'No description';
          final networkCodeName = networkCode['name'] ?? networkCode['codeId'] ?? 'Network Code';
          
          _showScanResultSheet(
            context: context,
            profileName: displayName,
            profileSummary: displaySummary,
            networkCodeLabel: 'Network Code: $networkCodeName',
            networkCodeId: networkCode['id'],
            isUserProfile: false,
            onConnect: (tags) async {
              try {
                final result = await NetworkingService().joinNetworkCode(
                  userId: userId,
                  code: code,
                );
                
                if (context.mounted) {
                  // Close the bottom sheet
                  Navigator.pop(context);
                  
                  final isAutoConnect = result['autoConnect'] as bool? ?? false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isAutoConnect ? '✅ Connected to network!' : '📝 Request sent to owner'),
                      backgroundColor: isAutoConnect ? Colors.green : Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            onFollow: (tags) {
               // Network codes might not support "following" in the same way, but we can keep the button or hide it
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature not available for Network Codes')),
              );
            },
          );
          return;
      }

      // 3. Check if it's a direct User ID
      // Loading is still open here
      final user = await NetworkingService().getUser(code);
      
      // Close loading now, regardless of result (we will show sheet or error)
      if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);
      
      if (user != null && context.mounted) {
        // Close loading if not already closed
        // Note: We need to be careful about navigation stack.
        // If we are here, it means previous checks failed or returned null.
        // If they failed, they might have popped loading? No, they only pop if they succeed or return.
        // Wait, line 124 popped loading for Network Code check.
        // If Network Code check returned null, we are here and loading is POPPED.
        // So we don't need to pop again.
        
        _showScanResultSheet(
          context: context,
          profileName: user['name'] ?? 'User',
          profileSummary: user['headline'] ?? user['oneLiner'] ?? 'No headline',
          networkCodeLabel: 'Direct Connection',
          networkCodeId: user['id'],
          isUserProfile: true,
          onConnect: (tags) async {
             try {
                await NetworkingService().connectToUser(
                  userId: userId,
                  targetUserId: user['id'],
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Connected successfully!'), backgroundColor: Colors.green),
                  );
                }
             } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
                  );
                }
             }
          },
          onFollow: (tags) async {
             try {
                await NetworkingService().followProfile(
                  userId: userId,
                  followingId: user['id'],
                  label: user['name'] ?? 'User',
                  type: 'profile',
                  tags: tags,
                );
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Followed user!'), backgroundColor: Colors.green),
                  );
                }
             } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
                  );
                }
             }
          },
        );
        return;
      }

      // If nothing found
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Invalid QR Code, Network Code, or User not found'), backgroundColor: Colors.red),
        );
      }

    } catch (e) {
      print('Scan Error: $e');
      // Close loading if error
      if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Error'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showScanResultSheet({
    required BuildContext context,
    required String profileName,
    required String profileSummary,
    required String networkCodeLabel,
    required String networkCodeId,
    required bool isUserProfile,
    required Function(List<String>) onConnect,
    required Function(List<String>) onFollow,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLg),
        ),
      ),
      builder: (context) => ScanResultBottomSheet(
        profileName: profileName,
        profileSummary: profileSummary,
        networkCodeLabel: networkCodeLabel,
        networkCodeId: networkCodeId,
        onConnect: onConnect,
        onFollow: onFollow,
      ),
    );
  }

  void _shareNetworkCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share Network Code feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final selectedCode = appState.selectedNetworkCode;

        if (selectedCode == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_2_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Text(
                  'No Network Codes available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                ElevatedButton.icon(
                  onPressed: () => _showCodeSelector(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Network Code'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Main Network Code card area
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: NetworkCodeCard(
                    code: selectedCode,
                    onTapDropdown: () => _showCodeSelector(context),
                  ),
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Open scanner button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openScanner(context),
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text('Open scanner'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacingMd,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMd),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMd),

                    // Share Network Code button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareNetworkCode(context),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share Network Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacingMd,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMd),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
