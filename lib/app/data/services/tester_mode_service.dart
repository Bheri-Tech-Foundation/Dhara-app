import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dharak_flutter/app/data/services/developer_mode_service.dart';

/// Tester Mode Service - Manages tester mode state for voting/feedback.
/// Only available on the web platform; always disabled on mobile.
class TesterModeService {
  static final TesterModeService _instance = TesterModeService._internal();
  static TesterModeService get instance => _instance;
  
  final Logger _logger = Logger();
  
  // Private constructor
  TesterModeService._internal();
  
  // ===== STATE =====
  bool _isEnabled = false;
  bool get isEnabled => kIsWeb && _isEnabled;
  
  final BehaviorSubject<bool> _testerModeSubject = BehaviorSubject.seeded(false);
  Stream<bool> get testerModeStream => _testerModeSubject.stream.map((v) => kIsWeb && v);
  
  // ===== CONSTANTS =====
  static const String _testerModeEnabledKey = 'tester_mode_enabled';
  static const String _hasSeenOnboardingKey = 'scholar_mode_onboarding_shown';
  
  // ===== INITIALIZATION =====
  
  /// Initialize tester mode service (web only).
  /// Auto-enables when the app is served from the /samiksha path.
  Future<void> initialize() async {
    if (!kIsWeb) {
      _logger.d('⏭️ TesterModeService skipped - not on web platform');
      return;
    }
    try {
      await _loadSettings();

      // Auto-enable tester mode when deployed under /samiksha
      // or when the API route is set to Samiksha
      if (_shouldAutoEnable() && !_isEnabled) {
        _isEnabled = true;
        _testerModeSubject.add(true);
        await _saveSettings();
        _logger.d('🧪 Tester mode auto-enabled (samiksha context)');
      }

      _logger.d('✅ TesterModeService initialized - enabled: $_isEnabled');
    } catch (e) {
      _logger.e('❌ Error initializing TesterModeService', error: e);
    }
  }

  /// Check if tester mode should auto-enable:
  /// either the URL path contains /samiksha or the API route is set to Samiksha
  bool _shouldAutoEnable() {
    try {
      final urlHasSamiksha = Uri.base.path.toLowerCase().contains('/samiksha');
      final routeIsSamiksha = DeveloperModeService.instance.apiRoute == ApiRoute.samiksha;
      return urlHasSamiksha || routeIsSamiksha;
    } catch (_) {
      return false;
    }
  }
  
  /// Load settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_testerModeEnabledKey) ?? false;
      _testerModeSubject.add(_isEnabled);
    } catch (e) {
      _logger.e('❌ Error loading tester mode settings', error: e);
    }
  }
  
  /// Save settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_testerModeEnabledKey, _isEnabled);
      _logger.d('💾 Tester mode settings saved: $_isEnabled');
    } catch (e) {
      _logger.e('❌ Error saving tester mode settings', error: e);
    }
  }
  
  // ===== ONBOARDING =====
  
  /// Check if user has seen the onboarding
  Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasSeenOnboardingKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark onboarding as seen
  Future<void> markOnboardingAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenOnboardingKey, true);
      _logger.d('✅ Onboarding marked as seen');
    } catch (e) {
      _logger.e('❌ Error marking onboarding as seen', error: e);
    }
  }
  
  // ===== TESTER MODE METHODS =====
  
  /// Enable tester mode (web only)
  Future<void> enable() async {
    if (!kIsWeb) return;
    _isEnabled = true;
    _testerModeSubject.add(true);
    await _saveSettings();
    _logger.d('🧪 Tester mode enabled');
  }
  
  /// Disable tester mode
  Future<void> disable() async {
    if (!kIsWeb) return;
    _isEnabled = false;
    _testerModeSubject.add(false);
    await _saveSettings();
    _logger.d('🧪 Tester mode disabled');
  }
  
  /// Toggle tester mode (web only)
  Future<void> toggle() async {
    if (!kIsWeb) return;
    if (_isEnabled) {
      await disable();
    } else {
      await enable();
    }
  }
  
  /// Set tester mode to specific value (web only)
  Future<void> setEnabled(bool enabled) async {
    if (!kIsWeb) return;
    if (enabled) {
      await enable();
    } else {
      await disable();
    }
  }
  
  // ===== UTILITY METHODS =====
  
  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'isEnabled': _isEnabled,
    };
  }
  
  /// Dispose resources
  void dispose() {
    _testerModeSubject.close();
  }
}

