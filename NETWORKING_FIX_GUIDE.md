# Networking Module Organization - Quick Guide

## Current Issue

The dropdown in network mode shows old/empty networks because:
1. The UI is using `AppState._networkCodes` (which we cleared)
2. The new `NetworkingService` is not integrated with the UI yet

## Solution

### Step 1: Move Files to Networking Module (Manual)

Move these files into `lib/modules/networking/`:

**Already in module from earlier:**
- ✅ `lib/modules/networking/models/` - network_code.dart, qr_profile.dart (already there)
- ✅ `lib/modules/networking/screens/` - create_network_code_screen.dart, create_qr_profile_screen.dart (already there)
- ✅ `lib/modules/networking/widgets/` - qr_card.dart, network_code_card.dart, etc. (already there)

**Need to add:**
- Move `lib/services/networking_service.dart` → `lib/modules/networking/services/networking_service.dart`

### Step 2: Update Networking Mode Widget

Find the file that shows the network code dropdown (likely `lib/widgets/networking_mode_view.dart` or similar) and update it:

**Before (using AppState):**
```dart
// Old code - shows empty list
final networkCodes = Provider.of<AppState>(context).networkCodes;

DropdownButton(
  items: networkCodes.map((code) {
    return DropdownMenuItem(
      value: code.id,
      child: Text(code.name),
    );
  }).toList(),
  // ...
)
```

**After (using NetworkingService):**
```dart
import 'package:goal_networking_app/services/networking_service.dart';
import 'package:goal_networking_app/services/auth_service.dart';

// In your widget:
FutureBuilder<List<Map<String, dynamic>>>(
  future: NetworkingService().getUserNetworkCodes(
    AuthService().currentUser?['id'] ?? 'user_1'
  ),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Column(
        children: [
          Text('No network codes yet'),
          ElevatedButton(
            onPressed: () {
              // Navigate to create network code screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateNetworkCodeScreen(),
                ),
              );
            },
            child: Text('Create Network Code'),
          ),
        ],
      );
    }
    
    final networkCodes = snapshot.data!;
    
    return DropdownButton<String>(
      value: selectedNetworkCodeId,
      items: networkCodes.map((code) {
        return DropdownMenuItem<String>(
          value: code['id'],
          child: Text('${code['name']} (${code['code']})'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedNetworkCodeId = value;
        });
      },
    );
  },
)
```

### Step 3: Update Create Network Code Screen

Update `lib/modules/networking/screens/create_network_code_screen.dart`:

**Replace the `_generateNetworkCode` method:**
```dart
import 'package:goal_networking_app/services/networking_service.dart';
import 'package:goal_networking_app/services/auth_service.dart';

void _generateNetworkCode() async {
  if (_formKey.currentState!.validate()) {
    try {
      // Get current user ID
      final userId = AuthService().currentUser?['id'] ?? 'user_1';
      
      // Create network code using NetworkingService
      final networkCode = await NetworkingService().createNetworkCode(
        userId: userId,
        code: _codeIdController.text.toUpperCase(),
        name: _nameController.text,
        description: _keywordsController.text,
        autoConnect: _autoConnect,
        expiresAt: DateTime.now().add(Duration(days: 30)),
        maxConnections: 100,
        tags: _selectedTags.toList(),
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Network Code created: ${networkCode['code']}'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true); // Return true to indicate success
      
    } catch (e) {
      if (!mounted) return;
      
      // Shows "already exists" error or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### Step 4: Test the Flow

1. **Login** with demo@waytree.com / demo123
2. **Go to Network Mode** - Should show "No network codes yet"
3. **Click Create** - Opens create network code screen
4. **Enter details:**
   - Name: "My First Network"
   - Code ID: "STARTUP2025"
   - Toggle auto-connect: ON
5. **Click Generate** - Creates network code
6. **Go back to Network Mode** - Should now show "My First Network (STARTUP2025)" in dropdown

### Step 5: Add Edit Functionality

To edit existing network codes, add this to the dropdown or network code list:

```dart
IconButton(
  icon: Icon(Icons.edit),
  onPressed: () async {
    // Show edit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Network Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Auto-Connect'),
              subtitle: Text(
                autoConnect 
                  ? 'Members connect instantly' 
                  : 'Members must approve'
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
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Auto-connect ${value ? 'enabled' : 'disabled'}'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  },
)
```

## Summary

**The dropdown shows old networks because:**
- UI is still using `AppState._networkCodes` (empty list)
- Need to switch to `NetworkingService().getUserNetworkCodes()`

**To fix:**
1. Update the dropdown widget to use `FutureBuilder` with `NetworkingService`
2. Update create screen to use `NetworkingService().createNetworkCode()`
3. Add edit functionality with `NetworkingService().updateNetworkCode()`

**Files to modify:**
- `lib/widgets/networking_mode_view.dart` (or wherever the dropdown is)
- `lib/modules/networking/screens/create_network_code_screen.dart`

All networking logic is now in `lib/services/networking_service.dart` - just need to connect it to the UI!
