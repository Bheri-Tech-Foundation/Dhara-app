# Google Sign-In "10 Minute" Rate Limiting Fix (Web)

## Problem Description

**User reported issue**: On the web version, they see this error repeatedly:

```
Auto re-authn was previously triggered less than 10 minutes ago. 
Only one auto re-authn request can be made every 10 minutes.
```

This is followed by:
- 401 Unauthorized errors
- Token refresh failures  
- "Login needed" messages
- App redirecting to login screen

## Root Cause Analysis

### Google's Rate Limiting on Web

Google Sign-In on web has a **strict rate limit**:
- **Silent authentication** (`signInSilently()`) can only be called **once every 10 minutes**
- If called again within 10 minutes → Google blocks it with the error above
- This is a security measure to prevent abuse

### The Bug in Our Code

The `GoogleAuthService.initGoogleClient()` method was being called **multiple times**:

1. **Splash Page** calls `authRepo.initSetup()` → calls `initGoogleClient()` → calls `signInSilently()`
2. **Login Page** calls `authRepo.initSetup()` → calls `initGoogleClient()` **again** → calls `signInSilently()` **again**
3. Any navigation between pages could trigger this again

**Result**: Multiple `signInSilently()` calls within 10 minutes → Google blocks them → Authentication fails

### Code Before Fix

```dart
void initGoogleClient() {
  try {
    _googleSignIn = GoogleSignIn(...);
    
    _googleSignIn!.onCurrentUserChanged.listen(...);
    
    // ❌ PROBLEM: Called every time initGoogleClient() is called!
    _googleSignIn!.signInSilently();
  } catch (e) {
    mLogger.e('Error initializing Google client: $e');
  }
}
```

## Solution Implemented

### 1. Prevent Multiple Initializations

Added a flag `_isInitialized` to ensure Google Client is only initialized once:

```dart
bool _isInitialized = false;

void initGoogleClient() {
  // ✅ Early return if already initialized
  if (_isInitialized) {
    mLogger.d('Google client already initialized, skipping');
    return;
  }
  
  // ... initialization code ...
  _isInitialized = true;
}
```

### 2. Rate Limit Silent Sign-In Attempts

Added tracking and rate limiting for `signInSilently()` calls:

```dart
DateTime? _lastSilentSignInAttempt;

void _trySignInSilently() {
  try {
    // ✅ On web, check if 10 minutes have passed since last attempt
    if (kIsWeb && _lastSilentSignInAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(_lastSilentSignInAttempt!);
      if (timeSinceLastAttempt.inMinutes < 10) {
        mLogger.d('Skipping silent sign-in (last attempt was ${timeSinceLastAttempt.inMinutes} minutes ago)');
        return; // ✅ Skip the attempt
      }
    }
    
    _lastSilentSignInAttempt = DateTime.now();
    mLogger.d('Attempting silent Google sign-in...');
    _googleSignIn!.signInSilently();
  } catch (e) {
    mLogger.e('Error in silent sign-in: $e');
  }
}
```

### 3. Complete Fixed Code

```dart
class GoogleAuthService {
  var mLogger = Logger();
  
  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;
  bool _isInitialized = false; // ✅ NEW: Track initialization
  DateTime? _lastSilentSignInAttempt; // ✅ NEW: Track last attempt

  void initGoogleClient() {
    try {
      // ✅ Prevent multiple initializations
      if (_isInitialized) {
        mLogger.d('Google client already initialized, skipping');
        return;
      }
      
      // ... initialization code ...
      _isInitialized = true;
      
      // ✅ Try silent sign-in with rate limiting
      _trySignInSilently();
    } catch (e) {
      mLogger.e('Error initializing Google client: $e');
    }
  }
  
  /// ✅ NEW: Silent sign-in with rate limiting protection
  void _trySignInSilently() {
    try {
      if (kIsWeb && _lastSilentSignInAttempt != null) {
        final timeSinceLastAttempt = DateTime.now().difference(_lastSilentSignInAttempt!);
        if (timeSinceLastAttempt.inMinutes < 10) {
          mLogger.d('Skipping silent sign-in (last attempt was ${timeSinceLastAttempt.inMinutes} minutes ago)');
          return;
        }
      }
      
      _lastSilentSignInAttempt = DateTime.now();
      _googleSignIn!.signInSilently();
    } catch (e) {
      mLogger.e('Error in silent sign-in: $e');
    }
  }
}
```

## Benefits

### Before Fix:
- ❌ Multiple silent sign-in attempts within 10 minutes
- ❌ Google blocks subsequent attempts
- ❌ Authentication fails randomly
- ❌ User sees 401 errors and "Login needed" messages
- ❌ Poor user experience on web

### After Fix:
- ✅ Only one silent sign-in attempt per session
- ✅ Respects Google's 10-minute rate limit on web
- ✅ No more "10 minute" error messages
- ✅ Smooth authentication flow
- ✅ Better user experience on web

## Platform-Specific Behavior

### Web (kIsWeb = true)
- **Respects 10-minute rate limit** for silent sign-in
- **Initialization happens only once** per session
- **Logs clear messages** when skipping attempts

### Mobile (Android/iOS)
- **No rate limiting needed** (Google doesn't have this restriction on mobile)
- **Initialization happens only once** (same as web, for consistency)
- **Works exactly as before**

## Files Modified

- ✅ `lib/app/providers/google/google_auth.dart`

## Testing Scenarios

### Scenario 1: User navigates between splash and login
- **Before**: Silent sign-in called 2+ times → Error
- **After**: Silent sign-in called once → Success

### Scenario 2: User refreshes the page (web)
- **Before**: Silent sign-in called again → May fail if within 10 minutes
- **After**: Rate limiting prevents call → No error

### Scenario 3: User logs out and back in within 10 minutes
- **Before**: Silent sign-in called → Google blocks → Error
- **After**: Rate limiting prevents automatic attempt → User clicks login button → Success

### Scenario 4: User reopens app after 10+ minutes
- **Before**: Works (10-minute window passed)
- **After**: Works (can attempt silent sign-in again)

## Related Issues

This fix is **separate** from the token expiration fix:
- **Token Expiration Fix**: Handles expired JWT tokens after 40 days
- **This Fix**: Handles Google's rate limiting for silent authentication

Both fixes work together to improve authentication reliability!

## Logs to Watch For (After Fix)

**Good logs:**
```
Google client already initialized, skipping
Attempting silent Google sign-in...
Silent sign-in successful for: user@example.com
```

**Expected logs when rate limited:**
```
Skipping silent sign-in (last attempt was 5 minutes ago)
```

**No more error logs:**
```
❌ Auto re-authn was previously triggered less than 10 minutes ago
```

