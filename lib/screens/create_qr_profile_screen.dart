import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qr_profile.dart';
import '../services/app_state.dart';
import '../utils/theme.dart';

class CreateQrProfileScreen extends StatefulWidget {
  const CreateQrProfileScreen({super.key});

  @override
  State<CreateQrProfileScreen> createState() => _CreateQrProfileScreenState();
}

class _CreateQrProfileScreenState extends State<CreateQrProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qrCodeIdController = TextEditingController();
  final _keywordsController = TextEditingController();
  bool _autoConnect = false;

  final List<String> _suggestedTags = [
    'Healthcare Technology',
    'AI service',
    'Fundraising',
    'Hospital Partnerships',
    'Startup',
    'Innovation',
    'Networking',
    'Investment',
  ];

  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _nameController.dispose();
    _qrCodeIdController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  void _generateQrCode() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);

      // Parse keywords
      final keywords = _keywordsController.text
          .split(',')
          .map((k) => k.trim())
          .where((k) => k.isNotEmpty)
          .toList();

      // Add selected tags to keywords
      keywords.addAll(_selectedTags);

      final newProfile = QrProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        qrCodeId: _qrCodeIdController.text,
        description: keywords.take(3).join(', '),
        keywords: keywords,
        autoConnect: _autoConnect,
      );

      appState.addQrProfile(newProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR profile created successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                'Add your QR code for sharable profile',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXl),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name of the QR code',
                  hintText: 'Ex: johnQR',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // QR code ID field
              TextFormField(
                controller: _qrCodeIdController,
                decoration: InputDecoration(
                  labelText: 'QR code ID',
                  hintText: 'Ex: john.ai',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a QR code ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Auto connect toggle
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Activate the auto connect',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXs),
                          Text(
                            'Automatically connect when QR is scanned',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _autoConnect,
                      onChanged: (value) {
                        setState(() {
                          _autoConnect = value;
                        });
                      },
                      activeThumbColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Keywords field
              TextFormField(
                controller: _keywordsController,
                decoration: InputDecoration(
                  labelText: 'Keywords',
                  hintText: 'Ex: Healthcare, Technology',
                  helperText: 'Separate multiple keywords with commas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Suggested tags
              Text(
                'Suggested Tags',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Wrap(
                spacing: AppConstants.spacingSm,
                runSpacing: AppConstants.spacingSm,
                children: _suggestedTags.map<Widget>((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingXl * 2),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: ElevatedButton(
            onPressed: _generateQrCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
            ),
            child: const Text(
              'Generate QR code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
