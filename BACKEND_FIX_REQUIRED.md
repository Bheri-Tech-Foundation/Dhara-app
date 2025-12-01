# 🔴 CRITICAL BACKEND BUG: Duplicate User Records

## Problem
Users are getting this error when trying to log in:
```
Backend login failed: Unexpected error: get() returned more than one User -- it returned 2!
```

## Root Cause
The database has **duplicate user records** for the same Google account. When a user tries to log in, the backend query returns multiple user records instead of one, causing the login to fail.

## Why This Happens
1. **Missing/Invalid Unique Constraint**: The database doesn't have a proper unique constraint on the user's email or Google ID field
2. **Race Condition**: Multiple simultaneous registration requests created duplicate records
3. **Manual Data Operations**: Database migrations or manual inserts created duplicates

## Impact
- Affected users **cannot log in** (except if they use a different Google account)
- First-time users might get blocked
- Database integrity is compromised

---

## ✅ BACKEND FIX (REQUIRED)

### Step 1: Add Unique Constraint
Add a database constraint to prevent future duplicates:

**Django Example:**
```python
# models.py
class User(models.Model):
    email = models.EmailField(unique=True)  # ← Add this
    google_id = models.CharField(max_length=255, unique=True)  # ← Or this
    # ... other fields
```

**SQL Example:**
```sql
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);
-- OR
ALTER TABLE users ADD CONSTRAINT unique_google_id UNIQUE (google_id);
```

### Step 2: Clean Up Existing Duplicates
Identify and merge/delete duplicate records:

**Find duplicates:**
```sql
SELECT email, COUNT(*) as count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;
```

**Manual cleanup:**
For each duplicate email:
1. Check which record is the "correct" one (most recent activity, complete profile, etc.)
2. **Backup the data first!**
3. Migrate/merge data from duplicate records to the main one
4. Delete the duplicate records

**Django script example:**
```python
from django.contrib.auth.models import User

# Find users with duplicate emails
duplicates = User.objects.values('email').annotate(count=Count('id')).filter(count__gt=1)

for dup in duplicates:
    email = dup['email']
    users = User.objects.filter(email=email).order_by('date_joined')
    
    # Keep the first user (oldest), delete others
    main_user = users.first()
    duplicate_users = users[1:]
    
    print(f"Keeping user ID {main_user.id} for {email}")
    for dup_user in duplicate_users:
        print(f"  Deleting duplicate user ID {dup_user.id}")
        # dup_user.delete()  # Uncomment after verification
```

### Step 3: Update Login Logic
Add error handling for edge cases:

```python
# views.py or serializers.py
try:
    user = User.objects.get(email=email)
except User.MultipleObjectsReturned:
    # Log the error for admin attention
    logger.error(f"Multiple users found for email: {email}")
    # Return a clear error
    raise ValidationError("Duplicate account detected. Please contact support.")
except User.DoesNotExist:
    # Handle new user registration
    user = create_new_user(email=email, ...)
```

---

## 📱 FRONTEND CHANGES (ALREADY DONE)

The Flutter app now:
1. ✅ Detects the duplicate user error
2. ✅ Shows a user-friendly message: "Your account has duplicate records in our system. Please contact support."
3. ✅ Logs the affected Google email for easier backend investigation
4. ✅ Prevents app crash with proper error handling

**Logs to look for:**
```
🔴 Duplicate user records detected in backend database!
🔴 Google account with duplicates: user@example.com
🔴 BACKEND ACTION REQUIRED: Clean up duplicate user records for user@example.com
```

---

## 🚨 PRIORITY
**HIGH** - This blocks users from logging in. Fix ASAP.

## Testing After Fix
1. Try logging in with the affected account
2. Verify only ONE user record exists in the database
3. Confirm login succeeds
4. Test with a new Google account to ensure no new duplicates are created

---

## Support Contact
If users report this error, ask them for:
- Their Google email address
- Screenshot of the error
- Whether they can log in with a different account

Then manually check and clean their duplicate records in the database.

