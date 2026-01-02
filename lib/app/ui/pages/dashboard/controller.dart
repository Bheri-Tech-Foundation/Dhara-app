import 'dart:async';

// import 'package:common/app/domain/base/domain_result.dart';
// import 'package:common/app/domain/domain.dart';
// import 'package:common/app/types/types.dart';
import 'package:dharak_flutter/app/data/remote/api/interceptors/auth_interceptor.dart';
import 'package:dharak_flutter/app/domain/auth/auth_account_repo.dart';
import 'package:dharak_flutter/app/domain/base/domain_result.dart';
import 'package:dharak_flutter/app/domain/dictionary/repo.dart';
import 'package:dharak_flutter/app/domain/verse/repo.dart';
import 'package:dharak_flutter/core/services/verse_service.dart';
import 'package:dharak_flutter/core/services/dictionary_service.dart';
import 'package:dharak_flutter/core/services/unified_service.dart';
import 'package:dharak_flutter/app/types/user/user.dart';
import 'package:dharak_flutter/app/types/verse/language_pref.dart';
import 'package:dharak_flutter/app/domain/verse/constants.dart';
import 'package:dharak_flutter/app/ui/pages/dashboard/cubit_states.dart';
import 'package:dharak_flutter/app/ui/pages/dashboard/dashboard_args.dart';
// import 'package:common/app/types/account/account_common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
// import 'package:mithai_vendor/app/ui/pages/dashboard/cubit_states.dart';
// import 'package:mithai_vendor/app/ui/pages/dashboard/dashboard_args.dart';

class DashboardController extends Cubit<DashboardCubitState> {

  final VerseRepository mVersesRepo;

  final DictionaryRepository mDictionaryRepository;
  // final VendorsRepository mVendorsRepo;

  final AuthAccountRepository mAuthAccountRepository;
  final AuthInterceptor mAuthInterceptor;
  // StoreRepository mStoreRepo = Modular.get<StoreRepository>();

  StreamSubscription<bool>? _mLoginSubscription;
  StreamSubscription<UserRM?>? _mAccountCommonSubscription;
  StreamSubscription<bool>? _mAuthInterceptorSubscription;

  StreamSubscription<VersesLanguagePrefRM?>? _mVerseLanguagePrefSubscription;
  DashboardController({
    required this.mAuthAccountRepository,
    required this.mVersesRepo,
    required this.mDictionaryRepository,
    required this.mAuthInterceptor,
  }) : super(
         DashboardCubitState(
           // isLoading: true,
           // state: AuthRootUiConstants.STATE_DEFAULT,
           // purpose: AuthEmailUiConstants.STATE_DEFAULT
         ),
       ) {
    // Immediately set up subscriptions and load language preference
    _subscribeBloc();
    _loadLanguagePreferenceImmediately();
  }

  @override
  Future<void> close() {
    _mAccountCommonSubscription?.cancel();
    _mAuthInterceptorSubscription?.cancel();

    _mVerseLanguagePrefSubscription?.cancel();
    try {
      _mLoginSubscription?.cancel();
      _mLoginSubscription = null;
    } catch (e) {
    }

    // _mSearchOnChange.close();
    // _mEventRefresh.close();
    // _mEventMessage.close();
    // _mEventActionProgress.close();
    // _mEventNewChatMessage.close();
    return super.close();
  }

  Future<void> initData(DashboardArgsRequest args) async {
    // mCommuneId = args.communeId;
    // // _onTalesDetail(args!.tale!);
    // var communeBanker = args.communeBanker ?? await _getMyCommuneBanker(emit);
    // if (communeBanker != null) {

    // }

    // var uiState = state.state;
    // if (args.purpose == AuthRootUiConstants.PURPOSE_JOIN) {
    //   uiState = AuthRootUiConstants.STATE_SELECTOR;
    // } else if (args.purpose == AuthRootUiConstants.PURPOSE_GOOGLE_REDIRECT ||
    //     args.purpose == AuthRootUiConstants.PURPOSE_NONE) {
    //   uiState = AuthRootUiConstants.STATE_DEFAULT;
    // } else {
    //   uiState = AuthRootUiConstants.STATE_MODAL;
    // }

    // initSetup();

    // Subscribe to streams FIRST, then load data
    _subscribeBloc();
    
    await _load();
    emit(
      state.copyWith(
        // purpose: args.purpose,
        isInitialized: true,
        // state: uiState,
        isLoading: false,
      ),
    );

    // _mEventRefresh.sink.add(true);
  }

