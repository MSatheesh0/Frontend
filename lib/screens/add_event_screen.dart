import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../models/event.dart';
import '../services/networking_service.dart';
import '../utils/theme.dart';

class AddEventScreen extends StatefulWidget {
  final Event? event;
  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _networkingService = NetworkingService();
  final _imagePicker = ImagePicker();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _headlineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  
  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 7));
  List<String> _selectedPhotos = [];
  List<String> _selectedVideos = [];
  bool _isEvent = true;
  bool _isCommunity = false;
  bool _isLoading = false;
  
  // PDF file (only for events)
  String? _selectedPdfBase64;
  String? _selectedPdfName;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _nameController.text = widget.event!.name;
      _headlineController.text = widget.event!.headline ?? '';
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _tagsController.text = widget.event!.tags.join(', ');
      _selectedDateTime = widget.event!.dateTime;
      _isEvent = widget.event!.isEvent;
      _isCommunity = widget.event!.isCommunity;
      // Note: We don't populate photos/videos/pdf here as they are paths or base64
      // and might need different handling if we want to show existing ones.
      // For now, we'll focus on text fields and basic flags.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // ... (keep existing helper methods)

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedPhotos.addAll(images.map((img) => img.path));
        });
      }
    } catch (e) {
      _showError('Failed to pick images: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        setState(() {
          _selectedVideos.add(video.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick video: $e');
    }
  }

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final base64Pdf = base64Encode(bytes);
        
        setState(() {
          _selectedPdfBase64 = 'data:application/pdf;base64,$base64Pdf';
          _selectedPdfName = result.files.single.name;
        });
        
        print('📄 PDF selected: ${result.files.single.name} (${bytes.length} bytes)');
      }
    } catch (e) {
      _showError('Failed to pick PDF: $e');
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse tags from comma-separated string
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      if (widget.event != null) {
        // Update existing event
        await _networkingService.updateEvent(
          eventId: widget.event!.id,
          name: _nameController.text.trim(),
          headline: _headlineController.text.trim().isEmpty ? null : _headlineController.text.trim(),
          description: _descriptionController.text.trim(),
          dateTime: _selectedDateTime,
          location: _locationController.text.trim(),
          tags: tags,
        );
      } else {
        // Create new event
        await _networkingService.createEvent(
          name: _nameController.text.trim(),
          headline: _headlineController.text.trim().isEmpty 
              ? null 
              : _headlineController.text.trim(),
          description: _descriptionController.text.trim(),
          dateTime: _selectedDateTime,
          location: _locationController.text.trim(),
          photos: _selectedPhotos,
          videos: _selectedVideos,
          tags: tags,
          isEvent: _isEvent,
          isCommunity: _isCommunity,
          pdfFile: (_isEvent && _selectedPdfBase64 != null) ? _selectedPdfBase64 : null,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('✅ ${widget.event != null ? 'Updated' : 'Created'} successfully!'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showError('Failed to ${widget.event != null ? 'update' : 'create'}: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
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
        title: Text(
          widget.event != null ? 'Edit Event' : 'Create New',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveEvent,
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          children: [
            // Type Toggles
            // Type Selection Buttons
            Row(
              children: [
                // Event Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEvent = true;
                        _isCommunity = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isEvent ? AppTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isEvent ? AppTheme.primaryColor : Colors.grey[300]!,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Event',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isEvent ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Community Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCommunity = true;
                        _isEvent = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isCommunity ? AppTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isCommunity ? AppTheme.primaryColor : Colors.grey[300]!,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Community',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isCommunity ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Event Name
            _buildSectionLabel(_isEvent ? 'Event Name' : 'Community Name', required: true),
            const SizedBox(height: AppConstants.spacingSm),
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration(
                hintText: 'e.g., TechCrunch Disrupt 2025',
                prefixIcon: Icons.event,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Event name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Headline
            _buildSectionLabel('Headline'),
            const SizedBox(height: AppConstants.spacingSm),
            TextFormField(
              controller: _headlineController,
              decoration: _buildInputDecoration(
                hintText: 'e.g., The future of AI and startups',
                prefixIcon: Icons.title,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Description
            _buildSectionLabel('Description', required: true),
            const SizedBox(height: AppConstants.spacingSm),
            TextFormField(
              controller: _descriptionController,
              decoration: _buildInputDecoration(
                hintText: 'Tell people what your event is about...',
                prefixIcon: Icons.description,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Location
            _buildSectionLabel('Location', required: true),
            const SizedBox(height: AppConstants.spacingSm),
            TextFormField(
              controller: _locationController,
              decoration: _buildInputDecoration(
                hintText: 'e.g., San Francisco, CA',
                prefixIcon: Icons.location_on,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Location is required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Date & Time (Only for Events, not Communities)
            if (_isEvent) ...[
              _buildSectionLabel('Date & Time', required: true),
              const SizedBox(height: AppConstants.spacingSm),
              InkWell(
                onTap: _selectDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} at ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
            ],

            // Images
            _buildSectionLabel('Images'),
            const SizedBox(height: AppConstants.spacingSm),
            if (_selectedPhotos.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedPhotos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.image, size: 40),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
            ],
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(_selectedPhotos.isEmpty ? 'Add Images' : 'Add More Images'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // Videos
            _buildSectionLabel('Videos'),
            const SizedBox(height: AppConstants.spacingSm),
            if (_selectedVideos.isNotEmpty) ...[
              Column(
                children: _selectedVideos.asMap().entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.videocam, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Video ${entry.key + 1}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => _removeVideo(entry.key),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingSm),
            ],
            OutlinedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_library),
              label: Text(_selectedVideos.isEmpty ? 'Add Video' : 'Add Another Video'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),

            // PDF Upload (Only for Events, not Communities)
            if (_isEvent) ...[
              _buildSectionLabel('Event Details PDF (Optional)'),
              const SizedBox(height: AppConstants.spacingSm),
              
              if (_selectedPdfName != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedPdfName!,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedPdfBase64 = null;
                            _selectedPdfName = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
              ],
              
              OutlinedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.upload_file),
                label: Text(_selectedPdfName == null ? 'Upload PDF' : 'Replace PDF'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'Upload a PDF with event details for better AI-powered recommendations',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
            ],

            // Tags
            _buildSectionLabel('Tags'),
            const SizedBox(height: AppConstants.spacingSm),
            TextFormField(
              controller: _tagsController,
              decoration: _buildInputDecoration(
                hintText: 'e.g., tech, ai, conference (comma-separated)',
                prefixIcon: Icons.label,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: AppTheme.primaryColor),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
