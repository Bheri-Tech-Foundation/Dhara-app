# Developer Mode Guide

## Overview

Developer Mode is a simplified feature that allows developers to point the Dhara app to a local development server instead of the production server. This is useful for testing API changes locally before deploying to production.

## What Does It Do?

**ONLY ONE THING**: Replaces the production domain `project.iith.ac.in` with your custom domain (e.g., `192.168.167.88:8000`) while keeping the `/bheri` path for **ALL API calls** throughout the app.

**Example**:
- Production: `https://project.iith.ac.in/bheri`
- You enter: `http://192.168.167.88:8000`
- Result: `http://192.168.167.88:8000/bheri` ← `/bheri` is automatically added!

## How to Activate Developer Mode

### On Android (Mobile)
**Long press** on the "Dhārā" logo in the top navigation bar.

### On Web/Desktop
**Right-click** (secondary click) on the "Dhārā" logo in the top navigation bar.

> Note: This works on both web browsers and desktop apps when using a mouse.

## Using Developer Mode

Once activated, a modal will appear with the following options:

1. **Current Status**: Shows whether developer mode is enabled and which URL is currently in use.

2. **Custom Domain & Port**: Enter your local development server domain and port
   - Example: `http://192.168.167.88:8000`
   - Must start with `http://` or `https://`
   - **Important**: `/bheri` will be automatically appended to your input!

3. **Enable Button**: Activates developer mode with your custom domain

4. **Disable Button**: Deactivates developer mode and returns to production URL

## Important Notes

### URL Format
- Your custom URL should be **domain and port only** (no paths)
- The `/bheri` path will be **automatically added**
- ✅ Correct: `http://192.168.167.88:8000`
- ❌ Incorrect: `http://192.168.167.88:8000/bheri` (don't add /bheri, it's automatic!)
- ❌ Incorrect: `http://192.168.167.88:8000/api/` (no paths!)

### What Gets Replaced

When developer mode is enabled with `http://192.168.167.88:8000`:
- Your input: `http://192.168.167.88:8000`
- Actual base URL used: `http://192.168.167.88:8000/bheri`

All API calls will use this base URL:

- **Auth APIs**: 
  - `/api/glogin/` → `http://192.168.167.88:8000/bheri/api/glogin/`
  - `/api/token/refresh/` → `http://192.168.167.88:8000/bheri/api/token/refresh/`

- **Dictionary APIs**: 
  - `/dict/v1/get_defs/` → `http://192.168.167.88:8000/bheri/dict/v1/get_defs/`

- **Verse APIs**: 
  - `/verse/v1/search/` → `http://192.168.167.88:8000/bheri/verse/v1/search/`

- **Citation APIs**: 
  - `/citation/v1/get/` → `http://192.168.167.88:8000/bheri/citation/v1/get/`

- **Prashna (AI) APIs**: 
  - `/prashna/v1/ask/` → `http://192.168.167.88:8000/bheri/prashna/v1/ask/`

- **Unified Search**: 
  - `/quick_search/` → `http://192.168.167.88:8000/bheri/quick_search/`

- **Books APIs**: 
  - All book-related endpoints → `http://192.168.167.88:8000/bheri/...`

### App Restart

⚠️ **You may need to restart the app for changes to take full effect**, especially if:
- You were already logged in before enabling developer mode
- Some API clients were already initialized with the old URL

### Persistence

Developer mode settings are **persistent** and will remain active even after closing and reopening the app. Make sure to **disable** it when you're done testing!

## For Your Team

### Setting Up Local Development Server

1. Start your local backend server on your desired port
   - Example: `python manage.py runserver 0.0.0.0:8000`

2. Find your machine's local IP address
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`
   - Example: `192.168.167.88`

3. Activate Developer Mode in the app
   - Long press (mobile) or right-click (web/desktop) on Dhārā logo
   - Enter your URL: `http://192.168.167.88:8000`
   - Click "Enable"

4. Test your changes
   - All API calls will now go to your local server
   - You can debug, log, and test freely

5. **Don't forget to disable** when done!

### Network Requirements

- Your mobile device and development machine must be on the **same network**
- Your local server must be accessible from the network (use `0.0.0.0` instead of `127.0.0.1`)
- Make sure your firewall allows incoming connections on the server port

## Troubleshooting

### "Connection refused" or "Network error"
- Verify your local server is running
- Check that you're using the correct IP address and port
- Ensure your device and server are on the same network
- Check firewall settings

### "401 Unauthorized" errors
- Your local server might not have the same authentication setup
- Try logging out and logging back in with developer mode enabled

### Changes not taking effect
- Try restarting the app completely
- Verify developer mode is enabled (check Current Status in the modal)
- Check that your custom URL is correct

## Technical Implementation

### Files Modified

1. **`lib/app/data/services/developer_mode_service.dart`**
   - Simplified service that manages only custom base URL
   - Persistent storage using SharedPreferences
   - Stream-based URL updates

2. **`lib/app/ui/widgets/developer_settings_modal.dart`**
   - Clean UI for enabling/disabling developer mode
   - URL validation and status display

3. **`lib/app/ui/pages/dashboard/dashboard_page.dart`**
   - Long press and right-click activation
   - No password required

4. **`lib/app/core_module.dart`**
   - Uses `DeveloperModeService.instance.getEffectiveApiUrl()` for all API points

5. **`lib/app/data/remote/api/interceptors/auth_interceptor.dart`**
   - Token refresh uses developer mode URL

6. **`lib/app/data/remote/api/parts/unified/api_point_simple.dart`**
   - Unified search uses developer mode URL

### How It Works

```dart
// Production URL (default)
String apiUrl = "https://project.iith.ac.in/bheri";

// When developer mode is enabled
if (DeveloperModeService.instance.isEnabled) {
  apiUrl = DeveloperModeService.instance.customApiUrl; // e.g., "http://192.168.167.88:8000"
}

// All API points use this effective URL
DeveloperModeService.instance.getEffectiveApiUrl();
```

## Security Note

This feature is for **development use only**. It should not be used in production builds. Consider:
- Removing the activation gesture in production builds
- Adding additional checks to prevent misuse
- Logging all developer mode activations for security auditing

---

**Happy Developing! 🚀**

