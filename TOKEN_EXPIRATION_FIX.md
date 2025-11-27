# Token Expiration Fix - Login Issue After 40 Days

## Problem Description

**User reported issue**: When users try to login after being inactive for ~40 days, they get a "Login failed" message on their first attempt, but the second login attempt succeeds.

## Root Cause Analysis

### The Flow of the Bug:

1. **User opens app after 40 days** → `SplashPage` loads
2. **Splash checks authentication** (lines 87-106 in `splash_page.dart`):
   - ✅ Access token exists in secure storage
   - ✅ User data exists
   - → App considers user "authenticated" and navigates to `/Dhara/quicksearch`
3. **Problem**: The splash page **only checked if tokens exist**, NOT if they're valid or expired!
4. **First API call with expired token**:
   - `AuthInterceptor` adds the old (expired) access token to the request
   - Backend returns **401 Unauthorized**
   - `AuthInterceptor.onError` attempts to refresh the token
   - But the **refresh token is ALSO expired** (after ~40 days - typical JWT refresh token lifetime)
   - Refresh fails → User sees **"Login failed"**
5. **Second attempt works**: User manually logs in with Google, which generates fresh tokens

### Why Second Login Works:
The second attempt is a fresh Google OAuth login that generates brand new access and refresh tokens, bypassing the expired token issue entirely.

## Solution Implemented

### 1. Added Token Validation Method to `AuthAccountRepository`

**File**: `lib/app/domain/auth/auth_account_repo.dart`

Added `validateAndRefreshTokens()` method that:
- Checks if both access token and refresh token exist
- Proactively attempts to refresh the access token
- If refresh succeeds → Returns `true` (tokens are valid)
- If refresh fails (expired refresh token) → Clears all tokens and returns `false`

```dart
Future<bool> validateAndRefreshTokens() async {
  try {
    final accessToken = await mSecureStorage.getAccessToken();
    final refreshToken = await mSecureStorage.getRefreshToken();
    
    // No tokens = not authenticated
    if (accessToken == null || accessToken.isEmpty || 
        refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    
    // Try to refresh the access token to validate the refresh token
    final isRefreshSuccess = await _attemptTokenRefresh(refreshToken);
    
    if (!isRefreshSuccess) {
      // Refresh token is expired/invalid, clear all auth data
      await mSecureStorage.saveAccessToken(null);
      await mSecureStorage.saveRefreshToken(null);
      return false;
    }
    
    return true;
  } catch (e) {
    return false;
  }
}
```

### 2. Added Token Refresh API Method

**File**: `lib/app/data/remote/api/parts/auth/api.dart`

Added `refreshToken()` method to `AuthApiRepo` that:
- Uses Dio directly (not Retrofit) to call `/api/token/refresh/`
- Sends `{'refresh': refreshToken}` to backend
- Returns new access token if successful

```dart
Future<RefreshTokenResponse> refreshToken(Map<String, dynamic> request) async {
  try {
    final response = await dio.post(
      '/api/token/refresh/',
      data: request,
    );
    
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return RefreshTokenResponse(
        accessToken: data['access'] as String?,
        success: true,
      );
    }
    
    return RefreshTokenResponse(accessToken: null, success: false);
  } catch (e) {
    return RefreshTokenResponse(accessToken: null, success: false);
  }
}
```

### 3. Updated Splash Page to Validate Tokens

**File**: `lib/app/ui/pages/splash/splash_page.dart`

Changed from:
```dart
// OLD: Only check if tokens exist
final accessToken = await authRepo.mSecureStorage.getAccessToken();
bool isAuthenticated = accessToken != null && accessToken.isNotEmpty && ...;
```

To:
```dart
// NEW: Validate and refresh tokens
final hasValidTokens = await authRepo.validateAndRefreshTokens();
bool isAuthenticated = hasValidTokens && hasUserData;
```

### 4. Updated Login Page

**File**: `lib/app/ui/pages/auth/login_page.dart`

Applied the same token validation logic to handle cases where users navigate directly to the login page.

### 5. Updated Dependency Injection

**File**: `lib/app/core_module.dart`

Updated `AuthApiRepo` instantiation to include the Dio instance:
```dart
i.addSingleton(() => AuthApiRepo(apiPoint: i<AuthApiPoint>(), dio: i<Dio>()));
```

## Technical Details

### Token Lifecycle:
- **Access Token**: Short-lived (typically 5-60 minutes)
- **Refresh Token**: Long-lived (typically 7-90 days)
- After 40 days of inactivity, both tokens are expired

### Why Proactive Validation:
Instead of waiting for an API call to fail and triggering the `AuthInterceptor` error handler, we now:
1. Validate tokens during app initialization (splash screen)
2. Clear expired tokens before navigation
3. Navigate to login if tokens are invalid
4. User sees login screen immediately instead of "Login failed" error

## Benefits of This Fix

1. **Better User Experience**: 
   - No confusing "Login failed" message
   - Users go straight to login screen if tokens are expired

2. **Proactive Error Handling**:
   - Catches expired tokens before any API calls
   - Prevents unnecessary API requests with invalid tokens

3. **Clear Feedback**:
   - Logs indicate exactly why authentication failed
   - Easier debugging in production

4. **Consistent Behavior**:
   - Both splash page and login page use same validation logic
   - No edge cases where expired tokens slip through

## Testing Scenarios

### Scenario 1: User Opens App After 40+ Days
- **Before Fix**: 
  - ❌ First login attempt fails
  - ✅ Second login attempt works
- **After Fix**: 
  - ✅ Tokens validated during splash
  - ✅ Expired tokens cleared
  - ✅ User navigates to login screen
  - ✅ First login attempt works

### Scenario 2: User Opens App After 1 Day
- **Before & After**: 
  - ✅ Tokens are valid
  - ✅ User navigates to app

### Scenario 3: Refresh Token Valid, Access Token Expired
- **Before Fix**: 
  - App navigates to quicksearch
  - First API call fails → triggers refresh → works
- **After Fix**: 
  - Tokens refreshed proactively during splash
  - User navigates to app with fresh access token
  - All API calls work immediately

## Files Modified

1. `lib/app/domain/auth/auth_account_repo.dart` - Added token validation logic
2. `lib/app/data/remote/api/parts/auth/api.dart` - Added refresh token API method
3. `lib/app/ui/pages/splash/splash_page.dart` - Updated authentication check
4. `lib/app/ui/pages/auth/login_page.dart` - Updated authentication check
5. `lib/app/core_module.dart` - Updated DI configuration

## Related Issues

- The `AuthInterceptor` already handles token refresh for expired access tokens during API calls
- This fix complements the interceptor by handling expired tokens **before** any API calls
- The interceptor still works as a fallback for edge cases

## Future Improvements (Optional)

1. **Store Token Expiration Time**: 
   - Save `expiresIn` timestamp when storing tokens
   - Check expiration without API call
   - More efficient than calling refresh API

2. **Background Token Refresh**:
   - Periodically refresh tokens in the background
   - Keep user session alive without interruption

3. **Better Error Messages**:
   - Show user-friendly message: "Your session has expired, please login again"
   - Instead of generic "Login failed"

