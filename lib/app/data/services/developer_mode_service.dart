import 'dart:async';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simplified Developer Mode Service - Only handles custom base URL configuration
/// Allows developers to point the app to a local development server
class DeveloperModeService {
  static final DeveloperModeService _instance = DeveloperModeService._internal();
  static DeveloperModeService get instance => _instance;
  
  final Logger _logger = Logger();
  
  // Private constructor
  DeveloperModeService._internal();
  
  // ===== CONSTANTS =====
  static const String defaultProductionUrl = 'https://project.iith.ac.in/bheri';
  static const String apiPath = '/bheri'; // Path to append to custom domain
  
  // ===== AUTHENTICATION STATE =====
  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;
  
  // ===== API URL MANAGEMENT =====
  String _customDomain = ''; // Stores just domain:port (e.g., "192.168.167.88:8000")
  String get customDomain => _customDomain;
  
  final BehaviorSubject<String> _apiUrlSubject = BehaviorSubject.seeded(defaultProductionUrl);
  Stream<String> get apiUrlStream => _apiUrlSubject.stream;
  
  // ===== INITIALIZATION =====
  
  /// Initialize developer mode service
  Future<void> initialize() async {
    try {
      await _loadSettings();
      _logger.d('✅ DeveloperModeService initialized');
    } catch (e) {
      _logger.e('❌ Error initializing DeveloperModeService', error: e);
    }
  }
  
  /// Load settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load developer mode enabled state
      _isEnabled = prefs.getBool('dev_mode_enabled') ?? false;
      
      // Load custom domain (just domain:port without path)
      _customDomain = prefs.getString('dev_mode_custom_domain') ?? '';
      
      final effectiveUrl = getEffectiveApiUrl();
      _apiUrlSubject.add(effectiveUrl);
      
      if (_isEnabled && _customDomain.isNotEmpty) {
        _logger.d('🔧 Developer mode enabled: $_customDomain → $effectiveUrl');
      } else {
        _logger.d('🔧 Using production URL: $effectiveUrl');
      }
    } catch (e) {
      _logger.e('❌ Error loading developer mode settings', error: e);
    }
  }
  
  /// Save settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('dev_mode_enabled', _isEnabled);
      await prefs.setString('dev_mode_custom_domain', _customDomain);
      
      _logger.d('💾 Developer mode settings saved');
    } catch (e) {
      _logger.e('❌ Error saving developer mode settings', error: e);
    }
  }
  
  // ===== DEVELOPER MODE METHODS =====
  
  /// Enable developer mode with custom domain (e.g., "http://192.168.167.88:8000")
  /// The /bheri path will be automatically appended
  Future<void> enable(String customDomainWithProtocol) async {
    _isEnabled = true;
    // Store the domain without any path
    _customDomain = customDomainWithProtocol.endsWith('/') 
        ? customDomainWithProtocol.substring(0, customDomainWithProtocol.length - 1)
        : customDomainWithProtocol;
    
    final fullUrl = getEffectiveApiUrl();
    _apiUrlSubject.add(fullUrl);
    await _saveSettings();
    _logger.d('🔐 Developer mode enabled: $_customDomain → $fullUrl');
  }
  
  /// Disable developer mode and return to production URL
  Future<void> disable() async {
    _isEnabled = false;
    _customDomain = '';
    _apiUrlSubject.add(defaultProductionUrl);
    await _saveSettings();
    _logger.d('🔓 Developer mode disabled, using production URL');
  }
  
  // ===== API URL METHODS =====
  
  /// Get the effective API URL (custom domain + /bheri if enabled, production otherwise)
  /// Examples:
  /// - Production: "https://project.iith.ac.in/bheri"
  /// - Developer mode with "http://192.168.167.88:8000" → "http://192.168.167.88:8000/bheri"
  String getEffectiveApiUrl() {
    if (_isEnabled && _customDomain.isNotEmpty) {
      return '$_customDomain$apiPath';
    }
    return defaultProductionUrl;
  }
  
  // ===== UTILITY METHODS =====
  
  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'isEnabled': _isEnabled,
      'customDomain': _customDomain,
      'apiPath': apiPath,
      'effectiveApiUrl': getEffectiveApiUrl(),
    };
  }
  
  /// Dispose resources
  void dispose() {
    _apiUrlSubject.close();
  }
}








