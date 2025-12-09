import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/app_state.dart';
import '../models/tagged_person.dart' as tagged;
import '../utils/theme.dart';
import '../widgets/qr_card.dart';
import '../widgets/network_code_selector_sheet.dart';
import '../widgets/scan_result_bottom_sheet.dart';
import '../screens/create_network_code_screen.dart';
import '../screens/my_space_screen.dart';
import '../screens/edit_network_code_screen.dart';

class NetworkingModeView extends StatelessWidget {
  const NetworkingModeView({super.key});

  void _showProfileSelector(BuildContext context) {
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

  void _openScanner(BuildContext context, {String? manualCode}) {
    final appState = Provider.of<AppState>(context, listen: false);

    // Mock scan result - in production this would come from QR scanner
    final mockScannedProfiles = [
      {
        'name': 'Sarah Chen',
        'summary':
            'Product Manager at Google with 8 years experience in AI/ML products. Looking to connect with founders in the AI space.',
        'networkCodeId': '1', // Events
      },
      {
        'name': 'Michael Rodriguez',
        'summary':
            'Serial entrepreneur and angel investor. Founded 3 startups, 2 exits. Active in SaaS and B2B tech.',
        'networkCodeId': '2', // Friends
      },
      {
        'name': 'Emily Watson',
        'summary':
            'Senior Engineer at Meta specializing in distributed systems. Passionate about open source and developer tools.',
        'networkCodeId': '1', // Events
      },
    ];

    // Pick a random profile for demo or use manualCode to simulate specific lookup
    // If manualCode is provided, we simulate finding a profile associated with it
    final profile = (mockScannedProfiles..shuffle()).first;
    
    // CHECK EXPIRY LOGIC (Mock)
    // If we had the real network code object for the *target* connection, we would check:
    // if (targetNetworkCode.expiresAt != null && DateTime.now().isAfter(targetNetworkCode.expiresAt!)) {
    //   showError('This code has expired'); return;
    // }
    // Since we are mocking the "scanned" code, let's assume it's valid unless manualCode is specific.
    
    final networkCodes = appState.networkCodes;
    final networkCode = networkCodes.firstWhere(
      (nc) => nc.id == profile['networkCodeId'],
      orElse: () => networkCodes.isNotEmpty ? networkCodes.first : appState.selectedNetworkCode!,
    );
    
    // CHECK EXPIRY AND ACTIVE STATUS
    // In production, this would check the *scanned* user's code, not our own
    // For now, we'll validate our own code to demonstrate the logic
    print('🔴 CHECKING CODE VALIDITY:');
    print('  - Code ID: ${networkCode.codeId}');
    print('  - Is Expired: ${networkCode.isExpired}');
    print('  - Is Active: ${networkCode.isActive}');
    print('  - Expires At: ${networkCode.expiresAt}');
    
    if (networkCode.isExpired) {
      print('❌ CODE EXPIRED - Connection blocked');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This network code has expired'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!networkCode.isActive) {
      print('❌ CODE INACTIVE - Connection blocked');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This network code is inactive'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    print('✅ CODE VALID - Proceeding with connection');
    
    if (manualCode != null) {
       // Simulate that we scanned/entered 'manualCode'
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Code verified! Finding profile...')),
       );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLg),
        ),
      ),
      builder: (context) => ScanResultBottomSheet(
        profileName: profile['name'] as String,
        profileSummary: profile['summary'] as String,
        networkCodeLabel: networkCode.name,
        networkCodeId: networkCode.id,
        onConnect: (tags) {
          final connection = tagged.Connection(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            label: profile['name'] as String,
            networkCodeId: networkCode.id,
            userTags: tags,
          );
          appState.addTaggedConnection(connection);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tags.isEmpty
                    ? 'Connection added'
                    : 'Connection added with ${tags.length} tag${tags.length > 1 ? 's' : ''}',
              ),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
        onFollow: (tags) {
          final following = tagged.FollowingPerson(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            label: profile['name'] as String,
            networkCodeId: networkCode.id,
            userTags: tags,
          );
          appState.addTaggedFollowing(following);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tags.isEmpty
                    ? 'Added to your followings'
                    : 'Added to your followings with ${tags.length} tag${tags.length > 1 ? 's' : ''}',
              ),
              backgroundColor: AppTheme.successColor,
            ),
          );
        },
      ),
    );
  }

  void _shareQrCode(BuildContext context, dynamic networkCode) async {
    print('🔵 SHARE BUTTON CLICKED - Code: ${networkCode.codeId}');
    final String shareText = 
      'Connect with me on GoalNet!\n'
      'Network Code: ${networkCode.codeId}\n'
      'Name: ${networkCode.name}\n'
      'Valid until: ${networkCode.expiresAt?.toString() ?? "Indefinitely"}';
      
    print('🔵 SHARING: $shareText');
    await Share.share(shareText);
    print('🔵 SHARE COMPLETE');
  }

  void _showManualEntryDialog(BuildContext context) {
    print('🟢 MANUAL ENTRY DIALOG OPENED');
    final TextEditingController _controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Network Code'),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Code',
            hintText: 'Enter code manually',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = _controller.text.trim();
              print('🟢 USER ENTERED CODE: $code');
              if (code.isEmpty) return;
              
              Navigator.pop(context);
              // Logic to handle entered code
              await _handleScannedCode(context, code);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleScannedCode(BuildContext context, String code) async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Simulate finding the code (in real app, query backend)
    // For now, let's assume we find a code or it's invalid
    // We already have logic to 'find' code in the appState or Service?
    // Let's use NetworkingService to find it.
    
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifying code...')),
      );

      // This part would ideally call a service method to find the code.
      // Since we don't have a direct 'connect via code string' in AppState exposed simply,
      // we'll mock the success for the user's "Manual Entry" feature as per plan "Mock scan result".
      // But we should try to be somewhat realistic.
      
      // Checking for expiry would happen here if we fetched the real object.
      // Let's just mock a success for now or call the scan handler if available.
      _openScanner(context, manualCode: code);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final selectedNetworkCode = appState.selectedNetworkCode;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Networking Mode'),
            actions: [
              if (selectedNetworkCode != null)
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share Code',
                  onPressed: () => _shareQrCode(context, selectedNetworkCode),
                ),
              IconButton(
                icon: const Icon(Icons.people_outline),
                tooltip: 'My Space',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MySpaceScreen()),
                  );
                },
              ),
            ],
          ),
          body: selectedNetworkCode == null
              ? Center(
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
                        onPressed: () {
                           Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CreateNetworkCodeScreen(),
                              ),
                            );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Create Network Code'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Main QR card area
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppConstants.spacingLg),
                          child: QrCard(
                            profile: selectedNetworkCode,
                            onTapDropdown: () => _showProfileSelector(context),
                          ),
                        ),
                      ),
                    ),

                    // Bottom action buttons
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingLg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            // Open scanner button
                            Expanded(
                              child: Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _openScanner(context),
                                    icon: const Icon(Icons.qr_code_scanner),
                                    label: const Text('Scan QR'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppConstants.spacingMd,
                                        horizontal: AppConstants.spacingMd,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppConstants.radiusMd),
                                        side: const BorderSide(
                                          color: AppTheme.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _showManualEntryDialog(context),
                                    child: const Text('Enter Code Manually', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),

                            // Edit button
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Convert NetworkCode object to Map for EditNetworkCodeScreen
                                  final networkCodeMap = {
                                    'id': selectedNetworkCode.id,
                                    'code': selectedNetworkCode.codeId,
                                    'name': selectedNetworkCode.name,
                                    'description': selectedNetworkCode.description ?? '',
                                    'autoConnect': selectedNetworkCode.autoConnect,
                                    'keywords': selectedNetworkCode.keywords,
                                    'isActive': selectedNetworkCode.isActive,
                                    'maxConnections': selectedNetworkCode.maxConnections,
                                    'currentConnections': selectedNetworkCode.currentConnections,
                                    'createdAt': selectedNetworkCode.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
                                  };
                                  
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditNetworkCodeScreen(
                                        networkCode: networkCodeMap,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