  initSetup() {
    mAuthAccountRepository.initSetup();

    _mLoginSubscription = mAuthAccountRepository.onGoogleWebLoggedIn.listen((
      onData,
    ) {
      if (onData) {
        // _getGoogleIdToken();

        emit(
          state.copyWith(
            googleWebLoggedInCounter: state.googleWebLoggedInCounter + 1,
          ),
        );
      }
    });
  }

  void setAuthPopupState(bool authPopupOpen) {
    emit(state.copyWith(authPopupOpen: authPopupOpen));
  }

  void _subscribeBloc() {
    
    // Prevent double subscription
    if (_mVerseLanguagePrefSubscription != null) {
      return;
    }
    
    _mAccountCommonSubscription = mAuthAccountRepository.mAccountUserObservable
        .listen((value) {
          if (state.user != value) {
            emit(state.copyWith(user: value));
          }
        });

    // ✅ FIX: Save auth interceptor listener to variable to prevent duplicates
    _mAuthInterceptorSubscription = mAuthInterceptor.eventLoginNeeded.listen((value) {
      emit(state.copyWith(loginNeededCounter: state.loginNeededCounter + 1));
    });

    _mVerseLanguagePrefSubscription = mVersesRepo.mLanguagePrefObservable
        .listen((value) {
          emit(state.copyWith(verseLanguagePref: value));
        });
  }

  void onTabChanged(String? currentTab) {
    emit(state.copyWith(currentTab: currentTab));
  }

  Future<void> onClickLogout() async {
    await mAuthAccountRepository.logout();
  }

  Future<void> onClickSwitchAccount() async {
    await mAuthAccountRepository.switchAccount();
    // Navigation will be handled by the BlocListener in DashboardPage
    // when the user state changes to null
  }

  void onNewSearchQuery(bool isForVerse, String? searchQuery) {
    if (isForVerse) {
      mVersesRepo.onNewSearchQuery(searchQuery);
    } else {
      mDictionaryRepository.onNewSearchQuery(searchQuery);
    }
  }

  Future<void> onVerseLanguageChange(String languageOutput) async {
    try {
      var result = await mVersesRepo.getlanguagePref(output: languageOutput);
      
      if (result.status == DomainResultStatus.SUCCESS) {
        // Clear relevant caches to ensure fresh results
        _clearSearchCaches();
        
        // Note: State update will happen automatically via _mVerseLanguagePrefSubscription listener
        // This eliminates the race condition between manual emit and repository stream
      }
    } catch (e) {
      // Silently handle error
    }
  }

  /// Clear search caches when language changes to ensure fresh results
  void _clearSearchCaches() {
    try {
      final verseService = VerseService.instance;
      verseService.clearCache();
      
      final dictionaryService = DictionaryService.instance;
      dictionaryService.clearCache();
      
      final unifiedService = UnifiedService.instance;
      unifiedService.clearCache();
      
    } catch (e) {
      print("⚠️ DashboardController: Error clearing caches - $e");
    }
  }

  /* **************************************************************************************
   *                                      domain 
   */

  /// Immediate language preference loading (called from constructor)
  void _loadLanguagePreferenceImmediately() {
    // First check if repository already has a cached language preference
    try {
      if (mVersesRepo.mLanguagePrefObservable.hasValue && mVersesRepo.mLanguagePrefObservable.value != null) {
        final cachedPref = mVersesRepo.mLanguagePrefObservable.value!;
        emit(state.copyWith(verseLanguagePref: cachedPref));
        return;
      }
    } catch (e) {
      // Silently handle error
    }
    
    // If no cached preference, load from API asynchronously
    _load().catchError((e) {
      // Set a default if loading fails
      _setDefaultLanguagePreference();
    });
  }

  /// Set default language preference if loading fails
  void _setDefaultLanguagePreference() {
    final defaultPref = VersesLanguagePrefRM(
      output: VersesConstants.LANGUAGE_DEFAULT,
    );
    emit(state.copyWith(verseLanguagePref: defaultPref));
  }

  _load() async {
    try {
      var result = await mVersesRepo.getlanguagePref();
      
      if (result.status == DomainResultStatus.SUCCESS && result.data != null) {
        emit(state.copyWith(verseLanguagePref: result.data));
      } else {
        _setDefaultLanguagePreference();
      }
    } catch (e) {
      _setDefaultLanguagePreference();
    }
  }

  /* *****************************************************************************
   *                              Form
   */
}
