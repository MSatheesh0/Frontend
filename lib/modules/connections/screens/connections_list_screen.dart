import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/services/app_state.dart';
import '../../../services/networking_service.dart';
import '../../../utils/theme.dart';
import '../../../screens/profile_viewer_screen.dart';

class ConnectionsListScreen extends StatefulWidget {
  const ConnectionsListScreen({super.key});

  @override
  State<ConnectionsListScreen> createState() => _ConnectionsListScreenState();
}

class _ConnectionsListScreenState extends State<ConnectionsListScreen> {
  final _networkingService = NetworkingService();
  List<Map<String, dynamic>> _connectionsWithUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    setState(() => _isLoading = true);
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final currentUserId = appState.currentUser?['id'] as String?;
      
      if (currentUserId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get all connections for the current user
      final connections = await _networkingService.getUserConnections(currentUserId);
      
      // Fetch user details for each connection
      final connectionsWithUsers = <Map<String, dynamic>>[];
      for (final conn in connections) {
        // Determine the other user's ID
        final otherUserId = conn['userId1'] == currentUserId 
            ? conn['userId2'] 
            : conn['userId1'];
        
        // Fetch the other user's details
        final otherUser = await _networkingService.getUser(otherUserId as String);
        
        if (otherUser != null) {
          connectionsWithUsers.add({
            'connection': conn,
            'user': otherUser,
          });
        }
      }
      
      setState(() {
        _connectionsWithUsers = connectionsWithUsers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading connections: $e');
      setState(() => _isLoading = false);
    }
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
        title: const Text(
          'Connections',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _connectionsWithUsers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadConnections,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    itemCount: _connectionsWithUsers.length,
                    itemBuilder: (context, index) {
                      final item = _connectionsWithUsers[index];
                      final user = item['user'] as Map<String, dynamic>;
                      final connection = item['connection'] as Map<String, dynamic>;
                      return _buildConnectionCard(user, connection);
                    },
                  ),
                ),
    );
  }

  Widget _buildConnectionCard(
    Map<String, dynamic> user,
    Map<String, dynamic> connection,
  ) {
    final connectionSource = connection['connectionSource'] as String? ?? 'direct';
    final notes = connection['notes'] as String? ?? '';
    
    return GestureDetector(
      onTap: () {
        // Navigate to profile viewer with actual user ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileViewerScreen(
              userId: user['id'],
              userName: user['name'],
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
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.1),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Center(
                child: Text(
                  (user['name'] as String).isNotEmpty
                      ? user['name'][0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user['role'] != null && (user['role'] as String).isNotEmpty)
                    Text(
                      user['role'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  if (user['company'] != null && (user['company'] as String).isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user['company'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getSourceIcon(connectionSource),
                          size: 12,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            notes,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textTertiary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Message button
            IconButton(
              icon: const Icon(Icons.message_outlined, size: 20),
              color: AppTheme.primaryColor,
              onPressed: () {
                // Message action
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'qr_scan':
        return Icons.qr_code_scanner;
      case 'network_code':
      case 'network_code_join':
        return Icons.group;
      case 'direct_scan':
        return Icons.person_add;
      default:
        return Icons.link;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            const Text(
              'No connections yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Start networking to build your connections',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
