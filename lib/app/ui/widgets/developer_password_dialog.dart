import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:dharak_flutter/res/styles/text_styles.dart';
import 'package:dharak_flutter/res/values/dimens.dart';
import 'package:dharak_flutter/res/values/gaps.dart';
import 'package:flutter/material.dart';

/// Simple password dialog for developer mode access
class DeveloperPasswordDialog extends StatefulWidget {
  final AppThemeColors? themeColors;
  final String correctPassword;
  
  const DeveloperPasswordDialog({
    super.key,
    this.themeColors,
    this.correctPassword = 'dev123', // Default password
  });

  @override
  State<DeveloperPasswordDialog> createState() => _DeveloperPasswordDialogState();
}

class _DeveloperPasswordDialogState extends State<DeveloperPasswordDialog> {
  late final AppThemeColors themeColors;
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    themeColors = widget.themeColors ?? 
        AppThemeColors.seedColor(seedColor: const Color(0xFF6CE18D), isDark: false);
  }
  
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
  
  void _checkPassword() {
    final password = _passwordController.text.trim();
    
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a password';
      });
      return;
    }
    
    if (password == widget.correctPassword) {
      // Password correct - return true to caller
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = 'Incorrect password';
      });
      _passwordController.clear();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TdResDimens.dp_16),
      ),
      backgroundColor: themeColors.surface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(TdResDimens.dp_24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: themeColors.primary,
                  size: TdResDimens.dp_24,
                ),
                TdResGaps.h_12,
                Expanded(
                  child: Text(
                    'Developer Mode',
                    style: TdResTextStyles.h4.copyWith(
                      color: themeColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: themeColors.onSurface),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            
            TdResGaps.v_8,
            
            Text(
              'Enter developer password to access settings',
              style: TdResTextStyles.caption.copyWith(
                color: themeColors.onSurface?.withOpacity(0.7),
              ),
            ),
            
            TdResGaps.v_24,
            
            // Password field
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofocus: true,
              onSubmitted: (_) => _checkPassword(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter password',
                errorText: _errorMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TdResDimens.dp_8),
                ),
                prefixIcon: Icon(Icons.vpn_key, color: themeColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: themeColors.onSurface?.withOpacity(0.6),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              style: TdResTextStyles.h6.copyWith(color: themeColors.onSurface),
            ),
            
            TdResGaps.v_24,
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TdResTextStyles.button.copyWith(
                      color: themeColors.onSurface?.withOpacity(0.6),
                    ),
                  ),
                ),
                TdResGaps.h_12,
                ElevatedButton(
                  onPressed: _checkPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColors.primary,
                    foregroundColor: themeColors.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: TdResDimens.dp_24,
                      vertical: TdResDimens.dp_12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TdResDimens.dp_8),
                    ),
                  ),
                  child: Text(
                    'Unlock',
                    style: TdResTextStyles.button.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            TdResGaps.v_12,
            
            // Hint for development
            Container(
              padding: const EdgeInsets.all(TdResDimens.dp_12),
              decoration: BoxDecoration(
                color: themeColors.primary?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TdResDimens.dp_8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: TdResDimens.dp_16,
                    color: themeColors.primary,
                  ),
                  TdResGaps.h_8,
                  Expanded(
                    child: Text(
                      'Default password: dev123',
                      style: TdResTextStyles.caption.copyWith(
                        color: themeColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

