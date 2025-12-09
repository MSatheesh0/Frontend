import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_section_card.dart';
import '../utils/theme.dart';

class ProfileScreenBackup extends StatefulWidget {
  const ProfileScreenBackup({super.key});

  @override
  State<ProfileScreenBackup> createState() => _ProfileScreenBackupState();
}

class _ProfileScreenBackupState extends State<ProfileScreenBackup> {
  late ProfileScreenModel profileModel;

  @override
  void initState() {
    super.initState();
    profileModel = ProfileScreenModel.getMockProfile();
  }

  void _toggleSectionVisibility(int index) {
    setState(() {
      profileModel.dynamicSections[index].isVisible =
          !profileModel.dynamicSections[index].isVisible;
    });
  }

  void _toggleSectionPin(int index) {
    setState(() {
      final section = profileModel.dynamicSections[index];
      section.isPinned = !section.isPinned;

      // Reorder: pinned sections first, then unpinned
      profileModel.dynamicSections.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile (Old)',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
            onPressed: () {
              // Settings action
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Profile Header (Static)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: ProfileHeader(headerInfo: profileModel.headerInfo),
            ),
          ),

          // Dynamic Sections
          SliverPadding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingLg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final section = profileModel.dynamicSections[index];
                  return ProfileSectionCard(
                    section: section,
                    onToggleVisibility: () => _toggleSectionVisibility(index),
                    onTogglePin: () => _toggleSectionPin(index),
                  );
                },
                childCount: profileModel.dynamicSections.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showSectionManager(context);
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.tune, color: Colors.white),
        label: const Text(
          'Manage Sections',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showSectionManager(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Manage Profile Sections',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Expanded(
                    child: ReorderableListView.builder(
                      onReorder: (oldIndex, newIndex) {
                        setModalState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item =
                              profileModel.dynamicSections.removeAt(oldIndex);
                          profileModel.dynamicSections.insert(newIndex, item);
                        });
                        setState(() {});
                      },
                      itemCount: profileModel.dynamicSections.length,
                      itemBuilder: (context, index) {
                        final section = profileModel.dynamicSections[index];
                        return Container(
                          key: ValueKey(section.type),
                          margin: const EdgeInsets.only(
                              bottom: AppConstants.spacingSm),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusSm),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.drag_handle,
                              color: AppTheme.textTertiary,
                            ),
                            title: Text(
                              section.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    section.isPinned
                                        ? Icons.push_pin
                                        : Icons.push_pin_outlined,
                                    size: 18,
                                    color: section.isPinned
                                        ? AppTheme.primaryColor
                                        : AppTheme.textSecondary,
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      section.isPinned = !section.isPinned;
                                    });
                                    setState(() {});
                                  },
                                ),
                                Switch(
                                  value: section.isVisible,
                                  onChanged: (value) {
                                    setModalState(() {
                                      section.isVisible = value;
                                    });
                                    setState(() {});
                                  },
                                  activeThumbColor: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacingMd),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
