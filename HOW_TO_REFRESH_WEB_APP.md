# How to Refresh Web App After New Build

## You're seeing the old error because the browser cached the old build!

### Quick Solution - Hard Refresh:

**Windows/Linux:**
- Press `Ctrl + Shift + R` 
- OR `Ctrl + F5`
- OR `Shift + F5`

**Mac:**
- Press `Cmd + Shift + R`
- OR `Cmd + Shift + Delete` (then clear cache)

### Alternative - Clear Browser Cache:

1. Open DevTools (F12)
2. Right-click on the refresh button (near address bar)
3. Select "Empty Cache and Hard Reload"

### Or manually:

1. Press `F12` to open DevTools
2. Go to "Application" tab
3. Click "Clear site data" under "Storage"
4. Refresh the page

### After refreshing, you should see:
- **Old error**: "Backend login failed: The connection errored: The XMLHttpRequest onError callback was called..."
- **New error** (user-friendly): "Please check your internet connection and try again."

---

## But the real issue is:

**Your backend server is not responding!**

The console shows:
```
POST https://project.iith.ac.in/bheri/api/glogin/ net::ERR_CONNECTION_TIMED_OUT
```

This means the backend at `https://project.iith.ac.in` is either:
- Down
- Not accessible from your network
- Behind a firewall
- Taking too long to respond

### To verify:
1. Try opening `https://project.iith.ac.in/bheri` directly in your browser
2. Check if the server is running
3. Check your internet connection
4. Try from a different network

### To use a local backend instead:
1. Hard refresh the page first (to load new build)
2. On the login page, use **Ctrl+Shift+Click** on the Dhara logo
3. Enable developer mode
4. Enter your local backend URL (e.g., `http://localhost:8000`)
5. Try logging in again


