import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/tagged_person.dart' as tagged;
import '../utils/theme.dart';
import '../widgets/qr_card.dart';
import '../widgets/qr_profile_selector_sheet.dart';
import '../widgets/scan_result_bottom_sheet.dart';

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
      builder: (context) => const QrProfileSelectorSheet(),
    );
  }

  void _openScanner(BuildContext context) {
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

    // Pick a random profile for demo
    final profile = (mockScannedProfiles..shuffle()).first;
    final networkCodes = appState.networkCodes;
    final networkCode = networkCodes.firstWhere(
      (nc) => nc.id == profile['networkCodeId'],
      orElse: () => networkCodes.first,
    );

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

  void _shareQrCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share QR code feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // QR profile feature is separate - using Network Codes for now
        final selectedProfile = null; // appState.selectedQrProfile;

        if (selectedProfile == null) {
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
                  'No QR profiles available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                ElevatedButton.icon(
                  onPressed: () => _showProfileSelector(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create QR Profile'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Main QR card area
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: QrCard(
                    profile: selectedProfile,
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
                      child: ElevatedButton.icon(
                        onPressed: () => _openScanner(context),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Open scanner'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacingMd,
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
                    ),
                    const SizedBox(width: AppConstants.spacingMd),

                    // Share QR code button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareQrCode(context),
                        icon: const Icon(Icons.share),
                        label: const Text('Share QR code'),
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
        );
      },
    );
  }
}
