import 'package:flutter/material.dart';
import '../services/networking_service.dart';
import '../utils/theme.dart';
import 'profile_viewer_screen.dart';

class QrScanResultScreen extends StatefulWidget {
  final String codeId;
  final String? userId;

  QrScanResultScreen({
    super.key, 
    required this.codeId,
    this.userId,
  }) {
    print('🔵 QR SCAN RESULT SCREEN: Constructor called with codeId=$codeId, userId=$userId');
  }

  @override
  State<QrScanResultScreen> createState() {
    print('🔵 QR SCAN RESULT SCREEN: createState called');
    return _QrScanResultScreenState();
  }
}

class _QrScanResultScreenState extends State<QrScanResultScreen> {
  final _networkingService = NetworkingService();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  Map<String, dynamic>? _networkCode;
  Map<String, dynamic>? _creator;
  List<Map<String, dynamic>> _creatorNetworkCodes = [];
  
  // Status tracking
  String _connectionStatus = 'none'; // none, pending, accepted, rejected
  bool _isFollowing = false;
  bool _isConnecting = false;
  bool _isFollowingAction = false;

  @override
  void initState() {
    print('🟢 QR SCAN RESULT SCREEN: initState called! codeId=${widget.codeId}');
    super.initState();
    print('🟢 QR SCAN RESULT SCREEN: About to call _handleQrScan()');
    _handleQrScan();
  }

