# Networking Service - Usage Guide

## Overview

The `NetworkingService` handles all networking functionality including network codes, QR profiles, connections, and connection requests with automatic unique ID generation.

---

## Features

### ✅ Network Code Management
- Create network codes with **unique IDs**
- **Edit network codes** (toggle auto-connect on/off)
- Auto-connect feature for instant connections
- Manual approval mode for connection requests

### ✅ QR Code Management
- Create QR profiles with unique IDs
- Scan QR codes to connect instantly
- Track scan counts

### ✅ Connection Management
- Auto-connect or manual approval based on settings
- Connection requests with approve/reject
- View all connections and pending requests

---

## Usage Examples

### 1. Create Network Code

```dart
import 'package:goal_networking_app/services/networking_service.dart';

final networkingService = NetworkingService();

// Create with auto-connect enabled
final networkCode = await networkingService.createNetworkCode(
  userId: currentUser.id,
  code: 'STARTUP2025',  // User-provided code
  name: 'Startup Meetup 2025',
  description: 'Networking for startup founders',
  autoConnect: true,    // ✅ Instant connections
  expiresAt: DateTime.now().add(Duration(days: 30)),
  maxConnections: 100,
  tags: ['startup', 'founders'],
);

print('Created: ${networkCode['code']}');
print('ID: ${networkCode['id']}');  // Unique ID like nc_1732789145679
```

### 2. Edit Network Code (Toggle Auto-Connect)

```dart
// Toggle auto-connect from true to false
await networkingService.updateNetworkCode(
  networkCodeId: 'nc_1732789012345',
  autoConnect: false,  // Now requires approval
);

// Or toggle back to true
await networkingService.updateNetworkCode(
  networkCodeId: 'nc_1732789012345',
  autoConnect: true,  // Back to instant connections
);

// Update other fields
await networkingService.updateNetworkCode(
  networkCodeId: 'nc_1732789012345',
  name: 'Updated Event Name',
  expiresAt: DateTime.now().add(Duration(days: 60)),
  maxConnections: 200,
);
```

### 3. Join Network Code (Auto-Connect TRUE)

```dart
// User enters network code
final result = await networkingService.joinNetworkCode(
  userId: currentUser.id,
  code: 'TECH2024',  // Has autoConnect: true
);

if (result['autoConnect'] == true) {
  print('✅ Auto-connected to ${result['newConnections']} members!');
  // Connections created immediately in database
}
```

### 4. Join Network Code (Auto-Connect FALSE)

```dart
// User enters network code
final result = await networkingService.joinNetworkCode(
  userId: currentUser.id,
  code: 'INVEST2024',  // Has autoConnect: false
);

if (result['autoConnect'] == false) {
  print('📨 Sent ${result['newRequests']} connection requests');
  // Requests created, waiting for approval
}
```

### 5. Scan QR Code

```dart
// User scans QR code
final result = await networkingService.scanQRCode(
  scannerId: currentUser.id,
  qrProfileId: 'qr_1732789056789',  // ID from scanned QR
);

if (result['success']) {
  print('✅ Connected via QR scan!');
  final connection = result['connection'];
  final qrProfile = result['qrProfile'];
  
  // Connection stored in database immediately
  print('Connected to: ${qrProfile['userId']}');
}
```

### 6. Create QR Profile

```dart
final qrProfile = await networkingService.createQRProfile(
  userId: currentUser.id,
  title: 'Fundraising Profile',
  description: 'Looking to raise Series A',
  context: 'fundraising',
  customMessage: 'We\'re raising $3M. Let\'s connect!',
);

print('QR ID: ${qrProfile['id']}');  // Use this ID in QR code
```

### 7. View Pending Connection Requests

```dart
final requests = await networkingService.getPendingRequests(currentUser.id);

for (final request in requests) {
  print('Request from: ${request['fromUserId']}');
  print('Message: ${request['message']}');
  print('Source: ${request['source']}');  // 'qr_scan' or 'network_code'
}
```

### 8. Approve Connection Request

```dart
await networkingService.approveRequest('req_1732789156789');
print('✅ Connection approved and created!');
```

### 9. Reject Connection Request

```dart
await networkingService.rejectRequest(
  'req_1732789156789',
  reason: 'Not looking for connections at this time',
);
print('❌ Connection rejected');
```

### 10. View User's Connections

