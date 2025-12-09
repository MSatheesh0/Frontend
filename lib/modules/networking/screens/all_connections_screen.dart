import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/app_state.dart';
import '../../../services/networking_service.dart';
import '../../../screens/profile_viewer_screen.dart';
import '../../../utils/theme.dart';

class AllConnectionsScreen extends StatefulWidget {
  const AllConnectionsScreen({Key? key}) : super(key: key);

  @override
  State<AllConnectionsScreen> createState() => _AllConnectionsScreenState();
}

class _AllConnectionsScreenState extends State<AllConnectionsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _connections = [];

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    setState(() => _isLoading = true);
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.currentUser == null) return;

      final userId = appState.currentUser!.id;
      
      // Fetch all accepted connections
      final connections = await NetworkingService().getUserConnections(userId);

      setState(() {
        _connections = connections;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading connections: $e');
      setState(() => _isLoading = false);
    }
  }

  void _openProfile(String? userId, String? userName) {
    if (userId == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileViewerScreen(
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'All Connections',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _connections.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No connections yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Scan QR codes to connect with people',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConnections,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _connections.length,
                    itemBuilder: (context, index) {
                      final conn = _connections[index];
                      
                      // Determine which user is the connection (not current user)
                      final appState = Provider.of<AppState>(context, listen: false);
                      final currentUserId = appState.currentUser?.id;
                      
                      final user1 = conn['userId'];
                      final user2 = conn['requestorId'];
                      
                      final otherUser = (user1 is Map && user1['_id'] == currentUserId) || 
                                       (user1 is String && user1 == currentUserId)
                          ? user2 
                          : user1;
                      
                      // Extract user details
                      final name = otherUser is Map 
                          ? (otherUser['name']?.toString() ?? 'Unknown User')
                          : 'Unknown User';
                      final role = otherUser is Map 
                          ? (otherUser['role']?.toString() ?? '')
                          : '';
                      final company = otherUser is Map 
                          ? (otherUser['company']?.toString() ?? '')
                          : '';
                      final photoUrl = otherUser is Map 
                          ? otherUser['photoUrl']?.toString()
                          : null;
                      final userId = otherUser is Map 
                          ? (otherUser['_id']?.toString() ?? otherUser['id']?.toString())
                          : (otherUser is String ? otherUser : null);
                      final connectionCount = otherUser is Map 
                          ? (otherUser['connectionCount'] ?? 0)
                          : 0;
                      
                      // Extract network details
                      final networkCode = conn['networkCodeId'];
                      final networkName = networkCode is Map 
                          ? (networkCode['name']?.toString() ?? 'Unknown Network')
                          : 'Unknown Network';
                      final codeId = conn['codeId']?.toString() ?? 
                                    (networkCode is Map ? networkCode['codeId']?.toString() : null) ?? 
                                    'N/A';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Info Row
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                                        ? NetworkImage(photoUrl) 
                                        : null,
                                    child: photoUrl == null || photoUrl.isEmpty
                                        ? Text(
                                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ) 
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        if (role.isNotEmpty)
                                          Text(
                                            '$role${company.isNotEmpty ? ' at $company' : ''}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              
                              // Network Info
                              Row(
                                children: [
                                  Icon(Icons.hub, size: 16, color: AppTheme.textSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Network: $networkName',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              
                              // Code ID
                              Row(
                                children: [
                                  Icon(Icons.qr_code, size: 16, color: AppTheme.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Code: $codeId',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              
                              // Connection Count
                              Row(
                                children: [
                                  Icon(Icons.people, size: 16, color: AppTheme.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Total Connections: $connectionCount',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // View Profile Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _openProfile(userId, name),
                                  icon: const Icon(Icons.person, size: 18),
                                  label: const Text('View Profile'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
