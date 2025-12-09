import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../utils/theme.dart';
import '../modules/networking/screens/create_network_code_screen.dart';
import '../modules/networking/screens/edit_network_code_screen.dart';
import '../services/networking_service.dart';

class NetworkCodeSelectorSheet extends StatelessWidget {
  const NetworkCodeSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final codes = appState.networkCodes;
        final selectedCode = appState.selectedNetworkCode;

        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusLg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Network Code',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () async {
                      // Close sheet first? No, keep it open or close and reopen?
                      // Usually we want to return to this sheet or just refresh.
                      // Let's close sheet and navigate, then maybe user reopens.
                      // Or just navigate on top.
                      
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateNetworkCodeScreen(),
                        ),
                      );
                      
                      if (result == true) {
                        // Reload codes
                        appState.loadNetworkCodes();
                      }
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(AppConstants.spacingSm),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Network Code list
              if (codes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXl),
                  child: Center(
                    child: Text(
                      'No network codes found.\nCreate one to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                ...codes.map<Widget>((code) {
                  final isSelected = selectedCode?.id == code.id;
                  return InkWell(
                    onTap: () {
                      appState.selectNetworkCode(code);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      margin: const EdgeInsets.only(
                        bottom: AppConstants.spacingMd,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.05)
                            : Colors.grey[50],
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  code.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : AppTheme.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: AppConstants.spacingXs),
                                Text(
                                  code.description ?? '',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Edit button
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                            onPressed: () async {
                              // Find the full network code map from service to pass to edit screen
                              // Or we can just pass the NetworkCode object and map it back?
                              // EditNetworkCodeScreen expects Map<String, dynamic>.
                              // We should probably update EditNetworkCodeScreen to accept NetworkCode object or fetch it.
                             // For now, let's fetch it or construct it.
                              
                              try {
                                final fullCode = await NetworkingService().findNetworkCodeByCode(code.codeId);
                                if (fullCode != null && context.mounted) {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditNetworkCodeScreen(networkCode: fullCode),
                                    ),
                                  );
                                  
                                  if (result == true) {
                                    appState.loadNetworkCodes();
                                  }
                                }
                              } catch (e) {
                                print('Error fetching code for edit: $e');
                              }
                            },
                          ),
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () async {
                              // Show confirmation dialog
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Network Code'),
                                  content: Text(
                                    'Are you sure you want to delete "${code.name}"?\n\nThis will also delete all connections made through this network code.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirmed == true && context.mounted) {
                                try {
                                  // Show loading
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                  
                                  // Delete the network code
                                  await NetworkingService().deleteNetworkCode(code.codeId);
                                  
                                  // Close loading
                                  if (context.mounted) Navigator.pop(context);
                                  
                                  // Reload codes
                                  await appState.loadNetworkCodes();
                                  
                                  // Close selector sheet
                                  if (context.mounted) Navigator.pop(context);
                                  
                                  // Show success message
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Network code "${code.name}" deleted successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // Close loading if still open
                                  if (context.mounted && Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                  
                                  // Show error
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to delete: ${e.toString().replaceAll('Exception: ', '')}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                          Radio<String>(
                            value: code.id,
                            groupValue: selectedCode?.id,
                            onChanged: (value) {
                              appState.selectNetworkCode(code);
                              Navigator.pop(context);
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: AppConstants.spacingMd),
            ],
          ),
        );
      },
    );
  }
}
