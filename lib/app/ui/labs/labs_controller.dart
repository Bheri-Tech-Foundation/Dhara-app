import 'dart:async';
import 'dart:developer';

import 'package:dharak_flutter/app/domain/auth/auth_account_repo.dart';
import 'package:dharak_flutter/app/domain/base/domain_result.dart';
import 'package:dharak_flutter/app/domain/dictionary/repo.dart';
import 'package:dharak_flutter/app/domain/verse/repo.dart';
import 'package:dharak_flutter/app/ui/labs/cubit_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class LabsController extends Cubit<LabsCubitState> {
  // LabsController() : super(0);

  final DictionaryRepository mDictionaryRepository;
  final VerseRepository mVerseRepository;
  final AuthAccountRepository mAuthAccountRepository;
  var mLogger = Logger();

  bool isRecording = false;
  
  StreamSubscription<bool>? _mLoginSubscription;

  //{required this.authApiRepo}
  // {required this.mAuthAccountRepo}
  LabsController({
    required this.mDictionaryRepository,
    required this.mVerseRepository,
    required this.mAuthAccountRepository,
  }) : super(LabsCubitState()) {
    // counterStream = _controller.stream;
  }

  @override
  Future<void> close() {
     try {
      _mLoginSubscription?.cancel();
      _mLoginSubscription = null;
    } catch (e) {
    }
    
    return super.close();


  }



  initSetup(){
    mAuthAccountRepository.initSetup();

    _mLoginSubscription = mAuthAccountRepository.onGoogleWebLoggedIn.listen((onData){
      if(onData){
        _getGoogleIdToken();
      }

    });
  }

  check() {
    mLogger.i("LabsController: message");
  }

  // @override
  // Future<void> close() {
  //   return super.close();
  // }

  googleLogin() async {
    try {
      emit(state.copyWith(idToken: null));
      var result = await mAuthAccountRepository.signInWithGoogle();

    

      // var token = await mAuthAccountRepository.getIdToken();

      // print("googleLogin: idtoken");

      // print(token);
    } catch (e) {}
  }

  
  Future<void> _getGoogleIdToken() async {

      emit(state.copyWith(idToken: null));

       var token = await mAuthAccountRepository.getIdToken();
      //  emit(state)

    
      emit(state.copyWith(idToken: token));
      
      
  }

  getDefinitions() async {
    var result = await mDictionaryRepository.getDefinition(word: "nad");

    if (result.status == DomainResultStatus.SUCCESS && result.data != null) {
      // emit(state.copyWith(order: result.data));
      return true;
    }

    return false;
  }

  getVerses() async {
    var result = await mVerseRepository.getVerses(inputStr: "agnimeele");

    if (result.status == DomainResultStatus.SUCCESS && result.data != null) {
      inspect(result.data);
      // emit(state.copyWith(order: result.data));
      return true;
    }

    return false;
  }

  getVerseStreams() async {
    var result = await mVerseRepository.getVersesStream(inputStr: "agnimeele", onItem:({footer, header, item}) => {
    },);

    if (result.status == DomainResultStatus.SUCCESS && result.data != null) {
      inspect(result.data);
      // emit(state.copyWith(order: result.data));
      return true;
    }

    return false;
  }

  void checkWordVerse() {}
  
}
