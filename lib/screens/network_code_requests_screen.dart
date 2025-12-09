import 'package:flutter/material.dart';
import '../services/networking_service.dart';
import '../utils/theme.dart';
import 'profile_viewer_screen.dart';

class NetworkCodeRequestsScreen extends StatefulWidget {
  final String networkName;
  final List<Map<String, dynamic>> requests;

  const NetworkCodeRequestsScreen({
    super.key,
    required this.networkName,
    required this.requests,
  });

  @override
  State<NetworkCodeRequestsScreen> createState() => _NetworkCodeRequestsScreenState();
}

class _NetworkCodeRequestsScreenState extends State<NetworkCodeRequestsScreen> {
  late List<Map<String, dynamic>> _currentRequests;

  @override
  void initState() {
    super.initState();
    _currentRequests = List.from(widget.requests);
  }

  Future<void> _handleRequest(String requestId, bool accept) async {
    try {
      if (accept) {
        await NetworkingService().approveRequest(requestId);
      } else {
        await NetworkingService().rejectRequest(requestId);
      }
      
      setState(() {
        _currentRequests.removeWhere((req) {
          final id = req['_id']?.toString() ?? req['id']?.toString();
          return id == requestId;
        });
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accept ? 'Request Accepted' : 'Request Rejected'),
            backgroundColor: accept ? Colors.green : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _openProfile(Map<String, dynamic> requestor) {
    // Extract user details
    final name = requestor['name']?.toString() ?? 'Unknown User';
    final userId = requestor['_id']?.toString() ?? requestor['id']?.toString();
    final role = requestor['role']?.toString() ?? '';
    final company = requestor['company']?.toString() ?? '';
    final location = requestor['location']?.toString() ?? '';
    final email = requestor['email']?.toString() ?? '';
    final photoUrl = requestor['photoUrl']?.toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileViewerScreen(
          userName: name,
          userId: userId,
          readOnly: true, // Read-only but we have buttons on the list itself
          initialData: {
            'name': name,
            'role': role,
            'company': company,
            'location': location,
            'email': email,
            'photoUrl': photoUrl,
          },
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context, true), // Return true to indicate potential changes
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
            Text(
              '${_currentRequests.length} Pending Actions',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: _currentRequests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'All Caught Up!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No pending requests for this network.',
                    style: TextStyle(color: AppTheme.textTertiary),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              itemCount: _currentRequests.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppConstants.spacingMd),
              itemBuilder: (context, index) {
                final req = _currentRequests[index];
                final requestor = req['requestorId'] ?? {};
                final name = requestor['name']?.toString() ?? 'Unknown User';
                final role = requestor['role']?.toString() ?? '';
                final company = requestor['company']?.toString() ?? '';
                final photoUrl = requestor['photoUrl']?.toString();
                final requestId = req['_id']?.toString() ?? req['id']?.toString() ?? '';
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: GestureDetector(
                          onTap: () => _openProfile(requestor),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              image: photoUrl != null && photoUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(photoUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: photoUrl == null || photoUrl.isEmpty
                                ? Center(
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (role.isNotEmpty || company.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  role.isNotEmpty && company.isNotEmpty 
                                      ? '$role at $company' 
                                      : (role.isNotEmpty ? role : company),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            if (req['message'] != null && req['message'].toString().isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '"${req['message']}"',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () => _openProfile(requestor),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _handleRequest(requestId, false),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Reject'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red.withOpacity(0.5)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleRequest(requestId, true),
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
