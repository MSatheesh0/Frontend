# Database Storage - Important Information

## ⚠️ Current Limitation

**Flutter Web Cannot Write to Assets Folder**

The `assets/data/db.json` file is **read-only** in Flutter web apps. This means:
- ✅ Can READ from `assets/data/db.json`
- ❌ Cannot WRITE to `assets/data/db.json` (web only)
- ✅ Can write on Desktop/Mobile apps

## Current Solution

The `NetworkingService` uses **in-memory storage** that:
- ✅ Persists across hot reloads (using `static` variable)
- ✅ Prevents duplicate code IDs
- ✅ Allows editing network codes
- ❌ Data is lost on full app restart

## How It Works Now

1. **First Load:** Reads from `assets/data/db.json`
2. **Create/Edit:** Updates in-memory database
3. **Hot Reload (`r`):** Data persists ✅
4. **Hot Restart (`R`):** Data resets to `db.json` ❌

## Production Solution

In production, replace file writing with API calls:

```dart
Future<void> _saveDatabase() async {
  // Call your backend API
  final response = await http.post(
    Uri.parse('https://your-api.com/database'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(_database),
  );
  
  if (response.statusCode == 200) {
    print('💾 Database saved to server');
  }
}
```

## For Development (Desktop App)

If you want to test file writing:

1. **Run on Windows Desktop:**
   ```bash
   flutter run -d windows
   ```

2. **The file will be written** to `assets/data/db.json`

3. **Changes persist** even after restart

## Current Behavior

### ✅ What Works:
- Create network codes with unique IDs
- Duplicate checking (shows error if code exists)
- Edit network codes (toggle auto-connect, etc.)
- Data persists during hot reload

### ❌ What Doesn't Work (Web Only):
- Writing to `db.json` file
- Data persistence after full restart

## Recommendation

**For now (development):**
- Use in-memory storage
- Test with hot reload (`r`)
- Data resets on restart - that's OK for development

**For production:**
- Set up a backend API (Node.js, Firebase, etc.)
- Replace `_saveDatabase()` with API call
- Data persists permanently in database

## Testing

1. **Create a network code:**
   - Name: "Test"
   - Code: "TEST2024"
   - ✅ Creates successfully

2. **Hot Reload:**
   - Press `r`
   - ✅ Network code still there

3. **Try duplicate:**
   - Try "TEST2024" again
   - ✅ Shows error: "already exists"

4. **Full Restart:**
   - Press `R` or restart app
   - ❌ Data resets (expected for web)

This is normal for Flutter web development! 🎯
