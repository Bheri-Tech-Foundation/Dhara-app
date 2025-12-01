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
    // First attempt
    print('🔐 Attempting login...');
    var result = await _attemptLogin(googleIdToken);
    
    print('🔍 Login result status: ${result.status}, message: ${result.message}');
    
    // Check for duplicate user error (backend database issue)
    if (result.status == DomainResultStatus.ERROR && 
        result.message?.contains('returned more than one User') == true) {
      // Get Google account email for logging
      final googleEmail = mGoogleAuthService.currentUser?.email ?? 'unknown';
      
      mLogger.e('🔴 Duplicate user records detected in backend database!');
      mLogger.e('🔴 Google account with duplicates: $googleEmail');
      print('🔴 Duplicate user error: ${result.message}');
      print('🔴 Google account: $googleEmail');
      print('🔴 BACKEND ACTION REQUIRED: Clean up duplicate user records for $googleEmail');
      
      // Return a user-friendly error message
      return DomainResult<bool>(
        status: DomainResultStatus.ERROR,
        message: 'Your account has duplicate records in our system. Please contact support to resolve this issue. (Account: $googleEmail)',
        data: false,
      );
    }
    
    // Check if it's a clock skew error
    if (result.status == DomainResultStatus.ERROR && 
        result.message?.contains('Token used too early') == true) {
      mLogger.w('⏰ Clock skew detected! Device clock is ahead of server. Retrying in 6 seconds...');
      print('⏰ Clock skew detected! Error message: ${result.message}');
      print('⏰ Waiting 6 seconds before retry...');
      
      // Wait 6 seconds to allow server time to "catch up" to the token's timestamp
      await Future.delayed(const Duration(seconds: 6));
      
      mLogger.d('⏰ Retrying login after clock skew delay...');
      print('⏰ Retrying login now...');
      
      // Retry the login
      result = await _attemptLogin(googleIdToken);
      
      if (result.status == DomainResultStatus.SUCCESS) {
        mLogger.i('✅ Login succeeded after clock skew retry!');
        print('✅ Login succeeded after retry!');
      } else {
        print('❌ Login failed after retry: ${result.message}');
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
      
      // Try to refresh the access token to validate the refresh token
      mLogger.d('validateAndRefreshTokens: Attempting token refresh...');
      final isRefreshSuccess = await _attemptTokenRefresh(refreshToken);
      
      if (!isRefreshSuccess) {
        // Refresh token is expired/invalid, clear all auth data
        mLogger.d('validateAndRefreshTokens: Refresh failed, clearing tokens');
        await mSecureStorage.saveAccessToken(null);
        await mSecureStorage.saveRefreshToken(null);
        return false;
      }
      
      mLogger.d('validateAndRefreshTokens: Tokens validated successfully');
      return true;
    } catch (e) {
      mLogger.e('validateAndRefreshTokens: Error - $e');
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
      
      return false;
    } catch (e) {
      mLogger.e('_attemptTokenRefresh: Failed - $e');
      return false;
    }
  }
}