```dart
final connections = await networkingService.getUserConnections(currentUser.id);

for (final conn in connections) {
  print('Connected to: ${conn['userId1'] == currentUser.id ? conn['userId2'] : conn['userId1']}');
  print('Source: ${conn['connectionSource']}');  // 'qr_scan' or 'network_code'
  print('Date: ${conn['connectedAt']}');
}
```

### 11. Get User's Network Codes

```dart
final myCodes = await networkingService.getUserNetworkCodes(currentUser.id);

for (final code in myCodes) {
  print('Code: ${code['code']}');
  print('Auto-connect: ${code['autoConnect']}');
  print('Connections: ${code['currentConnections']}/${code['maxConnections']}');
}
```

---

## How It Works

### Unique ID Generation

```dart
// Network codes: nc_<incrementing_number>
// QR profiles: qr_<incrementing_number>
// Connections: conn_<incrementing_number>
// Requests: req_<incrementing_number>

// IDs are generated from metadata counters
metadata['nextNetworkCodeId']  // 1732789145679
metadata['nextQrProfileId']     // 1732789190124
metadata['nextConnectionId']    // 1732789245679
metadata['nextRequestId']       // 1732789289013
```

### Auto-Connect Logic

**When `autoConnect: true`:**
1. User joins network code
2. Service finds all existing members
3. Creates connections immediately
4. No approval needed
5. Stores in `connections` collection

**When `autoConnect: false`:**
1. User joins network code
2. Service finds all existing members
3. Creates connection requests
4. Members see requests
5. Must approve/reject
6. If approved → moves to `connections`

### QR Scan Logic

1. User scans QR code
2. Gets QR profile ID from code
3. Finds target user from QR profile
4. Creates connection immediately
5. Updates scan count
6. Stores in `connections` collection

---

## UI Integration

### Create Network Code Screen

```dart
// In create_network_code_screen.dart

bool autoConnect = true;  // Toggle state

ElevatedButton(
  onPressed: () async {
    try {
      final networkCode = await NetworkingService().createNetworkCode(
        userId: currentUser.id,
        code: codeController.text,
        name: nameController.text,
        description: descriptionController.text,
        autoConnect: autoConnect,  // Use toggle value
        expiresAt: selectedDate,
        maxConnections: 100,
        tags: selectedTags,
      );
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network code created: ${networkCode['code']}')),
      );
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  },
  child: Text('Create Network Code'),
)
```

### Edit Network Code (Toggle Auto-Connect)

```dart
// In network code details screen

SwitchListTile(
  title: Text('Auto-Connect'),
  subtitle: Text(
    autoConnect 
      ? 'Members connect instantly' 
      : 'Members must approve requests'
  ),
  value: autoConnect,
  onChanged: (value) async {
    try {
      await NetworkingService().updateNetworkCode(
        networkCodeId: networkCode['id'],
        autoConnect: value,
      );
      
      setState(() {
        autoConnect = value;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auto-connect ${value ? 'enabled' : 'disabled'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  },
)
```

### QR Scanner

```dart
// In QR scanner screen

void onQRScanned(String qrData) async {
  try {
    // qrData should be the QR profile ID
    final result = await NetworkingService().scanQRCode(
      scannerId: currentUser.id,
      qrProfileId: qrData,
    );
    
    if (result['success']) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('✅ Connected!'),
          content: Text('You are now connected'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

---

## Error Handling

The service throws exceptions for:
- Duplicate network codes
- Expired network codes
- Max connections reached
- QR profile not found
- Already connected users
- Invalid requests

Always wrap calls in try-catch:

```dart
try {
  final result = await networkingService.joinNetworkCode(...);
} catch (e) {
  print('Error: $e');
  // Show user-friendly message
}
```

---

## Testing

**Test Accounts:**
- demo@waytree.com / demo123
- test@example.com / test123
- mentor@example.com / mentor123
- founder@startup.com / founder123

**Test Network Codes:**
- TECH2024 (auto-connect: true)
- INVEST2024 (auto-connect: false)
- STARTUP2024 (auto-connect: true)
- HIRING2024 (auto-connect: false)

**Test QR Profiles:**
- qr_1732789056789 (user_1, fundraising)
- qr_1732789067890 (user_1, professional)
- qr_1732789078901 (user_2, investing)

---

## Next Steps

1. **Integrate into UI:** Add the service to your screens
2. **Add to Provider:** Make it available app-wide
3. **Test flows:** Create, edit, join, scan, approve
4. **Add notifications:** Alert users of new requests
5. **Add backend:** Replace in-memory storage with API calls

---

**Created:** November 28, 2024  
**Service File:** `lib/services/networking_service.dart`
