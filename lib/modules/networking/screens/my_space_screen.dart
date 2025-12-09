import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/app_state.dart';
import '../../../services/networking_service.dart';
import '../../../screens/profile_viewer_screen.dart';
import '../../../screens/network_code_members_screen.dart';
import '../../../screens/network_code_requests_screen.dart';

class MySpaceScreen extends StatefulWidget {
  const MySpaceScreen({Key? key}) : super(key: key);

  @override
  State<MySpaceScreen> createState() => _MySpaceScreenState();
}

class _MySpaceScreenState extends State<MySpaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, List<Map<String, dynamic>>> _requestsByCode = {};
  Map<String, List<Map<String, dynamic>>> _connectionsByCode = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.currentUser == null) return;

      final userId = appState.currentUser!.id;

      // Fetch pending requests
      final requests = await NetworkingService().getPendingRequests(userId);
      
      // Fetch accepted connections
      final connections = await NetworkingService().getUserConnections(userId);

      // Group requests by network code
      final groupedRequests = <String, List<Map<String, dynamic>>>{};
      for (var request in requests) {
        final networkCodeName = request['networkCodeId']?['name'] ?? 'Unknown Network';
        if (!groupedRequests.containsKey(networkCodeName)) {
          groupedRequests[networkCodeName] = [];
        }
        groupedRequests[networkCodeName]!.add(request);
      }

      // Group connections by network code
      final groupedConnections = <String, List<Map<String, dynamic>>>{};
      for (var connection in connections) {
        // Filter: Only show connections for networks created by the current user
        // The 'userId' field in Connection represents the Owner.
        final ownerData = connection['userId'];
        final ownerId = ownerData is Map 
            ? (ownerData['_id']?.toString() ?? ownerData['id']?.toString()) 
            : ownerData?.toString();
            
        if (ownerId != userId) {
          continue; 
        }

        final networkCodeName = connection['networkCodeId']?['name'] ?? 
                                connection['codeId'] ?? 'Unknown Network';
        if (!groupedConnections.containsKey(networkCodeName)) {
          groupedConnections[networkCodeName] = [];
        }
        groupedConnections[networkCodeName]!.add(connection);
      }

      setState(() {
        _requestsByCode = groupedRequests;
        _connectionsByCode = groupedConnections;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRequest(String requestId, bool accept) async {
    try {
      if (accept) {
        await NetworkingService().approveRequest(requestId);
      } else {
        await NetworkingService().rejectRequest(requestId);
      }
      _loadData(); // Reload data
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(accept ? 'Request Accepted' : 'Request Rejected')),
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
      appBar: AppBar(
        title: const Text('My Space'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.inbox),
              text: 'Requests (${_requestsByCode.values.fold<int>(0, (sum, list) => sum + list.length)})',
            ),
            Tab(
              icon: const Icon(Icons.people),
              text: 'Connections (${_connectionsByCode.values.fold<int>(0, (sum, list) => sum + list.length)})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsTab(),
                _buildConnectionsTab(),
              ],
            ),
    );
  }

  Widget _buildRequestsTab() {
    if (_requestsByCode.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No pending requests', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requestsByCode.length,
      itemBuilder: (context, index) {
        final networkName = _requestsByCode.keys.elementAt(index);
        final requests = _requestsByCode[networkName]!;

        return GestureDetector(
          onTap: () async {
            // Navigate to requests screen and reload data on return
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NetworkCodeRequestsScreen(
                  networkName: networkName,
                  requests: requests,
                ),
              ),
            );
            // Reload data to reflect any changes made in the detail screen
            _loadData();
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.hub, size: 24, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          networkName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to review requests',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${requests.length} Pending',
                      style: const TextStyle(
                        fontSize: 12, 
                        color: Colors.white, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionsTab() {
    if (_connectionsByCode.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No connections yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _connectionsByCode.length,
      itemBuilder: (context, index) {
        final networkName = _connectionsByCode.keys.elementAt(index);
        final connections = _connectionsByCode[networkName]!;
        
        // Get network code ID from first connection
        // Prioritize the top-level 'codeId' from the connection object as it is required and always correct
        String networkCodeId = '';
        if (connections.isNotEmpty) {
           final conn = connections[0];
           // 1. Try top-level codeId (most reliable)
           if (conn['codeId'] != null) {
             networkCodeId = conn['codeId'].toString();
           } 
           // 2. Try nested codeId inside networkCodeId object
           else if (conn['networkCodeId'] is Map && conn['networkCodeId']['codeId'] != null) {
             networkCodeId = conn['networkCodeId']['codeId'].toString();
           }
           // 3. Do NOT fallback to _id as that is the Mongo ID not the public code ID
        }

        return GestureDetector(
          onTap: () {
            if (networkCodeId.isNotEmpty) {
              // Navigate to network code members screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NetworkCodeMembersScreen(
                    networkCodeId: networkCodeId,
                    networkName: networkName,
                  ),
                ),
              );
            }
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.hub, size: 24, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      networkName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${connections.length} ${connections.length == 1 ? 'Member' : 'Members'}',
                      style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
