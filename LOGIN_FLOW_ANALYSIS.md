# 🔍 Complete Login Flow Analysis - Dhara Web App

## 📋 Current Issues Summary

### ✅ FIXED:
1. ~~Vercel build failing~~ - Now using pre-built files
2. ~~404 on flutter_bootstrap.js~~ - Files now being served correctly
3. ~~Google Sign-In popup aborting~~ - Fixed signOut() call on web
4. ~~Direct URL access (404 on /login)~~ - Added rewrite rule in vercel.json

### ❌ REMAINING ISSUE:
**Backend returns 400 "Invalid token" when calling `/api/glogin/`**

---

## 🔄 Complete Authentication Flow

### Step 1: User Lands on Login Page
```
URL: https://dhara-app-flutter.vercel.app/login
Route: /login (defined in lib/app/app_module.dart:88)
Widget: LoginPage (lib/app/ui/pages/auth/login_page.dart)
```

### Step 2: User Clicks "Sign in with Google"
```
Button: googleSignInButton() or onSubmitWithAccountPicker()
Location: lib/app/ui/pages/auth/login_page.dart:456-461
Handler: mBloc.onSubmitWithAccountPicker()
Controller: GoogleLoginController (lib/app/ui/sections/auth/login/google/controller.dart:82)
```

### Step 3: Google Sign-In Popup Opens
```
Method: GoogleAuthService.getIdTokenWithAccountPicker()
Location: lib/app/providers/google/google_auth.dart:99
Platform: Web (kIsWeb = true)

Flow:
1. Skip signOut() on web (to prevent popup abort)
2. Call _googleSignIn!.signIn()
3. User selects Google account
4. Get GoogleSignInAuthentication object
5. Extract access_token (web) or id_token (mobile)
```

### Step 4: Token is Obtained
```
Token Type: access_token (on web, OAuth2 token)
Note: On web, idToken is often null, so we use accessToken
Code: lib/app/providers/google/google_auth.dart:118-128

Token Format:
- Mobile: JWT with 3 parts (header.payload.signature)
- Web: OAuth2 access token (shorter, different format)
```

### Step 5: Token Sent to Controller
```
Controller emits state with idToken
Location: lib/app/ui/sections/auth/login/google/controller.dart:126
Listener: LoginPage._completeBackendLogin()
Location: lib/app/ui/pages/auth/login_page.dart:155
```

### Step 6: Backend Authentication Request
```
Method: authRepo.login(googleIdToken: googleIdToken)
Location: lib/app/domain/auth/auth_account_repo.dart:88

Token Detection (line 94-109):
- Check if token is JWT (has 2 dots, 3 parts) → Mobile
- Otherwise → Web access_token

Request Body:
{
  "access_token": "..." (if web),
  "id_token": "..." (if mobile),
  "client": "web_client"
}

Endpoint: POST /api/glogin/
Full URL: https://project.iith.ac.in/bheri/api/glogin/
API Point: lib/app/data/remote/api/parts/auth/api.dart:15
```

### Step 7: Backend Response (CURRENT FAILURE POINT)
```
Expected (Success - 200):
{
  "access_token": "JWT token from backend",
  "refresh_token": "...",
  "user": {
    "email": "...",
    "name": "...",
    "picture": "..."
  }
}

Actual (Failure - 400):
{
  "error": "Invalid token"
}

Interceptor: Does NOT retry for /google_login endpoint
Location: lib/app/data/remote/api/interceptors/auth_interceptor.dart:99
```

### Step 8: Success Path (After Backend Fix)
```
1. Save tokens to secure storage
   - access_token (backend JWT)
   - refresh_token
   - user info

2. Navigate to dashboard
   Route: /Dhara/quicksearch
   Location: lib/app/ui/pages/auth/login_page.dart:173
```

---

## 🐛 Root Cause Analysis

### Why Backend Returns 400 "Invalid token"

