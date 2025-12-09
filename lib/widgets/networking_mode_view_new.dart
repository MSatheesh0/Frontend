import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';
import '../models/tagged_person.dart' as tagged;
import '../utils/theme.dart';
import '../widgets/network_code_card.dart';
import '../widgets/network_code_selector_sheet.dart';
import '../widgets/scan_result_bottom_sheet.dart';
import 'package:goal_networking_app/services/networking_service.dart';
import 'qr_scanner_view.dart';
import '../screens/qr_scan_result_screen.dart';

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
    // CRITICAL: Capture navigator FIRST, before any operations that might deactivate context
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Close scanner first
    Navigator.pop(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Set up a timeout to close loading and show error if operation takes too long
    bool operationCompleted = false;
    Future.delayed(const Duration(seconds: 4), () {
      if (!operationCompleted && context.mounted) {
        print('⏰ QR SCANNER: Operation timeout after 4 seconds');
        // Close loading dialog if still open
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('⚠️ Operation took too long. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(milliseconds: 2000),
          ),
        );
      }
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final userId = appState.currentUser?.id ?? 'user_1';

      // 1. Check if it's a User QR Profile (starts with 'qr_')
      if (code.startsWith('qr_')) {
        final profile = await NetworkingService().findQRProfileById(code);
        
        operationCompleted = true;
        // Close loading
        if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);

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
      }

      // 2. Check if it's a Network Code
      print('🔍 QR SCANNER: Checking if code is a Network Code...');
      final networkCode = await NetworkingService().findNetworkCodeByCode(code);
      
      if (networkCode != null) {
         operationCompleted = true;
         print('✅ QR SCANNER: Network Code found!');
         print('📋 QR SCANNER: Network Code name: ${networkCode['name']}');
         print('🔑 QR SCANNER: Network Code ID: ${networkCode['codeId']}');
         print('🔓 QR SCANNER: Auto-connect: ${networkCode['autoConnect']}');
         print('✅ QR SCANNER: Is active: ${networkCode['isActive']}');
         
         // Pop loading dialog
         if (context.mounted && Navigator.canPop(context)) {
           print('🔄 QR SCANNER: Popping loading dialog');
           Navigator.pop(context);
         }
         
         if (networkCode['isActive'] == false) {
           print('⚠️ QR SCANNER: Network code is INACTIVE');
           if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                 content: Text('⚠️ This Network Code is currently inactive'),
                 backgroundColor: Colors.orange,
               ),
             );
           }
           return;
         }

         // PRE-VALIDATION: Check if user owns this code
         print('🔍 PRE-VALIDATION: Checking if user owns this code...');
         print('   - Current userId: $userId');
         print('   - Network code userId field: ${networkCode['userId']}');
         print('   - Network code createdBy field: ${networkCode['createdBy']}');
         
         // Check multiple possible fields for creator ID
         final codeCreatorId = networkCode['userId'] ?? networkCode['createdBy'];
         print('   - Resolved creator ID: $codeCreatorId');
         print('   - Type check: ${codeCreatorId.runtimeType} vs ${userId.runtimeType}');
         
         // Compare as strings to handle any type mismatches
         if (codeCreatorId != null && codeCreatorId.toString() == userId.toString()) {
           print('⚠️ QR SCANNER: User owns this network code - BLOCKING NAVIGATION');
           if (context.mounted) {
             scaffoldMessenger.showSnackBar(
               const SnackBar(
                 content: Text('💡 This is your network code! Share it with others to connect'),
                 backgroundColor: Colors.orange,
                 duration: Duration(milliseconds: 2500),
               ),
             );
           }
           return;
         }
         print('✅ PRE-VALIDATION: User does NOT own this code, continuing...');

         // PRE-VALIDATION: Check if already connected
         try {
           final connections = await NetworkingService().getUserConnections(userId);
           final existingConn = connections.firstWhere(
             (c) => c['codeId'] == code,
             orElse: () => {},
           );
           
           if (existingConn.isNotEmpty) {
             final status = existingConn['status'] ?? 'none';
             print('🔍 QR SCANNER: Found existing connection with status: $status');
             
             if (status == 'accepted') {
               print('✅ QR SCANNER: Already connected!');
               if (context.mounted) {
                 scaffoldMessenger.showSnackBar(
                   const SnackBar(
                     content: Text('✅ You\'re already connected! View their profile in My Spaces'),
                     backgroundColor: Colors.green,
                     duration: Duration(milliseconds: 2500),
                   ),
                 );
               }
               return;
             } else if (status == 'pending') {
               print('⏳ QR SCANNER: Request already pending');
               if (context.mounted) {
                 scaffoldMessenger.showSnackBar(
                   const SnackBar(
                     content: Text('⏳ Connection request pending approval by creator'),
                     backgroundColor: Colors.orange,
                     duration: Duration(milliseconds: 2500),
                   ),
                 );
               }
               return;
             }
           }
         } catch (e) {
           print('❌ QR SCANNER: Error checking connection status: $e');
           // Continue anyway - don't block on this error
         }

         // All validations passed - navigate to result screen
         // Navigate to QR scan result screen using captured navigator
         print('🚀 QR SCANNER: Navigating to QR Scan Result Screen with codeId: $code');
         print('👤 QR SCANNER: Passing userId: $userId');
         print('⚡ QR SCANNER: Using captured navigator for navigation');
         try {
           await navigator.push(
             MaterialPageRoute(
               builder: (context) {
                 print('🏗️ QR SCANNER: MaterialPageRoute builder called');
                 return QrScanResultScreen(
                   codeId: code,
                   userId: userId,
                 );
               },
             ),
           );
           print('✅ QR SCANNER: Navigator.push completed');
         } catch (e, stackTrace) {
           print('❌ QR SCANNER: Navigation error: $e');
           print('📚 QR SCANNER: Stack trace: $stackTrace');
           if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Navigation error: $e'),
                 backgroundColor: Colors.red,
               ),
             );
           }
         }
         return;
       } else {
         print('❌ QR SCANNER: No Network Code found for code: $code');
       }

      // 3. Check if it's a direct User ID
      print('🔍 QR SCANNER: Checking if code is a direct User ID...');
      final user = await NetworkingService().getUser(code);
      
      if (user != null) {
        print('✅ QR SCANNER: User found by ID!');
        print('📋 QR SCANNER: User name: ${user['name']}');
        print('🔑 QR SCANNER: User ID: ${user['id']}');
        if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);

        if (context.mounted) {
          _showScanResultSheet(
            context: context,
            profileName: user['name'] ?? 'User',
            profileSummary: user['headline'] ?? 'No headline',
            networkCodeLabel: 'Direct Connection',
            networkCodeId: user['id'],
            isUserProfile: true,
            onConnect: (tags) async {
               try {
                  await NetworkingService().connectToUser(
                    userId: userId,
                    targetUserId: code,
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
                  print('❌ QR SCANNER: Error following user: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
                    );
                  }
               }
            },
          );
        }
        return;
      } else {
        print('❌ QR SCANNER: No User found for ID: $code');
      }

      // If nothing found - close loading and show error
      operationCompleted = true;
      print('⚠️ QR SCANNER: No match found for scanned code: $code');
      
      // Close loading dialog
      if (context.mounted && Navigator.canPop(context)) {
        print('🔄 QR SCANNER: Closing loading dialog (nothing found)');
        Navigator.pop(context);
      }
      
      // Show error message
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('🔍 Network code not found. Please check the code and try again'),
            backgroundColor: Colors.red,
            duration: Duration(milliseconds: 2500),
          ),
        );
      }

    } catch (e) {
      operationCompleted = true;
      print('🔥 QR SCANNER: An unexpected error occurred: $e');
      // Close loading if error
      if (context.mounted && Navigator.canPop(context)) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
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

  void _shareNetworkCode(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final selectedCode = appState.selectedNetworkCode;
    
    if (selectedCode == null) return;
    
    print('🔵 SHARE BUTTON CLICKED - Code: ${selectedCode.codeId}');
    final String shareText = 
      'Connect with me on GoalNet!\n'
      'Network Code: ${selectedCode.codeId}\n'
      'Name: ${selectedCode.name}\n'
      'Valid until: ${selectedCode.expiresAt?.toString() ?? "Indefinitely"}';
      
    print('🔵 SHARING: $shareText');
    await Share.share(shareText);
    print('🔵 SHARE COMPLETE');
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
            
            // Manual entry text field below
            _ManualEntryField(
              onSubmit: (code) async {
                print('🟢 USER ENTERED CODE: $code');
                await _handleScannedCode(context, code.trim());
              },
            ),
          ],
        );
      },
    );
  }
}

class _ManualEntryField extends StatefulWidget {
  final Function(String) onSubmit;
  
  const _ManualEntryField({required this.onSubmit});

  @override
  State<_ManualEntryField> createState() => _ManualEntryFieldState();
}

class _ManualEntryFieldState extends State<_ManualEntryField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Or enter code manually',
            prefixIcon: const Icon(Icons.edit, size: 20),
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () async {
                if (_controller.text.trim().isEmpty) return;
                await widget.onSubmit(_controller.text);
                if (mounted) {
                  _controller.clear();
                }
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
          ),
          textInputAction: TextInputAction.go,
          onSubmitted: (code) async {
            if (code.trim().isEmpty) return;
            final textToClear = code;
            await widget.onSubmit(code);
            // Only clear if widget is still mounted
            if (mounted) {
              _controller.clear();
            }
          },
        ),
      ),
    );
  }
}
