import 'package:dharak_flutter/app/domain/auth/auth_account_repo.dart';
import 'package:dharak_flutter/app/ui/constants.dart';
import 'package:dharak_flutter/app/ui/sections/auth/constants.dart';
import 'package:dharak_flutter/app/ui/sections/auth/login/google/args.dart';
import 'package:dharak_flutter/app/ui/sections/auth/login/google/cubit_states.dart';
import 'package:dharak_flutter/app/ui/sections/auth/login/google/modal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoogleLoginController extends Cubit<GoogleLoginCubitState> {
  final AuthAccountRepository mAuthAccountRepository;

  GoogleLoginController({required this.mAuthAccountRepository})
    : super(GoogleLoginCubitState(state: GoogleLoginModal.STATE_DEFAULT));

  @override
  void dispose() {
    // Clean up any resources if needed
  }

  @override
  Future<void> close() {
    return super.close();
  }

  Future<void> initData(GoogleLoginArgsRequest args) async {
    var purpose = args.purpose;
    var uiState = state.state;

    emit(
      state.copyWith(
        purpose: purpose,
        isInitialized: true,
        state: uiState,
        isLoading: false,
      ),
    );

    if (purpose == AuthUiConstants.PURPOSE_GOOGLE_LOGIN_DIRECT) {
      onSubmit();
    } else if (purpose == AuthUiConstants.PURPOSE_GOOGLE_AFTER_LOGIN) {
      afterGoogleUILogin().then((onValue) {});
    }
  }

  void setModalState(int stateModal) {
    if (state.state == stateModal) {
      return;
    }

    emit(state.copyWith(state: stateModal));
  }

  int getModalState() {
    return state.state;
  }

  void end() {
    emit(
      state.copyWith(
        result: GoogleLoginArgsResult(
          resultCode: "RESULT_CANCELED",
        ),
      ),
    );
  }

  onSubmit() {
    Future.delayed(Duration(milliseconds: 100), () async {
      await directLogin();

      if (state.idToken != null) {
        onSuccess();
      } else {
        onFailed("unable to google login");
      }
    });
  }

  onSubmitWithAccountPicker() {
    // Set loading state immediately when user clicks sign-in
    emit(state.copyWith(isInProgress: true));
    
    Future.delayed(Duration(milliseconds: 100), () async {
      await _getGoogleIdTokenWithAccountPicker();

      if (state.idToken != null) {
        // Keep isInProgress true - backend login will happen next
        onSuccess();
      } else {
        // Clear loading state on failure
        emit(state.copyWith(isInProgress: false));
        onFailed("unable to login with selected account");
      }
    });
  }

  onSubmitSilent() {
    // Set loading state immediately
    emit(state.copyWith(isInProgress: true));
    
    Future.delayed(Duration(milliseconds: 100), () async {
      await _getGoogleIdTokenSilent();

      if (state.idToken != null) {
        // Keep isInProgress true - backend login will happen next
        onSuccess();
      } else {
        // Clear loading state on failure
        emit(state.copyWith(isInProgress: false));
        onFailed("unable to silent login");
      }
    });
  }

  Future<void> _getGoogleIdToken() async {
    try {
      var token = await mAuthAccountRepository.getIdToken();
      emit(state.copyWith(idToken: token));
    } catch (e) {
    }
  }

  Future<void> _getGoogleIdTokenWithAccountPicker() async {
    try {
      var token = await mAuthAccountRepository.getIdTokenWithAccountPicker();
      emit(state.copyWith(idToken: token));
    } catch (e) {
    }
  }

  Future<void> _getGoogleIdTokenSilent() async {
    try {
      var token = await mAuthAccountRepository.getIdTokenSilent();
      emit(state.copyWith(idToken: token));
    } catch (e) {
    }
  }

  Future<bool> afterGoogleUILogin() async {
    try {
      emit(state.copyWith(idToken: null));
      await _getGoogleIdToken();

      if (state.idToken != null) {
        onSuccess();
      } else {
        onFailed("unable to google login");
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> directLogin() async {

    try {
      emit(state.copyWith(idToken: null));
      var result = await mAuthAccountRepository.signInWithGoogle();

      await _getGoogleIdToken();

      return true;
    } catch (e) {
      return false;
    }
  }

  /* *********************************************************************************************************
| *                                            response Args
| */

  void onSuccess() {
    emit(
      state.copyWith(
        result: GoogleLoginArgsResult(
          resultCode: "RESULT_SUCCESS",
          idToken: state.idToken,
        ),
      ),
    );
  }

  void onFailed(String message) {
    setModalState(GoogleLoginModal.STATE_DEFAULT);

    emit(
      state.copyWith(
        result: GoogleLoginArgsResult(
          resultCode: "RESULT_FAILED",
        ),
        isInProgress: false, // Clear loading state on failure
      ),
    );
  }
}