The backend at `project.iith.ac.in/bheri` is **verifying the Google token** by calling Google's token verification API. This verification checks:

1. **Token Signature** - Is it signed by Google?
2. **Token Audience (aud)** - Which Client ID was it issued for?
3. **Token Issuer (iss)** - Is it from accounts.google.com?
4. **Token Expiry (exp)** - Is it still valid?

#### Problem:
The backend is **ONLY configured to accept tokens from the MOBILE Client ID**, not the WEB Client ID.

#### Evidence:
- Mobile app works (uses Client ID: `316847997090-rq6reduc42g6qu8lta3l0r8kcj2mfvdt`)
- Web app fails (uses Client ID: `316847997090-e7saa52r71mei35npko2vlgtu9alhtlb`)

---

## ✅ Solutions Required

### 1. Backend Team Must Fix (CRITICAL)

Update backend token verification to accept BOTH Client IDs:

```python
# Backend code (Django/Flask example)
GOOGLE_CLIENT_IDS = [
    '316847997090-rq6reduc42g6qu8lta3l0r8kcj2mfvdt',  # Mobile (Android)
    '316847997090-e7saa52r71mei35npko2vlgtu9alhtlb',  # Web ← ADD THIS
]

# When verifying token
idinfo = id_token.verify_oauth2_token(
    token, 
    requests.Request(), 
    audience=GOOGLE_CLIENT_IDS  # Accept any of these
)
```

### 2. Google Cloud Console (Already Done ✅)

Authorized JavaScript origins:
```
https://dhara-app-flutter.vercel.app
https://accounts.google.com
```

Authorized redirect URIs:
```
https://dhara-app-flutter.vercel.app
https://dhara-app-flutter.vercel.app/
```

### 3. Firebase (Already Done ✅)

Authorized domains:
```
dhara-app-flutter.vercel.app
```

---

## 🧪 How to Test After Backend Fix

### Test Script for Console:

```javascript
// Run this in browser console at https://dhara-app-flutter.vercel.app/login

// 1. Click Google Sign-In button
// 2. Complete sign-in
// 3. Check console for these logs:

console.log('Looking for token...');
// Should see: "auth_repo: Sending access token (web)"

console.log('Checking backend call...');
// Should see successful response from /api/glogin/

console.log('Checking navigation...');
// Should redirect to /Dhara/quicksearch
```

### Expected Network Request:

```
POST https://project.iith.ac.in/bheri/api/glogin/
Content-Type: application/json

Request Body:
{
  "access_token": "ya29.a0AfH6SMD...",  // Long OAuth2 token
  "client": "web_client"
}

Expected Response (200):
{
  "access_token": "eyJ...",  // Backend JWT
  "refresh_token": "...",
  "user": {...}
}
```

---

## 📝 Backend Team Checklist

- [ ] Add Web Client ID (`316847997090-e7saa52r71mei35npko2vlgtu9alhtlb`) to token verification
- [ ] Test token verification accepts both mobile and web tokens
- [ ] Verify CORS headers allow `dhara-app-flutter.vercel.app`
- [ ] Test `/api/glogin/` endpoint with web access_token
- [ ] Confirm successful response returns proper JWT

---

## 🚀 After Backend Fix - Deployment Complete!

Once backend is fixed:
1. ✅ User can access `/login` directly
2. ✅ Google Sign-In popup works
3. ✅ Token sent to backend
4. ✅ Backend accepts token
5. ✅ Login successful
6. ✅ User redirected to dashboard
7. ✅ App fully functional!

---

## 📞 Contact Backend Team

**Tell them:**
"The Flutter web app at `dhara-app-flutter.vercel.app` is sending valid Google OAuth tokens to `/api/glogin/`, but getting 400 'Invalid token'. The tokens are signed by Google for Web Client ID `316847997090-e7saa52r71mei35npko2vlgtu9alhtlb`. Please add this Client ID to your Google token verification logic alongside the mobile Client ID."

