import 'dart:async';
import 'dart:developer';

import 'package:dharak_flutter/app/data/local/secure/secure_local_data.dart';
import 'package:dharak_flutter/app/data/remote/api/base/dto/error_dto.dart';
import 'package:dharak_flutter/app/data/remote/api/parts/auth/api.dart';
import 'package:dharak_flutter/app/data/remote/api/parts/auth/dto/auth_login_req_dto.dart';
import 'package:dharak_flutter/app/domain/base/domain_helper.dart';
import 'package:dharak_flutter/app/domain/base/domain_result.dart';
import 'package:dharak_flutter/app/providers/google/google_auth.dart';
import 'package:dharak_flutter/app/types/auth/login.dart';
import 'package:dharak_flutter/app/types/user/user.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class AuthAccountRepository extends Disposable {
  var mLogger = Logger();

  final AuthApiRepo mAuthApiRepo;
  final SecureLocalData mSecureStorage;

  final GoogleAuthService mGoogleAuthService;

  final PublishSubject<String> _mErrorMessage = PublishSubject<String>();
  PublishSubject<String> get errorMessage => _mErrorMessage;

  final PublishSubject<bool> _mAccountStateChanged = PublishSubject<bool>();
  PublishSubject<bool> get accountChangedObservable => _mAccountStateChanged;

  final PublishSubject<bool> _mOnGoogleWebLoggedIn = PublishSubject<bool>();

  StreamSubscription<bool>? _mGoogleLoginSubscription;
  PublishSubject<bool> get onGoogleWebLoggedIn => _mOnGoogleWebLoggedIn;

  final BehaviorSubject<UserRM?> _mSubjectAccountUser = BehaviorSubject.seeded(
    null,
  );

  UserRM? _mUser;
  BehaviorSubject<UserRM?> get mAccountUserObservable => _mSubjectAccountUser;

  AuthAccountRepository({
    required this.mAuthApiRepo,
    required this.mSecureStorage,
    required this.mGoogleAuthService,
  });

  @override
  void dispose() {
    _mErrorMessage.close();
    _mOnGoogleWebLoggedIn.close();
    _mSubjectAccountUser.close();
    _mAccountStateChanged.close();
    try {
      _mGoogleLoginSubscription?.cancel();
      _mGoogleLoginSubscription = null;
    } catch (e) {
      print("AuthAccountRepository dispose error: ");
      print(e);
    }
  }

  initSetup() {
    mGoogleAuthService.initGoogleClient();
    _mGoogleLoginSubscription = mGoogleAuthService.onLoggedIn.listen((onData) {
      _mOnGoogleWebLoggedIn.sink.add(onData);
    });
    _loadUser();
  }

  Future<UserRM?> _loadUser() async {
    var name = await mSecureStorage.getDisplayName();
    var email = await mSecureStorage.getEmail();
    var picture = await mSecureStorage.getPicture();

    if (name.isNotEmpty || email != null || picture != null) {
      _mUser = UserRM(name: name, email: email, picture: picture);
      _mSubjectAccountUser.sink.add(_mUser);
    }
    return _mUser;
  }

  Future<DomainResult<bool>> login({String? googleIdToken}) async {
    print('🔐 Attempting login...');
    var result = await _attemptLogin(googleIdToken);
    
    print('🔍 Login result status: ${result.status}, message: ${result.message}');
    
    // With backend clock skew tolerance added, retries should rarely be needed
    // But keep them as a fallback safety net
    
    // Check for duplicate user error (backend database issue)
    if (result.status == DomainResultStatus.ERROR && 
        result.message?.contains('returned more than one User') == true) {
      final googleEmail = mGoogleAuthService.currentUser?.email ?? 'unknown';
      
      mLogger.e('🔴 Duplicate user records detected in backend database!');
      mLogger.e('🔴 Google account with duplicates: $googleEmail');
      
      // User-friendly error message (no technical details)
      return DomainResult<bool>(
        DomainResultStatus.ERROR,
        message: 'There seems to be an issue with your account. Please contact support for assistance.',
        data: false,
      );
    }
    
    // Fallback: Check if it's a clock skew error (should be rare with backend tolerance)
    if (result.status == DomainResultStatus.ERROR && 
        result.message?.contains('Token used too early') == true) {
      mLogger.w('⏰ Clock skew detected (backend tolerance may not be working). Retrying...');
      
      // Shorter wait since backend should have tolerance now
      await Future.delayed(const Duration(seconds: 3));
      result = await _attemptLogin(googleIdToken);
      
      if (result.status == DomainResultStatus.SUCCESS) {
        mLogger.i('✅ Login succeeded after retry!');
      }
    }

    if (result.status == DomainResultStatus.SUCCESS && result.data != null) {
      _mAccountStateChanged.sink.add(result.data!);
    }
    return result;
  }

  /// Internal method to attempt login (used for retry logic)
  Future<DomainResult<bool>> _attemptLogin(String? googleIdToken) async {
    return await domainCallBeforeSave<bool, AuthLoginRM, ErrorDto, UserRM>(
      networkCall: () async {
        print("auth_repo login 0:");

        // Detect token type: JWT (ID token) has 2 dots, OAuth access token doesn't
        bool isJWT = googleIdToken?.contains('.') == true && 
                     googleIdToken!.split('.').length == 3;
        
        String? accessToken;
        String? idToken;
        
        if (isJWT) {
          // Mobile sends ID token
          idToken = googleIdToken;
          print("auth_repo: Sending ID token (mobile)");
        } else {
          // Web sends access token
          accessToken = googleIdToken;
          print("auth_repo: Sending access token (web)");
        }

        return await mAuthApiRepo.login(
          AuthLoginReqDto(
            accessToken: accessToken,
            idToken: idToken,
            client: kIsWeb ? 'web_client' : 'bheri_web',
          ),
        );
      },
      saveCallResult: (remoteData) async {
        await mSecureStorage.saveAccessToken(remoteData.accessToken);
        await mSecureStorage.saveRefreshToken(remoteData.refreshToken);
        await mSecureStorage.saveEmail(remoteData.user?.email);
        await mSecureStorage.saveDisplayName(remoteData.user?.getName());
        await mSecureStorage.savePicture(remoteData.user?.picture);

        await _loadUser();

        return Future.value(_mUser);
      },
      finalResult: (savedData) => savedData != null,
    );
  }

  /* *****************************************************************************
   *                              Google
   */

  Future<GoogleSignInAuthentication> signInWithGoogle() async {
    try {
      var cred = await mGoogleAuthService.signInWithGoogle();
      return cred;
    } catch (e) {
      inspect(e);
      print(e);
      throw e;
    }
  }

  /* ****************************************************************8*
   *                                Google ID Token Methods
   */

  Future<String> getIdToken() async {
    var idTOken = await mGoogleAuthService.getIdToken();
    int tokenLength = idTOken.length;
    int tokenL2 = (tokenLength / 2).ceil();
    print("getIdToken: token obtained");

    debugPrint(idTOken.substring(0, tokenL2));
    debugPrint(idTOken.substring(tokenL2, tokenLength));
    return idTOken;
  }

  Future<String> getIdTokenWithAccountPicker() async {
    // Force account picker and get new token
    var idTOken = await mGoogleAuthService.getIdTokenWithAccountPicker();
    int tokenLength = idTOken.length;
    int tokenL2 = (tokenLength / 2).ceil();
    print("getIdTokenWithAccountPicker: token obtained");

    debugPrint(idTOken.substring(0, tokenL2));
    debugPrint(idTOken.substring(tokenL2, tokenLength));
    return idTOken;
  }

  Future<String> getIdTokenSilent() async {
    // Try silent sign-in with current Google user
    var idTOken = await mGoogleAuthService.getIdTokenSilent();
    int tokenLength = idTOken.length;
    int tokenL2 = (tokenLength / 2).ceil();
    print("getIdTokenSilent: token obtained");

    debugPrint(idTOken.substring(0, tokenL2));
    debugPrint(idTOken.substring(tokenL2, tokenLength));
    return idTOken;
  }

  switchAccount() async {
    // Clear only the authentication tokens, not the display info (email, name, picture)
    // DON'T logout from Google to allow silent sign-in with last account
    await mSecureStorage.saveAccessToken(null); // This will delete the token
    await mSecureStorage.saveRefreshToken(null); // This will delete the token
    
    _mAccountStateChanged.sink.add(false);
    _mSubjectAccountUser.sink.add(null);
  }

  logout() async {
    await mSecureStorage.clear();
    await mGoogleAuthService.logout(); // Also logout from Google
    _mAccountStateChanged.sink.add(false);
    _mSubjectAccountUser.sink.add(null);
  }

  /// Validate existing tokens by attempting to refresh
  /// Returns true if tokens are valid/refreshed successfully
  /// Returns false if tokens are expired/invalid and need re-login
  Future<bool> validateAndRefreshTokens() async {
    try {
      final accessToken = await mSecureStorage.getAccessToken();
      final refreshToken = await mSecureStorage.getRefreshToken();
      
      // No tokens = not authenticated
      if (accessToken == null || accessToken.isEmpty || 
          refreshToken == null || refreshToken.isEmpty) {
        mLogger.d('validateAndRefreshTokens: No tokens found');
        return false;
      }
      
      // IMPORTANT: Don't force refresh on every app start!
      // Just check if tokens exist - they'll be refreshed automatically 
      // by AuthInterceptor when API calls get 401 errors
      mLogger.d('validateAndRefreshTokens: Tokens found, assuming valid (will auto-refresh if needed)');
      return true;
      
      // OLD CODE: This was too aggressive - would logout on any network error!
      // final isRefreshSuccess = await _attemptTokenRefresh(refreshToken);
      // if (!isRefreshSuccess) {
      //   await clearAllAuthData();
      //   return false;
      // }
    } catch (e) {
      mLogger.e('validateAndRefreshTokens: Error reading tokens - $e');
      // Don't clear auth data for read errors - might be temporary storage issue
      // Only return false to trigger login if tokens are actually missing
      return false;
    }
  }
  
  /// Attempt to refresh the access token using refresh token
  Future<bool> _attemptTokenRefresh(String refreshToken) async {
    try {
      final response = await mAuthApiRepo.refreshToken({'refresh': refreshToken});
      
      if (response.accessToken != null && response.accessToken!.isNotEmpty) {
        await mSecureStorage.saveAccessToken(response.accessToken);
        mLogger.d('_attemptTokenRefresh: New access token saved');
        return true;
      }
      
      mLogger.w('_attemptTokenRefresh: No access token in response');
      return false;
    } catch (e) {
      mLogger.e('_attemptTokenRefresh: Failed - $e');
      // Likely means refresh token is expired
      return false;
    }
  }
  
  /// Clear all authentication data (used when refresh token expires)
  Future<void> clearAllAuthData() async {
    try {
      mLogger.d('clearAllAuthData: Clearing all tokens and user data');
      await mSecureStorage.saveAccessToken(null);
      await mSecureStorage.saveRefreshToken(null);
      // Optionally clear user info (email, name, picture) to force complete re-login
      // Uncomment these if you want to clear user info too:
      // await mSecureStorage.saveEmail(null);
      // await mSecureStorage.saveDisplayName(null);
      // await mSecureStorage.savePicture(null);
      
      _mAccountStateChanged.sink.add(false);
      _mSubjectAccountUser.sink.add(null);
    } catch (e) {
      mLogger.e('clearAllAuthData: Error - $e');
    }
  }
}