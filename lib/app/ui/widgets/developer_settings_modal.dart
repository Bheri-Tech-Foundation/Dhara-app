import 'package:flutter/material.dart';
import 'package:dharak_flutter/app/data/services/developer_mode_service.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:dharak_flutter/res/styles/text_styles.dart';
import 'package:dharak_flutter/res/values/dimens.dart';
import 'package:dharak_flutter/res/values/gaps.dart';

/// Simplified Developer Settings Modal - Only handles custom base URL
class DeveloperSettingsModal extends StatefulWidget {
  final AppThemeColors? themeColors;
  
  const DeveloperSettingsModal({
    super.key,
    this.themeColors,
  });

  @override
  State<DeveloperSettingsModal> createState() => _DeveloperSettingsModalState();
}

class _DeveloperSettingsModalState extends State<DeveloperSettingsModal> {
  late final AppThemeColors themeColors;
  final TextEditingController _customUrlController = TextEditingController();
  
  bool _isEnabled = false;
  ApiRoute _selectedRoute = ApiRoute.bheri;
  
  @override
  void initState() {
    super.initState();
    themeColors = widget.themeColors ?? 
        AppThemeColors.seedColor(seedColor: const Color(0xFF6CE18D), isDark: false);
    
    _loadCurrentSettings();
  }
  
  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCurrentSettings() async {
    setState(() {
      _isEnabled = DeveloperModeService.instance.isEnabled;
      _customUrlController.text = DeveloperModeService.instance.customDomain;
      _selectedRoute = DeveloperModeService.instance.apiRoute;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard height for proper padding
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(TdResDimens.dp_20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          TdResGaps.v_20,
          
          // Header with title and close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TdResDimens.dp_20),
            child: Row(
              children: [
                Icon(
                  Icons.developer_mode,
                  color: themeColors.primary,
                  size: 28,
                ),
                const SizedBox(width: TdResDimens.dp_12),
                Expanded(
                  child: Text(
                    'Developer Mode',
                    style: TdResTextStyles.h2.copyWith(
                      color: themeColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: themeColors.onSurface?.withOpacity(0.7),
                  ),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          
          TdResGaps.v_16,
          
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TdResDimens.dp_20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Current status
                  Text(
                    'Current Status',
                    style: TdResTextStyles.h4.copyWith(
                      color: themeColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TdResGaps.v_12,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(TdResDimens.dp_16),
                    decoration: BoxDecoration(
                      color: (_isEnabled ? Colors.green : Colors.grey).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(TdResDimens.dp_8),
                      border: Border.all(
                        color: (_isEnabled ? Colors.green : Colors.grey).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isEnabled ? Icons.check_circle : Icons.cancel,
                          color: _isEnabled ? Colors.green : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: TdResDimens.dp_12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEnabled ? 'Developer Mode Enabled' : 'Using Production URL',
                                style: TdResTextStyles.h6.copyWith(
                                  color: themeColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TdResGaps.v_4,
                              Text(
                                DeveloperModeService.instance.getEffectiveApiUrl(),
                                style: TdResTextStyles.buttonSmall.copyWith(
                                  color: themeColors.onSurface?.withOpacity(0.7),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  TdResGaps.v_20,

                  // Backend route selector
                  Text(
                    'Backend Route',
                    style: TdResTextStyles.h4.copyWith(
                      color: themeColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TdResGaps.v_8,
                  Text(
                    'Switch between Bheri (default) and Samiksha backends.',
                    style: TdResTextStyles.buttonSmall.copyWith(
                      color: themeColors.onSurface?.withOpacity(0.6),
                    ),
                  ),
                  TdResGaps.v_12,
                  Row(
                    children: ApiRoute.values.map((route) {
                      final isSelected = _selectedRoute == route;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: route != ApiRoute.values.last ? TdResDimens.dp_8 : 0,
                          ),
                          child: OutlinedButton(
                            onPressed: () => _switchRoute(route),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSelected 
                                  ? themeColors.primary.withOpacity(0.15) 
                                  : Colors.transparent,
                              side: BorderSide(
                                color: isSelected ? themeColors.primary : Colors.grey.withOpacity(0.4),
                                width: isSelected ? 2 : 1,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: TdResDimens.dp_14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(TdResDimens.dp_8),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  route.label,
                                  style: TdResTextStyles.h6.copyWith(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? themeColors.primary : themeColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  route.path,
                                  style: TdResTextStyles.buttonSmall.copyWith(
                                    fontFamily: 'monospace',
                                    color: isSelected 
                                        ? themeColors.primary.withOpacity(0.8) 
                                        : themeColors.onSurface?.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  TdResGaps.v_24,

                  // Custom domain section
                  Text(
                    'Custom Domain (Optional)',
                    style: TdResTextStyles.h4.copyWith(
                      color: themeColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TdResGaps.v_12,
                  TextField(
                    controller: _customUrlController,
                    onSubmitted: (_) => _applyCustomUrl(),
                    decoration: InputDecoration(
                      hintText: 'http://192.168.167.88:8000',
                      prefixIcon: Icon(Icons.link, color: themeColors.primary),
                      suffixText: _selectedRoute.path,
                      suffixStyle: TdResTextStyles.h6.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(TdResDimens.dp_8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: TdResDimens.dp_16,
                        vertical: TdResDimens.dp_16,
                      ),
                    ),
                    style: TdResTextStyles.h6.copyWith(
                      color: themeColors.onSurface,
                      fontFamily: 'monospace',
                    ),
                  ),
                  TdResGaps.v_16,
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyCustomUrl,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: TdResDimens.dp_14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(TdResDimens.dp_8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, size: 20),
                              const SizedBox(width: TdResDimens.dp_8),
                              Text(
                                'Enable',
                                style: TdResTextStyles.h6.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: TdResDimens.dp_12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _disableDeveloperMode,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: TdResDimens.dp_14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(TdResDimens.dp_8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.close, size: 20),
                              const SizedBox(width: TdResDimens.dp_8),
                              Text(
                                'Disable',
                                style: TdResTextStyles.h6.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  TdResGaps.v_24,
                  
                  // Warning note
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(TdResDimens.dp_16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(TdResDimens.dp_8),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: TdResDimens.dp_12),
                        Expanded(
                          child: Text(
                            'IMPORTANT: You must restart the app after enabling/disabling developer mode for changes to take effect.',
                            style: TdResTextStyles.h6.copyWith(
                              color: themeColors.onSurface?.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  TdResGaps.v_32,
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
  
  Future<void> _switchRoute(ApiRoute route) async {
    await DeveloperModeService.instance.setApiRoute(route);
    setState(() {
      _selectedRoute = route;
    });
    if (context.mounted) {
      _showRestartDialog();
    }
  }

  Future<void> _applyCustomUrl() async {
    final url = _customUrlController.text.trim();
    
    if (url.isEmpty) {
      _showErrorMessage('Please enter a custom URL');
      return;
    }
    
    // Basic URL validation
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      _showErrorMessage('URL must start with http:// or https://');
      return;
    }
    
    await DeveloperModeService.instance.enable(url);
    setState(() {
      _isEnabled = true;
    });
    
    // Show dialog to restart app
    if (context.mounted) {
      _showRestartDialog();
    }
  }
  
  Future<void> _disableDeveloperMode() async {
    await DeveloperModeService.instance.disable();
    setState(() {
      _isEnabled = false;
    });
    
    // Show dialog to restart app
    if (context.mounted) {
      _showRestartDialog();
    }
  }
  
  void _showRestartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Restart Required'),
        content: const Text(
          'Developer mode settings have been updated.\n\n'
          'Please close and restart the app for changes to take effect.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close developer settings
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
