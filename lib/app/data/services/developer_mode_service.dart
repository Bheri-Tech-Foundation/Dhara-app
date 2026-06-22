import 'dart:async';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available backend domains
enum ApiDomain {
  apiBheri('https://api.bheri.in', 'api.bheri.in'),
  projectIith('https://project.iith.ac.in', 'project.iith.ac.in');

  final String url;
  final String label;
  const ApiDomain(this.url, this.label);

  static ApiDomain fromUrl(String url) {
    return ApiDomain.values.firstWhere(
      (d) => d.url == url,
      orElse: () => ApiDomain.apiBheri,
    );
  }
}

/// Available backend routes that testers can switch between
enum ApiRoute {
  bheri('/bheri', 'Bheri (Default)'),
  samiksha('/samiksha', 'Samiksha');

  final String path;
  final String label;
  const ApiRoute(this.path, this.label);

  static ApiRoute fromPath(String path) {
    return ApiRoute.values.firstWhere(
      (r) => r.path == path,
      orElse: () => ApiRoute.bheri,
    );
  }
}

/// Developer Mode Service - Handles custom base URL and backend route configuration.
/// Allows developers/testers to point the app to a local server or switch API routes.
class DeveloperModeService {
  static final DeveloperModeService _instance = DeveloperModeService._internal();
  static DeveloperModeService get instance => _instance;
  
  final Logger _logger = Logger();
  
  DeveloperModeService._internal();
  
  // ===== CONSTANTS =====
  static const String _prefKeyEnabled = 'dev_mode_enabled';
  static const String _prefKeyCustomDomain = 'dev_mode_custom_domain';
  static const String _prefKeyApiRoute = 'dev_mode_api_route';
  static const String _prefKeyApiDomain = 'dev_mode_api_domain';
  
  // ===== STATE =====
  bool _isEnabled = false;
  bool get isEnabled => _isEnabled || _apiRoute == ApiRoute.samiksha;
  
  String _customDomain = '';
  String get customDomain => _customDomain;

  ApiDomain _apiDomain = ApiDomain.apiBheri;
  ApiDomain get apiDomain => _apiDomain;

  ApiRoute _apiRoute = ApiRoute.bheri;
  ApiRoute get apiRoute => _apiRoute;
  
  final BehaviorSubject<String> _apiUrlSubject = BehaviorSubject.seeded('${ApiDomain.apiBheri.url}${ApiRoute.bheri.path}');
  Stream<String> get apiUrlStream => _apiUrlSubject.stream;
  
  // ===== INITIALIZATION =====
  
  Future<void> initialize() async {
    try {
      await _loadSettings();
    } catch (e) {
      _logger.e('Error initializing DeveloperModeService', error: e);
    }
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _isEnabled = prefs.getBool(_prefKeyEnabled) ?? false;
      _customDomain = prefs.getString(_prefKeyCustomDomain) ?? '';
      
      final savedDomain = prefs.getString(_prefKeyApiDomain) ?? ApiDomain.apiBheri.url;
      _apiDomain = ApiDomain.fromUrl(savedDomain);

      final savedRoute = prefs.getString(_prefKeyApiRoute) ?? ApiRoute.bheri.path;
      _apiRoute = ApiRoute.fromPath(savedRoute);
      
      _apiUrlSubject.add(getEffectiveApiUrl());
    } catch (e) {
      _logger.e('Error loading developer mode settings', error: e);
    }
  }
  
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool(_prefKeyEnabled, _isEnabled);
      await prefs.setString(_prefKeyCustomDomain, _customDomain);
      await prefs.setString(_prefKeyApiDomain, _apiDomain.url);
      await prefs.setString(_prefKeyApiRoute, _apiRoute.path);
    } catch (e) {
      _logger.e('Error saving developer mode settings', error: e);
    }
  }
  
  // ===== DEVELOPER MODE METHODS =====
  
  /// Enable developer mode with a custom domain.
  /// The current API route path (e.g. /bheri or /samiksha) is appended automatically.
  Future<void> enable(String customDomainWithProtocol) async {
    _isEnabled = true;
    _customDomain = customDomainWithProtocol.endsWith('/') 
        ? customDomainWithProtocol.substring(0, customDomainWithProtocol.length - 1)
        : customDomainWithProtocol;
    
    _apiUrlSubject.add(getEffectiveApiUrl());
    await _saveSettings();
  }
  
  /// Disable developer mode and return to production URL
  Future<void> disable() async {
    _isEnabled = false;
    _customDomain = '';
    _apiDomain = ApiDomain.apiBheri;
    _apiUrlSubject.add(getEffectiveApiUrl());
    await _saveSettings();
  }

  /// Switch the backend API route (e.g. /bheri ↔ /samiksha).
  /// Persisted across app restarts.
  Future<void> setApiRoute(ApiRoute route) async {
    _apiRoute = route;
    _apiUrlSubject.add(getEffectiveApiUrl());
    await _saveSettings();
  }

  /// Switch the backend domain (e.g. api.bheri.in ↔ project.iith.ac.in).
  /// Only effective in developer mode. Persisted across app restarts.
  Future<void> setApiDomain(ApiDomain domain) async {
    _apiDomain = domain;
    _apiUrlSubject.add(getEffectiveApiUrl());
    await _saveSettings();
  }
  
  // ===== API URL METHODS =====
  
  /// Get the effective API URL.
  /// Priority: customDomain > selectedDomain > default (api.bheri.in)
  /// + selected route (/bheri or /samiksha)
  String getEffectiveApiUrl() {
    if (_isEnabled && _customDomain.isNotEmpty) {
      return '$_customDomain${_apiRoute.path}';
    }
    return '${_apiDomain.url}${_apiRoute.path}';
  }
  
  // ===== UTILITY METHODS =====
  
  Map<String, dynamic> getDebugInfo() {
    return {
      'isEnabled': _isEnabled,
      'customDomain': _customDomain,
      'apiDomain': _apiDomain.url,
      'apiRoute': _apiRoute.path,
      'effectiveApiUrl': getEffectiveApiUrl(),
    };
  }
  
  void dispose() {
    _apiUrlSubject.close();
  }
}








