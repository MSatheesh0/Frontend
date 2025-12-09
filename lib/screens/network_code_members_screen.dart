import 'package:flutter/material.dart';
import '../services/networking_service.dart';
import '../utils/theme.dart';
import 'profile_viewer_screen.dart';

class NetworkCodeMembersScreen extends StatefulWidget {
  final String networkCodeId;
  final String networkName;

  const NetworkCodeMembersScreen({
    super.key,
    required this.networkCodeId,
    required this.networkName,
  });

  @override
  State<NetworkCodeMembersScreen> createState() =>
      _NetworkCodeMembersScreenState();
}

class _NetworkCodeMembersScreenState extends State<NetworkCodeMembersScreen> {
  late Future<List<Map<String, dynamic>>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    setState(() {
      _membersFuture =
          NetworkingService().getNetworkCodeMembers(widget.networkCodeId);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.networkName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const Text(
              'Members',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  TextButton(
                    onPressed: _loadMembers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final members = snapshot.data ?? [];

          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No members yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share this network code to add members',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return _buildMemberCard(context, member);
            },
          );
        },
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, Map<String, dynamic> member) {
    // Determine the safe name to display
    final name = member['name'] ?? 'Unknown User';
    final role = member['role'] ?? 'Member';
    
    // Some endpoints might return different structures, adjust as needed
    // Assuming structure: { 'id': '...', 'name': '...', 'role': '...', 'photoUrl': '...' }
    // Or it might be inside a 'user' object if it's a join record.
    // Based on NetworkingService.getNetworkCodeMembers, it returns a list of maps.
    // If the map has a 'user' key (e.g. populated), we should use that.
    final userData = member.containsKey('user') ? member['user'] : member;
    final displayName = userData['name'] ?? name;
    final displayRole = userData['role'] ?? role;
    final displayCompany = userData['company'] ?? '';
    final displayLocation = userData['location'] ?? '';
    final displayEmail = userData['email'] ?? '';
    final displayPhotoUrl = userData['photoUrl'] as String?;
    final userId = userData['userId'] ?? userData['_id'] ?? userData['id'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileViewerScreen(
              userName: displayName,
              userId: userId?.toString(),
              readOnly: true, // Read-only when viewing from network members
              initialData: {
                'name': displayName,
                'role': displayRole,
                'company': displayCompany,
                'location': displayLocation,
                'email': displayEmail,
                'oneLiner': '', // Might not be available in members list
                'website': '',
                'photoUrl': displayPhotoUrl,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
                image: displayPhotoUrl != null && displayPhotoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(displayPhotoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: displayPhotoUrl == null || displayPhotoUrl.isEmpty
                  ? Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayRole,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
