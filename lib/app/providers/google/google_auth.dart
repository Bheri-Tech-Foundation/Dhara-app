import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class GoogleAuthService {
  var mLogger = Logger();
  
  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;
  bool _isInitialized = false; // Track initialization state
  DateTime? _lastSilentSignInAttempt; // Track last silent sign-in attempt

  final PublishSubject<bool> _mOnLoggedIn = PublishSubject<bool>();
  PublishSubject<bool> get onLoggedIn => _mOnLoggedIn;

  GoogleSignInAccount? get currentUser => _currentUser;

  void initGoogleClient() {
    try {
      // Prevent multiple initializations
      if (_isInitialized) {
        mLogger.d('Google client already initialized, skipping');
        return;
      }
      
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'openid',  // Request OpenID to get ID token
        ],
        // Add web client ID for web support
        clientId: kIsWeb 
          ? "316847997090-e7saa52r71mei35npko2vlgtu9alhtlb.apps.googleusercontent.com"
          : null,
      );

      _googleSignIn!.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
        _currentUser = account;
        if (account != null) {
          mLogger.d('Google user signed in: ${account.email}');
          _mOnLoggedIn.sink.add(true);
        } else {
          mLogger.d('Google user signed out');
          _mOnLoggedIn.sink.add(false);
        }
      });

      _isInitialized = true;
      
      // Try to restore previous session silently (skip on web to avoid rate limits)
      if (!kIsWeb) {
        _trySignInSilently();
      } else {
        mLogger.d('Skipping silent sign-in on web to avoid Google One Tap rate limits');
      }
    } catch (e) {
      mLogger.e('Error initializing Google client: $e');
    }
  }
  
  /// Attempt silent sign-in with rate limiting protection for web
  void _trySignInSilently() {
    try {
      // On web, Google limits silent sign-in to once every 10 minutes
      if (kIsWeb && _lastSilentSignInAttempt != null) {
        final timeSinceLastAttempt = DateTime.now().difference(_lastSilentSignInAttempt!);
        if (timeSinceLastAttempt.inMinutes < 10) {
          mLogger.d('Skipping silent sign-in (last attempt was ${timeSinceLastAttempt.inMinutes} minutes ago)');
          return;
        }
      }
      
      _lastSilentSignInAttempt = DateTime.now();
      mLogger.d('Attempting silent Google sign-in...');
      _googleSignIn!.signInSilently();
    } catch (e) {
      mLogger.e('Error in silent sign-in: $e');
    }
  }

  Future<GoogleSignInAuthentication> signInWithGoogle() async {
    try {
      mLogger.d('Attempting Google sign-in...');
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by user');
      }

      mLogger.d('Google sign-in successful for: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      return googleAuth;
    } catch (e) {
      mLogger.e('Google sign-in error: $e');
      rethrow;
    }
  }

  Future<String> getIdToken() async {
    try {
      if (_currentUser == null) {
        throw Exception('No current Google user');
      }
      
      final GoogleSignInAuthentication auth = await _currentUser!.authentication;
      
      // On web, ID token might be null, so use access token as fallback
      // The backend expects an access_token anyway (OAuth2 token)
      if (kIsWeb && auth.idToken == null) {
        if (auth.accessToken == null) {
          throw Exception('Failed to get access token');
        }
        mLogger.w('! ID token is null on web, but access token is available. Using access token as fallback.');
        return auth.accessToken!;
      }
      
      if (auth.idToken == null) {
        throw Exception('Failed to get ID token');
      }
      
      return auth.idToken!;
    } catch (e) {
      mLogger.e('Error getting ID token: $e');
      rethrow;
    }
  }

  Future<String> getIdTokenWithAccountPicker() async {
    try {
      mLogger.d('Starting Google sign-in with account picker...');
      
      // On web, just call signIn directly - the SDK will show account picker
      // Don't call signOut() as it aborts the popup on web
      if (!kIsWeb) {
        // Only sign out on mobile to force account picker
        await _googleSignIn!.signOut();
      }
      
      // Sign in with account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by user');
      }

      mLogger.d('Google sign-in with account picker successful for: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // On web, ID token might be null, so use access token as fallback
      // The backend expects an access_token anyway (OAuth2 token)
      if (kIsWeb && googleAuth.idToken == null) {
        if (googleAuth.accessToken == null) {
          throw Exception('Failed to get access token from account picker');
        }
        mLogger.w('! ID token is null on web, but access token is available. Using access token as fallback.');
        return googleAuth.accessToken!;
      }
      
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from account picker');
      }
      
      return googleAuth.idToken!;
    } catch (e) {
      mLogger.e('Error getting ID token with account picker: $e');
      rethrow;
    }
  }

  Future<String> getIdTokenSilent() async {
    try {
      mLogger.d('Attempting silent Google sign-in...');
      
      // Try silent sign-in first
      GoogleSignInAccount? googleUser = await _googleSignIn!.signInSilently();
      
      if (googleUser == null) {
        throw Exception('Silent sign-in failed - no cached account');
      }

      mLogger.d('Silent sign-in successful for: ${googleUser.email}');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // On web, ID token might be null, so use access token as fallback
      // The backend expects an access_token anyway (OAuth2 token)
      if (kIsWeb && googleAuth.idToken == null) {
        if (googleAuth.accessToken == null) {
          throw Exception('Failed to get access token from silent sign-in');
        }
        mLogger.w('! ID token is null on web, but access token is available. Using access token as fallback.');
        return googleAuth.accessToken!;
      }
      
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from silent sign-in');
      }
      
      return googleAuth.idToken!;
    } catch (e) {
      mLogger.e('Error getting ID token silently: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      mLogger.d('Signing out from Google...');
      await _googleSignIn?.signOut();
      _currentUser = null;
      mLogger.d('Google sign-out successful');
    } catch (e) {
      mLogger.e('Error signing out from Google: $e');
    }
  }

  void dispose() {
    _mOnLoggedIn.close();
  }
}