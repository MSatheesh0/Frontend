# Networking Module

## Overview
QR code profiles, network codes, and scanning functionality for instant networking.

## Features
- ✅ Custom QR profile generation
- ✅ Network code creation for groups
- ✅ QR code scanning
- ✅ Instant connection requests
- ✅ Context-aware profiles
- ✅ Multiple QR profiles

## Files

### Models
- `qr_profile.dart` - QR profile model
- `network_code.dart` - Network code model

### Screens
- `create_qr_profile_screen.dart` - Create custom QR profiles
- `create_network_code_screen.dart` - Create network codes

### Widgets
- `qr_card.dart` - QR code display card
- `qr_scanner_view.dart` - QR scanner widget
- `qr_profile_selector_sheet.dart` - QR profile selector
- `network_code_card.dart` - Network code card
- `network_code_selector_sheet.dart` - Network code selector
- `networking_mode_view.dart` - Networking interface
- `networking_mode_view_new.dart` - Updated networking interface
- `scan_result_bottom_sheet.dart` - Scan result display

## Usage

```dart
import 'package:goal_networking_app/modules/networking/networking.dart';
```

## Dependencies
- Core (theme, config)
- Profile module (for profile data)
- Connections module (for connection requests)
- QR Code Scanner package

## QR Profile Types
- Professional networking
- Event-specific
- Fundraising pitch
- Hiring
- Custom contexts

## Network Codes
Create codes for group networking sessions, events, or workshops with time-limited access.

## Testing
Use QR scanner to scan another user's QR code or network code to test connection flow.
