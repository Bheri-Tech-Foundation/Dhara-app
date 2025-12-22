# Developer Mode Implementation Summary

## User Requirements

✅ **Only one feature**: Replace production domain `project.iith.ac.in` with custom domain, keeping `/bheri` path
✅ **No other developer features**: Removed AI model selection, API testing, unified tab toggle
✅ **Simple activation**: Long press on mobile, right-click on web/desktop
✅ **No password required**: Directly opens settings modal
✅ **Works on all platforms**: Android, Web, Desktop

**Important**: The `/bheri` path is automatically appended to the custom domain
- Input: `http://192.168.167.88:8000`
- Result: `http://192.168.167.88:8000/bheri`

## Changes Made

### 1. Simplified Developer Mode Service
**File**: `lib/app/data/services/developer_mode_service.dart`

**Changes**:
- Removed authentication/password requirement
- Removed AI model preferences
- Removed UI feature toggles
- Removed API testing functionality
- **Kept only**: Custom base URL management
- Simplified API: `enable(url)`, `disable()`, `getEffectiveApiUrl()`

**Key Methods**:
```dart
// Enable developer mode with custom domain (path will be appended automatically)
await DeveloperModeService.instance.enable("http://192.168.167.88:8000");
// This results in: "http://192.168.167.88:8000/bheri"

// Disable and return to production
await DeveloperModeService.instance.disable();

// Get current effective URL (custom + /bheri or production)
String url = DeveloperModeService.instance.getEffectiveApiUrl();
// Returns: "http://192.168.167.88:8000/bheri" or "https://project.iith.ac.in/bheri"
```

### 2. Simplified Settings Modal
**File**: `lib/app/ui/widgets/developer_settings_modal.dart`

**Changes**:
- Complete rewrite with minimal UI
- Only shows:
  - Current status (enabled/disabled)
  - Current effective URL
  - Custom URL input field
  - Enable/Disable buttons
- Added URL validation
- User-friendly error messages

### 3. Updated Dashboard Activation
**File**: `lib/app/ui/pages/dashboard/dashboard_page.dart`

**Changes**:
- Removed password dialog requirement
- Added `onSecondaryTap` for right-click support (web/desktop)
- Kept `onLongPress` for mobile support
- Directly opens settings modal when activated

### 4. Updated Core Module
**File**: `lib/app/core_module.dart`

**Changes**:
- Added `_getApiUrl()` helper method
- All API points now use `_getApiUrl()` instead of `F.apiUrl`
- Affects:
  - `AuthApiPoint`
  - `DictionaryApiPoint`
  - `VerseApiPoint`
  - `CitationApiPoint`
  - `ShareApiPoint`
  - `PrashnaApiPointSimple`
  - `VerseApiRepo` (uses baseUrl parameter)

### 5. Updated Auth Interceptor
**File**: `lib/app/data/remote/api/interceptors/auth_interceptor.dart`

**Changes**:
- Token refresh endpoint now uses developer mode URL
- Added import for `DeveloperModeService`
- Uses `DeveloperModeService.instance.getEffectiveApiUrl()` for refresh token calls

### 6. Updated API URL Provider
**File**: `lib/app/data/services/api_url_provider_service.dart`

**Changes**:
- Simplified `_updateApiUrl()` method
- Removed authentication state listener
- Now directly uses `getEffectiveApiUrl()`

### 7. Updated Unified Search API
**File**: `lib/app/data/remote/api/parts/unified/api_point_simple.dart`

**Changes**:
- Simplified `_baseUrl` getter
- Uses `DeveloperModeService.instance.getEffectiveApiUrl()`

### 8. Deleted Unused Files
**Removed**:
- `lib/app/ui/widgets/developer_password_dialog.dart` ❌
- `lib/app/ui/widgets/developer_auth_dialog.dart` ❌

## How It Works

### URL Replacement Flow

1. **App Initialization**:
   - `DeveloperModeService.instance.initialize()` loads saved settings
   - If developer mode was enabled, loads custom URL
   - Otherwise uses production URL