  Future<void> _handleQrScan() async {
    print('🔍 QR SCAN: Starting scan process');
    print('📱 QR SCAN: Scanned Code ID: ${widget.codeId}');
    print('👤 QR SCAN: Current User ID: ${widget.userId}');
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final currentUserId = widget.userId;
      
      if (currentUserId == null || currentUserId.isEmpty) {
        print('❌ QR SCAN: No user logged in');
        setState(() {
          _hasError = true;
          _errorMessage = 'Please log in to connect';
          _isLoading = false;
        });
        return;
      }

      // 1. Get network code details
      print('📡 QR SCAN: Fetching network code details...');
      final networkCode = await _networkingService.findNetworkCodeByCode(widget.codeId);
      
      if (networkCode == null) {
        print('❌ QR SCAN: Network code not found');
        setState(() {
          _hasError = true;
          _errorMessage = 'Network code not found';
          _isLoading = false;
        });
        return;
      }
      
      print('✅ QR SCAN: Network code found: ${networkCode['name']}');
      print('📋 QR SCAN: Network Code Data: $networkCode');
      setState(() => _networkCode = networkCode);

      // 2. Get creator details
      print('🕵️ QR SCAN: Extracting creator ID...');
      String? creatorId;
      
      if (networkCode['userId'] != null) {
        if (networkCode['userId'] is Map) {
          final userMap = networkCode['userId'] as Map;
          creatorId = userMap['_id']?.toString() ?? userMap['id']?.toString();
          print('✅ QR SCAN: Found creator ID in Map: $creatorId');
        } else if (networkCode['userId'] is String) {
          creatorId = networkCode['userId'] as String;
          print('✅ QR SCAN: Found creator ID as String: $creatorId');
        } else {
          print('⚠️ QR SCAN: Unknown userId format: ${networkCode['userId'].runtimeType}');
        }
      } else {
        print('⚠️ QR SCAN: userId field is null in network code');
      }
      
      if (creatorId != null) {
        print('📡 QR SCAN: Fetching creator profile for ID: $creatorId');
        try {
          final creator = await _networkingService.getUser(creatorId);
          if (creator != null) {
            print('✅ QR SCAN: Creator profile fetched: ${creator['name']}');
            if (mounted) {
              setState(() => _creator = creator);
            }
            
            // Check following status
            print('📡 QR SCAN: Checking following status...');
            try {
              final followings = await _networkingService.getUserFollowings(currentUserId);
              print('📊 QR SCAN: Retrieved ${followings.length} followings');
              final isFollowing = followings.any((f) {
                final fId = f['followingId'] is Map 
                    ? (f['followingId']['_id'] ?? f['followingId']['id']) 
                    : f['followingId'];
                return fId.toString() == creatorId;
              });
              
              print('✅ QR SCAN: Is following: $isFollowing');
              if (mounted) {
                setState(() {
                  _isFollowing = isFollowing;
                });
              }
            } catch (e) {
              print('❌ QR SCAN: Error checking following status: $e');
              // Don't block on following status error
            }
          } else {
            print('⚠️ QR SCAN: Creator profile is null');
          }
        } catch (e) {
          print('❌ QR SCAN: Error fetching creator profile: $e');
          // Don't block on creator profile error
        }
      } else {
        print('⚠️ QR SCAN: Could not extract creator ID, skipping profile fetch');
      }

      // 2b. Fetch all network codes created by this user
      if (creatorId != null) {
        print('📡 QR SCAN: Fetching all network codes by creator...');
        try {
          final allCodes = await _networkingService.getUserNetworkCodes(creatorId);
          print('📊 QR SCAN: Retrieved ${allCodes.length} network codes');
          if (allCodes.isNotEmpty) {
            print('✅ QR SCAN: Found ${allCodes.length} network codes by creator');
            if (mounted) {
              setState(() => _creatorNetworkCodes = allCodes);
            }
          } else {
            print('ℹ️ QR SCAN: Creator has no other network codes');
          }
        } catch (e) {
          print('❌ QR SCAN: Error fetching creator network codes: $e');
          // Don't block on this error
        }
      } else {
        print('⚠️ QR SCAN: Skipping network codes fetch - no creator ID');
      }

      // 3. Check connection status
      print('📡 QR SCAN: Checking connection status...');
      try {
        final connections = await _networkingService.getUserConnections(currentUserId);
        print('📊 QR SCAN: Retrieved ${connections.length} connections');
        final existingConn = connections.firstWhere(
          (c) => c['codeId'] == widget.codeId, 
          orElse: () => {},
        );
        
        if (existingConn.isNotEmpty) {
          final status = existingConn['status'] ?? 'none';
          print('✅ QR SCAN: Found existing connection. Status: $status');
          if (mounted) {
            setState(() {
              _connectionStatus = status;
            });
          }
        } else {
           print('ℹ️ QR SCAN: No existing accepted connection found');
           // Check pending requests
           try {
             final pending = await _networkingService.getPendingRequests(currentUserId);
             print('📊 QR SCAN: Retrieved ${pending.length} pending requests');
           } catch (e) {
             print('❌ QR SCAN: Error checking pending requests: $e');
           }
           // TODO: Check if we have a pending OUTGOING request. 
           // For now, default to 'none' which shows "Connect" button.
           if (mounted) {
             setState(() {
               _connectionStatus = 'none';
             });
           }
        }
      } catch (e) {
        print('❌ QR SCAN: Error checking connection status: $e');
        // Don't block on connection status error
      }

      print('✅ QR SCAN: All data fetching complete!');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('🎉 QR SCAN: Screen is now ready to display');
      
    } catch (e) {
      print('❌ QR SCAN CRITICAL ERROR: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleConnect() async {
    if (_isConnecting) return;

    // Check if already connected
    if (_connectionStatus == 'accepted') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ You\'re already connected! View their profile in My Spaces'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 2000),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) Navigator.pop(context);
      }
      return;
    }

    // Check if request already pending
    if (_connectionStatus == 'pending') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏳ Connection request pending approval by creator'),
            backgroundColor: Colors.orange,
            duration: Duration(milliseconds: 2000),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) Navigator.pop(context);
      }
      return;
    }

    setState(() => _isConnecting = true);
    try {
      final result = await _networkingService.joinNetworkCode(
        userId: widget.userId!,
        code: widget.codeId,
      );
      
      print('✅ QR SCAN: Connection successful, status: ${result['status']}');
      
      if (mounted) {
        setState(() {
          _connectionStatus = result['status'] ?? 'pending';
          _isConnecting = false;
        });
      }
      
      if (mounted) {
        print('📱 QR SCAN: Showing success snackbar');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_connectionStatus == 'accepted' 
              ? '✅ Connected successfully!' 
              : '✅ Connection request sent!'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 1500),
          ),
        );
        
        // Auto-navigate back after showing success message
        print('⏱️ QR SCAN: Waiting 800ms before navigation...');
        await Future.delayed(const Duration(milliseconds: 800));
        print('🔙 QR SCAN: Attempting to navigate back, mounted=$mounted');
        if (mounted) {
          print('✅ QR SCAN: Calling Navigator.pop');
          Navigator.pop(context);
          print('✅ QR SCAN: Navigator.pop completed');
        } else {
          print('⚠️ QR SCAN: Widget no longer mounted, skipping navigation');
        }
      }
    } catch (e) {
      print('❌ QR SCAN: Connection error: $e');
      if (mounted) {
        String errorMessage = '❌ Connection failed';
        Color backgroundColor = Colors.red;
        bool shouldNavigateBack = true; // Default to true for most errors
        
        final errorText = e.toString().toLowerCase();
        
        print('🔍 QR SCAN: Error text for matching: $errorText');
        
        // Check for specific error types
        if (errorText.contains('already exist') || errorText.contains('connection exist')) {
          print('✅ QR SCAN: Detected duplicate connection error');
          errorMessage = '✅ You\'re already connected! View their profile in My Spaces';
          backgroundColor = Colors.green;
          setState(() => _connectionStatus = 'accepted');
        } else if (errorText.contains('pending')) {
          print('⚠️ QR SCAN: Detected pending connection');
          errorMessage = '⏳ Connection request pending approval by creator';
          backgroundColor = Colors.orange;
          setState(() => _connectionStatus = 'pending');
        } else if (errorText.contains('own network code') || errorText.contains('cannot connect to your own')) {
          print('⚠️ QR SCAN: Cannot connect to own code');
          errorMessage = '💡 This is your network code! Share it with others to connect';
          backgroundColor = Colors.orange;
        } else if (errorText.contains('inactive') || errorText.contains('expired')) {
          print('⚠️ QR SCAN: Code inactive or expired');
          errorMessage = '⚠️ This network code has expired or is inactive';
          backgroundColor = Colors.orange;
        } else if (errorText.contains('not found')) {
          print('❌ QR SCAN: Code not found');
          errorMessage = '🔍 Network code not found. Please check the code and try again';
          backgroundColor = Colors.red;
        } else {
          print('❌ QR SCAN: Generic error');
          // Generic error - clean up the message
          errorMessage = '❌ ${e.toString().replaceAll('Exception: ', '').replaceAll('exception:', '')}';
          shouldNavigateBack = false; // Don't navigate for unknown errors
        }
        
        print('📢 QR SCAN: Showing error message: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: backgroundColor,
            duration: const Duration(milliseconds: 2000),
          ),
        );
        
        // Navigate back for known errors
        if (shouldNavigateBack) {
          print('🔙 QR SCAN: Will navigate back in 1200ms');
          await Future.delayed(const Duration(milliseconds: 1200));
          print('🔙 QR SCAN: Navigating back now, mounted=$mounted');
          if (mounted) {
            print('✅ QR SCAN: Calling Navigator.pop from error handler');
            Navigator.pop(context);
            print('✅ QR SCAN: Navigator.pop completed from error handler');
          }
        } else {
          print('⚠️ QR SCAN: Skipping navigation for unknown error');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _handleFollow() async {
    if (_isFollowingAction || _creator == null) return;
    
    setState(() => _isFollowingAction = true);
    try {
      final creatorId = _creator!['_id'] ?? _creator!['id'];
      
      if (_isFollowing) {
        await _networkingService.unfollowProfile(widget.userId!, creatorId);
        setState(() => _isFollowing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unfollowed user')),
          );
        }
      } else {
        await _networkingService.followProfile(
          userId: widget.userId!,
          followingId: creatorId,
          label: _creator!['name'] ?? 'User',
          type: 'profile',
        );
        setState(() => _isFollowing = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Followed user!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isFollowingAction = false);
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
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Network Code',
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
          : _hasError
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: AppConstants.spacingMd),
            const Text(
              'Error',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Network Code Badge at top
          if (_networkCode != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                  vertical: AppConstants.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  border: Border.all(color: AppTheme.primaryColor),
                ),
                child: Text(
                  _networkCode!['name'] ?? 'Network Code',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppConstants.spacingXl),
          
          // Creator Profile - Main Focus
          if (_creator != null) ...[
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  border: Border.all(color: AppTheme.primaryColor, width: 3),
                ),
                child: Center(
                  child: Text(
                    (_creator!['name'] as String? ?? '?')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            
            // Name
            Text(
              _creator!['name'] ?? 'Unknown User',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            
            // Role
            if (_creator!['role'] != null)
              Text(
                _creator!['role'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            const SizedBox(height: AppConstants.spacingXl),

            // View Full Profile Link
            Center(
              child: TextButton.icon(
                onPressed: () {
                  final creatorId = _creator!['_id'] ?? _creator!['id'];
                  if (creatorId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileViewerScreen(
                          userId: creatorId,
                          userName: _creator!['name'] ?? 'User',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.person, size: 18),
                label: const Text('View Full Profile'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
          ],

          // Actions - Centered
          Row(
            children: [
              // Connect Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _connectionStatus == 'accepted' || _connectionStatus == 'pending'
                      ? null // Disable if already connected or pending
                      : _handleConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                  ),
                  child: _isConnecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _connectionStatus == 'accepted' 
                              ? 'Connected' 
                              : _connectionStatus == 'pending'
                                  ? 'Request Sent'
                                  : 'Connect',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: AppConstants.spacingMd),
              
              // Follow Button
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleFollow,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isFollowing ? Colors.grey : AppTheme.primaryColor,
                    side: BorderSide(
                      color: _isFollowing ? Colors.grey : AppTheme.primaryColor,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                  ),
                  child: _isFollowingAction
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isFollowing ? 'Following' : 'Follow',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywords(List keywords) {
    if (keywords.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingSm),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: keywords.map((keyword) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Text(
              keyword.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNetworkCodeItem(Map<String, dynamic> code) {
    final codeId = code['codeId'] ?? code['code'] ?? '';
    final isCurrentCode = codeId == widget.codeId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: isCurrentCode ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: isCurrentCode ? AppTheme.primaryColor : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      code['name'] ?? 'Unnamed',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCurrentCode ? AppTheme.primaryColor : AppTheme.textPrimary,
                      ),
                    ),
                    if (isCurrentCode) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'CURRENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  codeId,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (code['isActive'] == false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Inactive',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
