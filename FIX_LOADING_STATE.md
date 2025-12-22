# 🔧 Fix: Add Loading State During Login Retry

## Problem

Users are manually clicking the "Sign in with Google" button again during the automatic 6-second clock skew retry because:

1. ❌ Button stays enabled during the retry
2. ❌ No loading indicator shows
3. ❌ Users think login failed
4. ❌ Users click again, causing duplicate login attempts

## Solution

Add proper loading state management to disable the button and show feedback during the entire login process.

### Files to Modify

#### 1. `lib/app/ui/sections/auth/login/google/controller.dart`

**Add `isInProgress` state management:**

```dart
onSubmitWithAccountPicker() {
  // Set loading state immediately
  emit(state.copyWith(isInProgress: true));
  
  Future.delayed(Duration(milliseconds: 100), () async {
    await _getGoogleIdTokenWithAccountPicker();

    if (state.idToken != null) {
      print("google login onSubmitWithAccountPicker: success");
      onSuccess();
    } else {
      print("google login onSubmitWithAccountPicker: failed - no token");
      // Clear loading state on failure
      emit(state.copyWith(isInProgress: false));
      onFailed("unable to login with selected account");
    }
  });
}

void onSuccess() {
  print("google login onSuccess: ");
  emit(
    state.copyWith(
      result: GoogleLoginArgsResult(
        resultCode: "RESULT_SUCCESS",
        idToken: state.idToken,
      ),
      // Keep isInProgress true - backend login will happen next
      isInProgress: true,
    ),
  );
}

void onFailed(String message) {
  setModalState(GoogleLoginModal.STATE_DEFAULT);

  emit(
    state.copyWith(
      result: GoogleLoginArgsResult(
        resultCode: "RESULT_FAILED",
      ),
      isInProgress: false, // Clear loading state
    ),
  );
}
```

#### 2. `lib/app/ui/pages/auth/login_page.dart`

**Clear loading state after backend login completes:**

```dart
/// Complete the backend authentication process after Google sign-in
Future<void> _completeBackendLogin(String? googleIdToken) async {
  if (googleIdToken == null) {
    return;
  }

  try {
    // Get the auth repository and complete the login
    final authRepo = Modular.get<AuthAccountRepository>();
    final result = await authRepo.login(googleIdToken: googleIdToken);
    
    if (result.status == DomainResultStatus.SUCCESS) {
      // Wait a moment to ensure the UI state is updated
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted) {
        // Clear loading state before navigation
        mBloc.emit(mBloc.state.copyWith(isInProgress: false));
        
        // Login successful, navigate to main app
        Modular.to.pushReplacementNamed('/Dhara/quicksearch');
      }
    } else {
      // Clear loading state on error
      mBloc.emit(mBloc.state.copyWith(isInProgress: false));
      
      // Show user-friendly error message
      String errorMsg = "Login failed";
      if (result.message != null && result.message!.isNotEmpty) {
        if (result.message!.contains('duplicate records')) {
          errorMsg = result.message!;
        } else if (result.message!.contains('Invalid token') || 
                   result.message!.contains('Bad Request')) {
          errorMsg = "Unable to verify your Google account. Please try again.";
        } else {
          errorMsg = "Login failed. Please try again.";
        }
      }
      _showErrorMessage(errorMsg);
    }
  } catch (e) {
    // Clear loading state on exception
    mBloc.emit(mBloc.state.copyWith(isInProgress: false));
    _showErrorMessage("Login error. Please try again.");
  }
}
```

**Optional: Add loading overlay for better UX:**

```dart
@override
Widget build(BuildContext context) {
  _prepareTheme(context);
  
  return Scaffold(
    backgroundColor: themeColors.surface,
    body: Stack(
      children: [
        MultiBlocListener(
          listeners: [
            BlocListener<GoogleLoginController, GoogleLoginCubitState>(
              bloc: mBloc,
              listenWhen: (previous, current) => previous.result != current.result,
              listener: (context, state) {
                if (state.result != null && 
                    state.result!.resultCode == "RESULT_SUCCESS") {
                  _completeBackendLogin(state.result!.idToken);
                }
              },
            ),
          ],
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: TdResDimens.dp_32,
                vertical: TdResDimens.dp_24,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildAppHeader(),
                    TdResGaps.v_64,
                    _buildSignInSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Loading overlay during login
        BlocBuilder<GoogleLoginController, GoogleLoginCubitState>(
          bloc: mBloc,
          buildWhen: (previous, current) => 
              current.isInProgress != previous.isInProgress,
          builder: (context, state) {
            if (state.isInProgress == true) {
              return Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(TdResDimens.dp_24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: TdResDimens.dp_16),
                          Text(
                            'Signing in...',
                            style: TdResTextStyles.p1.copyWith(
                              color: themeColors.onSurface,
                            ),
                          ),
                          SizedBox(height: TdResDimens.dp_8),
                          Text(
                            'This may take a few seconds',
                            style: TdResTextStyles.caption.copyWith(
                              color: themeColors.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ],
    ),
  );
}
```

## Expected Behavior After Fix

### Before (Current):
```
1. User clicks "Sign in" → Button enabled ✅
2. Google popup → User selects account
3. Popup closes → Button still enabled ✅
4. [6 seconds of nothing visible]
5. User clicks again 🔴 (duplicate login!)
6. Login succeeds
```

### After (Fixed):
```
1. User clicks "Sign in" → Button disabled ❌ + Loading overlay
2. Google popup → User selects account
3. Popup closes → Loading overlay shows "Signing in..."
4. [6 seconds wait] → Spinner + "This may take a few seconds"
5. Login succeeds → Loading cleared → Navigate to app ✅
```

## Why This Fixes the "New User" Problem

The issue was NEVER specific to new users! It happened to ALL users experiencing clock skew:

1. ✅ **Automatic retry works** for everyone
2. ❌ **Button stays enabled** during retry
3. 🔴 **Users click again** thinking it failed
4. ✅ **Both attempts succeed** (one from auto-retry, one from manual)
5. 😕 **Looks like "manual retry fixed it"**

**Reality**: The automatic retry was working all along, users just didn't see it!

## Testing

After implementing this fix:

1. ✅ Test with new user - should see loading for 6+ seconds
2. ✅ Test with existing user - should see brief loading
3. ✅ Try clicking button during loading - should be disabled
4. ✅ Check that loading clears on error
5. ✅ Check that loading clears on success

## Summary

- **Root cause**: Missing loading state during 6-second clock skew retry
- **User impact**: Users thought login failed and manually retried
- **Actual behavior**: Automatic retry was working, just invisible
- **Fix**: Add `isInProgress` state management and loading UI
- **Result**: Users will see loading indicator and won't manually retry






