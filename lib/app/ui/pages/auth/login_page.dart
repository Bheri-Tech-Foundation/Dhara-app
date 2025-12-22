import 'package:dharak_flutter/app/ui/sections/auth/constants.dart';
import 'package:dharak_flutter/app/ui/sections/auth/login/google/args.dart';
import 'package:dharak_flutter/app/ui/sections/auth/login/google/controller.dart';
import 'package:dharak_flutter/app/ui/sections/auth/login/google/cubit_states.dart';
import 'package:dharak_flutter/app/providers/google/signin-button/index.dart';
import 'package:dharak_flutter/res/styles/text_styles.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:dharak_flutter/res/theme/app_theme_display.dart';
import 'package:dharak_flutter/res/theme/theme_helper.dart';
import 'package:dharak_flutter/res/values/dimens.dart';
import 'package:dharak_flutter/res/values/gaps.dart';
import 'package:dharak_flutter/app/domain/auth/auth_account_repo.dart';
import 'package:dharak_flutter/app/domain/base/domain_result.dart';
import 'package:dharak_flutter/app/ui/constants.dart';
import 'package:dharak_flutter/res/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late GoogleLoginController mBloc;
  late AppThemeColors themeColors;
  late AppThemeDisplay appThemeDisplay;

  @override
  void initState() {
    super.initState();
    
    // Get the auth repository dependency
    final authRepo = Modular.get<AuthAccountRepository>();
    mBloc = GoogleLoginController(mAuthAccountRepository: authRepo);
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Check if user is already authenticated
      _checkExistingAuthState();
      
      // Initialize the Google login controller with PURPOSE_GOOGLE_LOGIN
      mBloc.initData(GoogleLoginArgsRequest(
        purpose: AuthUiConstants.PURPOSE_GOOGLE_LOGIN,
      ));
    });
  }

  /// Check if user is already authenticated and redirect to app
  Future<void> _checkExistingAuthState() async {
    try {
      final authRepo = Modular.get<AuthAccountRepository>();
      authRepo.initSetup();
      
      // Quick check without delay
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Validate tokens - this will clear expired tokens automatically
      final hasValidTokens = await authRepo.validateAndRefreshTokens();
      var user = authRepo.mAccountUserObservable.value;
      
      bool isAuthenticated = hasValidTokens && 
                           user != null && 
                           (user.email?.isNotEmpty == true || 
                            user.name?.isNotEmpty == true);
      
      if (mounted && isAuthenticated) {
        Modular.to.pushReplacementNamed('/Dhara/quicksearch');
      }
    } catch (e) {
      // Continue with normal login flow
    }
  }

  @override
  Widget build(BuildContext context) {
    _prepareTheme(context);
    
    return Scaffold(
      backgroundColor: themeColors.surface,
      body: Stack(
        children: [
          MultiBlocListener(
            listeners: [
              BlocListener<GoogleLoginController, GoogleLoginCubitState>(
                bloc: mBloc,
                listenWhen: (previous, current) => previous.result != current.result,
                listener: (context, state) {
                  if (state.result != null && 
                      state.result!.resultCode == "RESULT_SUCCESS") {
                    // Complete backend authentication with the Google ID token
                    _completeBackendLogin(state.result!.idToken);
                  }
                },
              ),
            ],
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: TdResDimens.dp_32,
                  vertical: TdResDimens.dp_24,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App Header
                      _buildAppHeader(),
                      
                      TdResGaps.v_64,
                      
                      // Google Sign In Button
                      _buildSignInSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Loading overlay during authentication
          BlocBuilder<GoogleLoginController, GoogleLoginCubitState>(
            bloc: mBloc,
            buildWhen: (previous, current) => 
                current.isInProgress != previous.isInProgress,
            builder: (context, state) {
              if (state.isInProgress == true) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(TdResDimens.dp_32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                TdResColors.colorDharaBlue,
                              ),
                            ),
                            SizedBox(height: TdResDimens.dp_20),
                            Text(
                              'Signing you in...',
                              style: TdResTextStyles.h3SemiBold.copyWith(
                                color: themeColors.onSurface,
                              ),
                            ),
                            SizedBox(height: TdResDimens.dp_8),
                            Text(
                              'Please wait a moment',
                              style: TdResTextStyles.caption.copyWith(
                                color: themeColors.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Get last account information from secure storage
  Future<Map<String, String?>> _getLastAccountInfo() async {
    try {
      final authRepo = Modular.get<AuthAccountRepository>();
      final name = await authRepo.mSecureStorage.getDisplayName();
      final email = await authRepo.mSecureStorage.getEmail();
      final picture = await authRepo.mSecureStorage.getPicture();
      
      
      return {
        'name': name != null && name.isNotEmpty ? name : null,
        'email': email != null && email.isNotEmpty ? email : null,
        'picture': picture != null && picture.isNotEmpty ? picture : null,
      };
    } catch (e) {
      return {'name': null, 'email': null, 'picture': null};
    }
  }

  /// Complete the backend authentication process after Google sign-in
  Future<void> _completeBackendLogin(String? googleIdToken) async {
    if (googleIdToken == null) {
      // Clear loading state
      mBloc.emit(mBloc.state.copyWith(isInProgress: false));
      return;
    }

    try {
      // Get the auth repository and complete the login
      final authRepo = Modular.get<AuthAccountRepository>();
      final result = await authRepo.login(googleIdToken: googleIdToken);
      
      // Clear loading state
      mBloc.emit(mBloc.state.copyWith(isInProgress: false));
      
      if (result.status == DomainResultStatus.SUCCESS) {
        // Wait a moment to ensure the UI state is updated
        await Future.delayed(const Duration(milliseconds: 100));
        
        if (mounted) {
          // Login successful, navigate to main app with default tab (QuickSearch)
          Modular.to.pushReplacementNamed('/Dhara/quicksearch');
        }
      } else {
        // Show user-friendly error message (no technical jargon)
        String errorMsg = _getUserFriendlyErrorMessage(result.message);
        _showErrorMessage(errorMsg);
      }
    } catch (e) {
      // Clear loading state
      mBloc.emit(mBloc.state.copyWith(isInProgress: false));
      _showErrorMessage("Something went wrong. Please try logging in again.");
    }
  }
  
  /// Convert technical error messages to user-friendly ones
  String _getUserFriendlyErrorMessage(String? technicalMessage) {
    if (technicalMessage == null || technicalMessage.isEmpty) {
      return "Please try logging in again.";
    }
    
    // Check for specific error patterns and return friendly messages
    final lowerMessage = technicalMessage.toLowerCase();
    
    if (lowerMessage.contains('account') && lowerMessage.contains('issue')) {
      return technicalMessage; // Already user-friendly from backend
    } else if (lowerMessage.contains('invalid') || 
               lowerMessage.contains('token') ||
               lowerMessage.contains('bad request') ||
               lowerMessage.contains('400')) {
      return "Please try logging in again.";
    } else if (lowerMessage.contains('network') || 
               lowerMessage.contains('connection') ||
               lowerMessage.contains('timeout')) {
      return "Please check your internet connection and try again.";
    } else if (lowerMessage.contains('server') || 
               lowerMessage.contains('500') ||
               lowerMessage.contains('503')) {
      return "Our servers are experiencing issues. Please try again in a moment.";
    } else if (lowerMessage.contains('unauthorized') || 
               lowerMessage.contains('401') ||
               lowerMessage.contains('403')) {
      return "Please try logging in again.";
    } else {
      // Generic friendly message for any other error
      return "Something went wrong. Please try again.";
    }
  }

  /// Show error message to user
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        // Dhara Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: themeColors.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: themeColors.onSurface.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
                spreadRadius: 0,
              ),
            ],
          ),
          padding: EdgeInsets.all(TdResDimens.dp_16),
          child: Image.asset(
            "assets/img/Dhara_logo.png",
            fit: BoxFit.contain,
          ),
        ),
        
        TdResGaps.v_32,
        
        // App name
        Text(
          'Dhārā',
          style: TdResTextStyles.h1Bold.copyWith(
            color: TdResColors.colorDharaBlue,
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        
        TdResGaps.v_12,
        
        // Professional tagline
        Text(
          'AI Powered Search',
          style: TdResTextStyles.h2SemiBold.copyWith(
            color: themeColors.onSurface.withOpacity(0.8),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        
        TdResGaps.v_8,
        
        Text(
          'Definitions & Verses',
          style: TdResTextStyles.p1.copyWith(
            color: themeColors.onSurface.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }


  Widget _buildSignInSection() {
    return Column(
      children: [
        // Simple header text
        FutureBuilder<Map<String, String?>>(
          future: _getLastAccountInfo(),
          builder: (context, snapshot) {
            final hasLastAccount = snapshot.hasData && snapshot.data!['email'] != null;
            
            return Column(
              children: [
                Text(
                  hasLastAccount ? 'Continue with your account:' : 'Sign in with Google to continue',
                  style: TdResTextStyles.p2.copyWith(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                TdResGaps.v_20,
              ],
            );
          },
        ),
        
        BlocBuilder<GoogleLoginController, GoogleLoginCubitState>(
          bloc: mBloc,
          buildWhen: (previous, current) => 
              current.isInProgress != previous.isInProgress,
          builder: (context, state) {
            return FutureBuilder<Map<String, String?>>(
              future: _getLastAccountInfo(),
              builder: (context, accountSnapshot) {
                final hasLastAccount = accountSnapshot.hasData && accountSnapshot.data!['email'] != null;
                
                return Column(
                  children: [
                    // Hide "Sign in with last account" on all platforms to avoid clock skew issues
                    // Always use account picker for reliable authentication
                    if (false) ...[
                      // Sign in with last account button (direct login) - DISABLED
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 280),
                        child: ElevatedButton(
                          onPressed: (state.isInProgress == true) ? null : () async {
                            await mBloc.onSubmitSilent(); // Silent login with last account
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.alphaBlend(
                              themeColors.back.withAlpha(0x08),
                              themeColors.surface,
                            ),
                            foregroundColor: themeColors.onSurface,
                            elevation: 1,
                            shadowColor: Colors.grey.withOpacity(0.3),
                            padding: EdgeInsets.symmetric(
                              horizontal: TdResDimens.dp_16,
                              vertical: TdResDimens.dp_12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(TdResDimens.dp_8),
                              side: BorderSide(
                                color: themeColors.onSurface.withOpacity(0.2),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Profile picture or fallback icon
                              ClipOval(
                                child: accountSnapshot.data!['picture'] != null && accountSnapshot.data!['picture']!.isNotEmpty
                                  ? Image.network(
                                      accountSnapshot.data!['picture']!,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return SizedBox(
                                          width: 32,
                                          height: 32,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.account_circle,
                                          color: themeColors.onSurface.withOpacity(0.6),
                                          size: 32,
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.account_circle,
                                      color: themeColors.onSurface.withOpacity(0.6),
                                      size: 32,
                                    ),
                              ),
                              TdResGaps.h_12,
                              // User info (name and email)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Sign in as ${accountSnapshot.data!['name'] ?? 'User'}',
                                      style: TdResTextStyles.button.copyWith(
                                        color: themeColors.onSurface,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (accountSnapshot.data!['email'] != null) ...[
                                      SizedBox(height: 2),
                                      Text(
                                        accountSnapshot.data!['email']!,
                                        style: TdResTextStyles.caption.copyWith(
                                          color: themeColors.onSurface.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Google logo on the right
                              SvgPicture.asset(
                                'assets/svg/google_icon.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      TdResGaps.v_12,
                      
                      // Use different account button
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 280),
                        child: OutlinedButton.icon(
                          onPressed: (state.isInProgress == true) ? null : () async {
                            await mBloc.onSubmitWithAccountPicker();
                          },
                          icon: Icon(
                            Icons.account_circle_outlined,
                            size: 20,
                            color: themeColors.onSurface.withOpacity(0.7),
                          ),
                          label: Text(
                            'Choose different account',
                            style: TdResTextStyles.button.copyWith(
                              color: themeColors.onSurface.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color.alphaBlend(
                              themeColors.back.withAlpha(0x08),
                              themeColors.surface,
                            ),
                            elevation: 1,
                            shadowColor: Colors.grey.withOpacity(0.2),
                            padding: EdgeInsets.symmetric(
                              horizontal: TdResDimens.dp_20,
                              vertical: TdResDimens.dp_14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(TdResDimens.dp_12),
                            ),
                            side: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // First time users - show regular Google sign-in
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 280),
                        child: googleSignInButton(
                          onPressed: (state.isInProgress == true) ? null : () async {
                            await mBloc.onSubmitWithAccountPicker(); // Show account picker for first time
                          },
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _prepareTheme(BuildContext context) {
    themeColors = Theme.of(context).extension<AppThemeColors>() ??
        AppThemeColors.seedColor(seedColor: const Color(0xFF6CE18D), isDark: Theme.of(context).brightness == Brightness.dark);
    appThemeDisplay = Theme.of(context).extension<AppThemeDisplay>() ??
        TdThemeHelper.prepareThemeDisplay(context);
  }
}
