import 'dart:io';
import 'package:flutter/material.dart';
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
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()),
        );

        await _networkingService.uploadEventMembers(
          eventId: widget.eventId,
          file: file,
        );

        Navigator.pop(context); // Hide loading
        _refreshMembers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Members uploaded successfully')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Hide loading if error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
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

          // Deduplicate based on phone number
          final uniqueMembers = <Map<String, dynamic>>[];
          final seenPhones = <String>{};

          for (var member in members) {
            final participant = member['participantId'] ?? {};
            final phone = participant['phoneNumber']?.toString() ?? '';
            
            if (phone.isNotEmpty) {
              if (!seenPhones.contains(phone)) {
                seenPhones.add(phone);
                uniqueMembers.add(member);
              }
            } else {
              // If no phone, include it (or dedupe by email/id if needed, but keeping simple)
              uniqueMembers.add(member);
            }
          }

          return ListView.builder(
            itemCount: uniqueMembers.length,
            itemBuilder: (context, index) {
              final memberData = uniqueMembers[index];
              final participant = (memberData['participantId'] as Map<String, dynamic>?) ?? {};
              var name = participant['name']?.toString() ?? 'Unknown';
              if (name.isEmpty) name = 'Unknown';
              final email = participant['email'] ?? '';
              final phone = participant['phoneNumber']?.toString() ?? '';
              final photoUrl = participant['photoUrl'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Text(name.substring(0, 1).toUpperCase())
                      : null,
                ),
                title: Text(name),
                subtitle: Text(phone.isNotEmpty ? phone : email),
                onTap: () => _showMemberDetails(participant),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.isOrganizer
          ? FloatingActionButton(
              onPressed: _showAddOptions,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showMemberDetails(Map<String, dynamic> participant) {
    final name = participant['name']?.toString() ?? 'Unknown';
    final email = participant['email']?.toString() ?? 'N/A';
    final phone = participant['phoneNumber']?.toString() ?? 'N/A';
    final role = participant['role']?.toString() ?? 'N/A';
    final company = participant['company']?.toString() ?? 'N/A';
    final position = participant['position']?.toString() ?? 'N/A';
    final photoUrl = participant['photoUrl'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true, // Allow full height if needed
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null || photoUrl.isEmpty
                    ? Text(
                        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                role,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(Icons.phone, 'Phone', phone),
              _buildDetailRow(Icons.email, 'Email', email),
              _buildDetailRow(Icons.business, 'Company', company),
              _buildDetailRow(Icons.work, 'Position', position),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
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
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
