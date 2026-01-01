
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:file_picker/file_picker.dart';
import '../services/networking_service.dart';
import '../utils/theme.dart';

class EventMembersScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final bool isOrganizer;

  const EventMembersScreen({
    Key? key,
    required this.eventId,
    required this.eventName,
    this.isOrganizer = false,
  }) : super(key: key);

  @override
  State<EventMembersScreen> createState() => _EventMembersScreenState();
}

class _EventMembersScreenState extends State<EventMembersScreen> {
  final _networkingService = NetworkingService();
  late Future<List<Map<String, dynamic>>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _refreshMembers();
  }

  void _refreshMembers() {
    setState(() {
      _membersFuture = _networkingService.getEventMembers(widget.eventId);
    });
  }

  Future<void> _addManualMember() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member Manually'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v?.length != 10 ? 'Must be 10 digits' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _networkingService.addEventMember(
                    eventId: widget.eventId,
                    name: nameController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                  );
                  Navigator.pop(context);
                  _refreshMembers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Member added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add member: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadExcel() async {
    print('📂 _uploadExcel started');
    try {
      print('📂 Picking file...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Critical for Web
      );

      print('📂 Picker Result: ${result != null ? "Found" : "Null"}');

      if (result != null) {
        final platformFile = result.files.single;
        print('📂 File Info - Name: ${platformFile.name}, Size: ${platformFile.size}');

        // Show loading
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()),
        );

        try {
          if (kIsWeb) {
             print('🌐 Web Environment detected.');
             print('📂 Checking bytes...');
             if (platformFile.bytes != null) {
                print('✅ Bytes found (${platformFile.bytes!.length}). Uploading via bytes...');
                await _networkingService.uploadEventMembers(
                  eventId: widget.eventId,
                  bytes: platformFile.bytes,
                  filename: platformFile.name,
                );
             } else {
                print('❌ Web Error: Bytes are null!');
                throw Exception('File bytes are missing on Web.');
             }
          } else {
             // Native
             print('💻 Native Environment detected.');
             // Accessing .path on native is safe, but let's be careful
             final filePath = platformFile.path;
             print('📂 File Path: $filePath');
             
             if (filePath != null) {
                 await _networkingService.uploadEventMembers(
                   eventId: widget.eventId,
                   file: File(filePath),
                 );
             } else {
                 // Fallback to bytes if path is weirdly null on native (e.g. MacOS cached?)
                 if (platformFile.bytes != null) {
                    print('⚠️ Path null on native, but bytes found. Using bytes.');
                    await _networkingService.uploadEventMembers(
                      eventId: widget.eventId,
                      bytes: platformFile.bytes,
                      filename: platformFile.name,
                    );
                 } else {
                    throw Exception('File path and bytes are both missing.');
                 }
             }
          }

          if (mounted) {
             Navigator.pop(context); // Hide loading
             _refreshMembers();
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Members uploaded successfully')),
             );
          }
        } catch (uploadError) {
          print('❌ Upload Process Error: $uploadError');
          if (mounted) Navigator.pop(context); // Hide loading
          throw uploadError;
        }
      } else {
         print('📂 User cancelled picker');
      }
    } catch (e) {
      print('❌ Outer Upload Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Add Manually'),
            onTap: () {
              Navigator.pop(context);
              _addManualMember();
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Upload Excel'),
            subtitle: const Text('Columns: Name, Phone'),
            onTap: () {
              Navigator.pop(context);
              _uploadExcel();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.eventName} Members'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final members = snapshot.data ?? [];

          if (members.isEmpty) {
            return const Center(child: Text('No members yet.'));
          }

          // Deduplicate and Normalize
          // The backend now returns EventMember documents which have 'name' and 'phoneNumber' at the top level.
          // This unified structure works for Join, Manual, and Excel sources.
          final uniqueMembers = <Map<String, dynamic>>[];
          final seenKeys = <String>{};

          for (var member in members) {
             // 1. Try top-level name/phone directly (Prioritize EventMember logic)
             String name = member['name']?.toString() ?? '';
             String phone = member['phoneNumber']?.toString() ?? '';
             
             // 2. Fallback to older nested structure if somehow present (legacy safety)
             if (name.isEmpty || phone.isEmpty) {
                final participant = member['participantId'];
                if (participant is Map<String, dynamic>) {
                   if (name.isEmpty) name = participant['name']?.toString() ?? 'Unknown';
                   if (phone.isEmpty) phone = participant['phoneNumber']?.toString() ?? '';
                }
             }

             // Normalize for deduplication (Phone number based, or name if phone is missing)
             final key = phone.isNotEmpty ? phone.replaceAll(RegExp(r'\D'), '') : name.toLowerCase();
             
             // If key exists and hasn't been seen, or if we want to show everything (users choice), 
             // but user asked for "1 akash... 2 minu...", so distinct list is implied.
             if (key.isNotEmpty && !seenKeys.contains(key)) {
                seenKeys.add(key);
                uniqueMembers.add({
                  ...member,
                  'displayName': name.isNotEmpty ? name : 'Unknown',
                  'displayPhone': phone,
                });
             }
          }
          
          // Sort alphabetically by Name
          uniqueMembers.sort((a, b) => 
             (a['displayName'] as String).toLowerCase().compareTo((b['displayName'] as String).toLowerCase())
          );

          return ListView.builder(
            itemCount: uniqueMembers.length,
            itemBuilder: (context, index) {
              final memberData = uniqueMembers[index];
              final name = memberData['displayName'] as String;
              final phone = memberData['displayPhone'] as String;
              final source = memberData['source']?.toString() ?? 'unknown';

              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                      style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    phone.isNotEmpty ? phone : 'No phone number',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: _buildSourceTag(source),
                  onTap: () => _showMemberDetailsModal(name, phone, source),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.isOrganizer
          ? FloatingActionButton(
              onPressed: _showAddOptions,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget? _buildSourceTag(String source) {
    Color color;
    String label;
    
    switch (source) {
      case 'excel':
        color = Colors.green;
        label = 'Excel';
        break;
      case 'manual':
        color = Colors.orange;
        label = 'Manual';
        break;
      case 'join':
        color = Colors.blue;
        label = 'App User';
        break;
      default:
        return null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showMemberDetailsModal(String name, String phone, String source) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
               backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                style: TextStyle(fontSize: 32, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.phone, 'Phone', phone.isNotEmpty ? phone : 'N/A'),
            _buildDetailRow(Icons.source, 'Source', source.toUpperCase()),
            const SizedBox(height: 24),
          ],
        ),
      )
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
