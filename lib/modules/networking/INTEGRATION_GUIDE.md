# Networking Module - File Organization

## ✅ Module Structure Created

All networking-related files are now organized in the `lib/modules/networking/` directory:

```
lib/modules/networking/
├── models/
│   ├── network_code.dart          # Network code model
│   └── qr_profile.dart             # QR profile model
├── screens/
│   ├── create_network_code_screen.dart    # Create network codes
│   └── create_qr_profile_screen.dart      # Create QR profiles
├── services/
│   └── networking_service.dart     # All networking logic
├── widgets/
│   ├── qr_card.dart
│   ├── qr_scanner_view.dart
│   ├── network_code_card.dart
│   └── ... (other networking widgets)
├── networking.dart                 # Barrel export file
└── README.md                       # Module documentation
```

## 🔧 Next Steps

### 1. Update Import Paths

Change all imports from:
```dart
import '../services/networking_service.dart';
import '../models/network_code.dart';
```

To:
```dart
import 'package:goal_networking_app/modules/networking/networking.dart';
```

### 2. Integrate NetworkingService with UI

The dropdown is showing old networks because the UI is still using `AppState._networkCodes` instead of `NetworkingService`.

**Update the network code dropdown to use the service:**

```dart
// In the widget that shows the dropdown
FutureBuilder<List<Map<String, dynamic>>>(
  future: NetworkingService().getUserNetworkCodes(currentUser.id),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }
    
    final networkCodes = snapshot.data!;
    
    if (networkCodes.isEmpty) {
      return Text('No network codes yet. Create one!');
    }
    
    return DropdownButton<String>(
      items: networkCodes.map((code) {
        return DropdownMenuItem(
          value: code['id'],
          child: Text('${code['name']} (${code['code']})'),
        );
      }).toList(),
      onChanged: (value) {
        // Handle selection
      },
    );
  },
)
```

### 3. Files to Update

Update these files to use the new module structure:

1. **`lib/widgets/networking_mode_view.dart`**
   - Import from `modules/networking/networking.dart`
   - Use `NetworkingService().getUserNetworkCodes()` instead of `AppState.networkCodes`

2. **`lib/screens/create_network_code_screen.dart`**
   - Import `NetworkingService`
   - Call `NetworkingService().createNetworkCode()` instead of `AppState.addNetworkCode()`

3. **`lib/screens/main_screen.dart`**
   - Update imports to use modular structure

## 📝 Example: Updated Create Network Code Screen

```dart
import 'package:flutter/material.dart';
import 'package:goal_networking_app/modules/networking/services/networking_service.dart';

class CreateNetworkCodeScreen extends StatefulWidget {
  // ... existing code
  
  void _generateNetworkCode() async {
    if (_formKey.currentState!.validate()) {
      try {
        final networkCode = await NetworkingService().createNetworkCode(
          userId: currentUser.id,
          code: _codeIdController.text.toUpperCase(),
          name: _nameController.text,
          description: _keywordsController.text,
          autoConnect: _autoConnect,
          expiresAt: DateTime.now().add(Duration(days: 30)),
          tags: _selectedTags.toList(),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network Code created: ${networkCode['code']}')),
        );
        
        Navigator.pop(context);
      } catch (e) {
        // Shows "already exists" error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

## 🎯 Benefits of Module Organization

✅ **Easy to Find** - All networking code in one place  
✅ **Easy to Edit** - No need to search across multiple directories  
✅ **Clear Separation** - Networking logic separate from other features  
✅ **Team Collaboration** - One developer can own the networking module  
✅ **Reusable** - Import the entire module with one line  

## 🚀 Usage

Import the entire networking module:
```dart
import 'package:goal_networking_app/modules/networking/networking.dart';
```

Now you have access to:
- `NetworkingService()` - All networking operations
- `NetworkCode` - Network code model
- `QRProfile` - QR profile model
- All networking screens and widgets