2. **API Point Creation** (in `CoreModule`):
   ```dart
   String _getApiUrl() {
     return DeveloperModeService.instance.getEffectiveApiUrl();
   }
   
   i.addSingleton(() => AuthApiPoint(i<Dio>(), baseUrl: _getApiUrl()));
   ```

3. **Runtime URL Selection**:
   ```dart
   String getEffectiveApiUrl() {
     if (_isEnabled && _customDomain.isNotEmpty) {
       return '$_customDomain$apiPath';  // e.g., "http://192.168.167.88:8000/bheri"
     }
     return defaultProductionUrl;  // "https://project.iith.ac.in/bheri"
   }
   ```

4. **All API Calls Use This URL**:
   - Auth: `${baseUrl}/api/glogin/` → `http://192.168.167.88:8000/bheri/api/glogin/`
   - Dictionary: `${baseUrl}/dict/v1/get_defs/` → `http://192.168.167.88:8000/bheri/dict/v1/get_defs/`
   - Verse: `${baseUrl}/verse/v1/search/` → `http://192.168.167.88:8000/bheri/verse/v1/search/`
   - etc.
   
   **Note**: The `/bheri` path is automatically included!

### Activation Flow

**Mobile (Android)**:
1. User long-presses on "Dhārā" logo
2. `_handleDeveloperModeActivation()` called
3. Settings modal opens directly (no password)
4. User enters custom URL and clicks "Enable"
5. Settings saved to SharedPreferences
6. All subsequent API calls use custom URL

**Web/Desktop**:
1. User right-clicks on "Dhārā" logo
2. Same flow as mobile

## Testing Checklist

### Basic Functionality
- [ ] Long press on mobile opens developer settings
- [ ] Right-click on web/desktop opens developer settings
- [ ] Custom URL can be entered and enabled
- [ ] Current status shows correctly
- [ ] Disable button returns to production URL
- [ ] Settings persist after app restart

### URL Validation
- [ ] Empty URL shows error
- [ ] URL without http:// or https:// shows error
- [ ] Valid URL is accepted

### API Integration
- [ ] Auth endpoints use custom URL when enabled
- [ ] Dictionary endpoints use custom URL when enabled
- [ ] Verse endpoints use custom URL when enabled
- [ ] Citation endpoints use custom URL when enabled
- [ ] Prashna (AI) endpoints use custom URL when enabled
- [ ] Unified search uses custom URL when enabled
- [ ] Token refresh uses custom URL when enabled

### Platform Coverage
- [ ] Android app works correctly
- [ ] Web app works correctly
- [ ] Desktop app works correctly (if applicable)

## Documentation

Created comprehensive guide: **`DEVELOPER_MODE_GUIDE.md`**

Includes:
- Overview and purpose
- Activation instructions for mobile and web/desktop
- Usage guide with examples
- Network setup for local development
- Troubleshooting section
- Technical implementation details

## No Breaking Changes

✅ All changes are **backward compatible**
✅ Production behavior unchanged (uses same URL as before)
✅ No changes to existing API endpoints
✅ No changes to authentication flow
✅ Settings are optional and disabled by default

## Example Usage for Your Team

```bash
# 1. Start local backend server
cd backend
python manage.py runserver 0.0.0.0:8000

# 2. Find your IP address
# Windows: ipconfig
# Mac/Linux: ifconfig
# Example output: 192.168.167.88

# 3. In Dhara app:
#    - Long press (mobile) or right-click (web) on Dhārā logo
#    - Enter: http://192.168.167.88:8000
#    - Click "Enable"
#    
# 4. All API calls now go to your local server!
#
# 5. When done, click "Disable" to return to production
```

## Summary

✨ **Developer mode is now ultra-simple**:
- One feature: Custom base URL
- One activation: Long press or right-click on logo
- One purpose: Point to local development server
- Zero complexity: No passwords, no extra features

Perfect for your team to develop and test API changes locally! 🚀

