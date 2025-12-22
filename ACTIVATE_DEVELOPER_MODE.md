# 🔧 How to Activate Developer Mode - STEP BY STEP

## ⚠️ FIRST: You MUST Hard Refresh!

**The new code won't work until you refresh!**

### Hard Refresh Your Browser:
- **Windows/Linux**: Press `Ctrl + Shift + R`
- **Mac**: Press `Cmd + Shift + R`

**OR:**
1. Press `F12` to open DevTools
2. Right-click the refresh button (⟳) near the address bar  
3. Select **"Empty Cache and Hard Reload"**

---

## ✅ After Hard Refresh - 3 Ways to Open Developer Settings:

### **Method 1: Menu (EASIEST) ⭐**

1. Make sure you're **logged in** and on the **Dashboard**
2. Look at the **top-right corner** - you'll see your profile picture/name and a **⋮** (three dots) icon
3. **Click on the ⋮ icon**
4. In the dropdown menu, you should see:
   - Light/Dark Mode
   - Switch Account
   - **Developer Settings** ← Click this!
5. Developer Settings modal will open!

---

### **Method 2: Ctrl+Shift+Click**

1. On the **Dashboard** page
2. Look at **top-left** - you'll see the Dhārā logo (🏄‍♂️ icon + "Dhārā" text)
3. **Hold down `Ctrl + Shift` keys**
4. **While holding**, click on the logo
5. Developer Settings modal should open!

---

### **Method 3: Long Press (Mobile/Touch)**

1. On the **Dashboard** page  
2. Find the Dhārā logo (top-left)
3. **Press and hold** for 1-2 seconds
4. Release
5. Developer Settings modal should open!

---

## 🐛 Troubleshooting:

### If nothing happens:

1. **Did you hard refresh?** (`Ctrl+Shift+R`)
   - Check browser console (F12) for any errors
   - Look for the log: "DashboardPage: Developer mode activation triggered"

2. **Are you on the Dashboard page?**
   - The logo needs to be visible on the page
   - Try navigating to: `https://dhara.bheri.in/Dhara/quicksearch`

3. **Try the menu method first**
   - This is the most reliable
   - Works without any special key combinations

4. **Check browser console** (F12):
   - When you try Ctrl+Shift+Click, you should see:
     ```
     Ctrl+Shift+Click detected!
     DashboardPage: Developer mode activation triggered
     ```
   - If you don't see these logs, the page hasn't been refreshed

---

## 📝 After Opening Developer Settings:

You'll see a modal with:

```
1. Developer Mode
   [Toggle] Enable Developer Mode ← Turn this ON

   Custom Base URL (Domain:Port)
   [Text Input: http://192.168.167.88:8000] /bheri

   Resulting API URL: http://192.168.167.88:8000/bheri

   [Apply Custom URL Button]
```

### Steps:
1. **Toggle ON** "Enable Developer Mode"
2. **Enter your backend URL**:
   - `http://localhost:8000`
   - `http://192.168.167.88:8000`
   - **Don't include `/bheri`** - it's added automatically!
3. **Click "Apply Custom URL"**
4. You'll see a success message
5. Now try logging in - all APIs will use your local backend!

---

## 🎯 Quick Test Checklist:

- [ ] Hard refresh browser (`Ctrl+Shift+R`)
- [ ] Navigate to Dashboard (login if needed)
- [ ] Look for ⋮ menu in top-right corner
- [ ] Click ⋮ → "Developer Settings"
- [ ] Modal opens with Developer Mode toggle
- [ ] Configure your local backend URL
- [ ] Test login with local backend

---

## 💡 Still Not Working?

If the menu option doesn't show up after hard refresh:

1. **Clear ALL browser cache**:
   - Press `Ctrl+Shift+Delete`
   - Select "Cached images and files"
   - Clear cache
   - Close and reopen browser

2. **Check if you're on the latest version**:
   - Open browser console (F12)
   - Type: `window.location.reload(true)`
   - Press Enter

3. **Try a different browser** (to rule out caching issues)

4. **Check the network tab** (F12 → Network):
   - Refresh page
   - Look for `main.dart.js`
   - Check the size - should be ~44MB (minified)
   - If it's loading from cache, that's the problem!

---

## ✅ Success Indicators:

When developer mode is working, you'll see:
- Modal with "Developer Mode" toggle
- Custom URL input field
- "Resulting API URL" display
- "Apply Custom URL" button
- Success toast message after applying

**The menu option is the most reliable way!** Try that first after hard refresh.

