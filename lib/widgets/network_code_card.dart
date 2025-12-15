import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/network_code.dart';
import '../utils/theme.dart';

class NetworkCodeCard extends StatefulWidget {
  final NetworkCode code;
  final VoidCallback onTapDropdown;

  const NetworkCodeCard({
    super.key,
    required this.code,
    required this.onTapDropdown,
  });

  @override
  State<NetworkCodeCard> createState() => _NetworkCodeCardState();
}

class _NetworkCodeCardState extends State<NetworkCodeCard> {
  bool _isWallpaperEnabled = false;
  bool _isLoadingWallpaper = false;

  static const platform = MethodChannel('com.waytree.app/wallpaper');

  void _copyCodeId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.code.codeId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${widget.code.codeId} to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleWallpaper(bool value) async {
    setState(() {
      _isLoadingWallpaper = true;
    });

    try {
      if (value) {
        // Set wallpaper
        // Use higher resolution for wallpaper
        final url = 'https://quickchart.io/qr?text=${Uri.encodeComponent(widget.code.codeId)}&size=1080';
        
        final result = await platform.invokeMethod('setWallpaper', {
          'url': url,
          'networkName': widget.code.name,
          'codeId': widget.code.codeId,
        });

        if (result == true) {
          setState(() {
            _isWallpaperEnabled = true;
          });
        }
      } else {
        // Disable wallpaper
        setState(() {
          _isWallpaperEnabled = false;
        });
      }
    } on PlatformException catch (e) {
      // Silent error handling - just reset state
      print('Wallpaper error: ${e.message}');
      setState(() {
        _isWallpaperEnabled = false;
      });
    } catch (e) {
      // Silent error handling - just reset state
      print('Wallpaper error: $e');
      setState(() {
        _isWallpaperEnabled = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWallpaper = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Dropdown selector + Wallpaper Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dropdown selector
              InkWell(
                onTap: widget.onTapDropdown,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMd,
                    vertical: AppConstants.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.code.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          
          // Wallpaper Toggle Section
          Column(
            children: [
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                 decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Icon(
                       Icons.lock_clock, // Lock screen icon
                       size: 20, 
                       color: _isWallpaperEnabled ? AppTheme.primaryColor : Colors.grey[600]
                     ),
                     const SizedBox(width: 8),
                     SizedBox(
                       height: 28,
                       child: _isLoadingWallpaper 
                        ? const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Switch(
                           value: _isWallpaperEnabled,
                           onChanged: _toggleWallpaper,
                           activeColor: AppTheme.primaryColor,
                           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                         ),
                     ),
                   ],
                 ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enable to show in lock screen wallpaper',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXl),

          // Network Code visualization (QR code from QuickChart)
          Stack(
            children: [
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  child: Image.network(
                    'https://quickchart.io/qr?text=${Uri.encodeComponent(widget.code.codeId)}&size=220',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_2,
                              size: 120,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: AppConstants.spacingSm),
                            Text(
                              'Network Code',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (!widget.code.isActive)
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.block, color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'INACTIVE',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXl),

          // "Scan and connect" text
          const Text(
            'Scan and connect',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Code ID with copy button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Code ID: ',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.code.codeId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                InkWell(
                  onTap: () => _copyCodeId(context),
                  child: Icon(
                    Icons.copy,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Keywords/description
          if (widget.code.keywords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
              ),
              child: Wrap(
                spacing: AppConstants.spacingXs,
                runSpacing: AppConstants.spacingXs,
                alignment: WrapAlignment.center,
                children: widget.code.keywords.take(5).map<Widget>((keyword) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSm,
                      vertical: AppConstants.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Text(
                      keyword,
                      style: const TextStyle(
                        color: AppTheme.secondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
