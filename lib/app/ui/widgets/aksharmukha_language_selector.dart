import 'package:dharak_flutter/app/data/services/supported_languages_service.dart';
import 'package:dharak_flutter/app/domain/verse/constants.dart';
import 'package:dharak_flutter/app/types/verse/language_pref.dart';
import 'package:dharak_flutter/app/ui/pages/dashboard/controller.dart';
import 'package:dharak_flutter/app/ui/pages/dashboard/cubit_states.dart';
import 'package:dharak_flutter/res/styles/text_styles.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:dharak_flutter/res/values/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// Reusable "Powered by Aksharmukha" language selector widget
/// Can be used across all verse result areas for consistent language selection
/// This widget automatically reacts to language changes via BlocBuilder
class AksharmukhaLanguageSelector extends StatelessWidget {
  final AppThemeColors themeColors;
  final bool isCompact;
  final bool showPoweredBy;
  
  const AksharmukhaLanguageSelector({
    super.key,
    required this.themeColors,
    this.isCompact = true,
    this.showPoweredBy = true,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap in BlocBuilder to automatically react to language changes
    return BlocBuilder<DashboardController, DashboardCubitState>(
      bloc: Modular.get<DashboardController>(),
      buildWhen: (previous, current) {
        return current.verseLanguagePref != previous.verseLanguagePref;
      },
      builder: (context, state) {
        if (isCompact) {
          return _buildCompactSelector(state.verseLanguagePref);
        } else {
          return _buildFullSelector(state.verseLanguagePref);
        }
      },
    );
  }

  /// Compact version - small "Powered by Aksharmukha" + language dropdown
  Widget _buildCompactSelector(VersesLanguagePrefRM? currentLanguagePref) {
    final currentLanguage = currentLanguagePref?.output ?? VersesConstants.LANGUAGE_DEFAULT;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(TdResDimens.dp_6),
        border: Border.all(
          color: themeColors.primary.withAlpha(0x33),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPoweredBy) ...[
            Text(
              'Powered by ',
              style: TdResTextStyles.caption.copyWith(
                color: themeColors.onSurfaceMedium,
                fontSize: 10,
              ),
            ),
            Text(
              'Aksharmukha',
              style: TdResTextStyles.caption.copyWith(
                color: themeColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 1,
              height: 12,
              color: themeColors.onSurfaceMedium.withAlpha(0x33),
            ),
            const SizedBox(width: 6),
          ],
          _buildLanguageDropdown(currentLanguage),
        ],
      ),
    );
  }

  /// Full version - more prominent display
  Widget _buildFullSelector(VersesLanguagePrefRM? currentLanguagePref) {
    final currentLanguage = currentLanguagePref?.output ?? VersesConstants.LANGUAGE_DEFAULT;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(TdResDimens.dp_8),
        boxShadow: [
          BoxShadow(
            color: themeColors.primary.withAlpha(0x1a),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPoweredBy) ...[
            Icon(
              Icons.translate,
              size: 16,
              color: themeColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Powered by ',
              style: TdResTextStyles.caption.copyWith(
                color: themeColors.onSurfaceMedium,
                fontSize: 11,
              ),
            ),
            Text(
              'Aksharmukha',
              style: TdResTextStyles.caption.copyWith(
                color: themeColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
          ],
          _buildLanguageDropdown(currentLanguage),
        ],
      ),
    );
  }

  /// Language dropdown component - Working implementation from QuickVerse
  Widget _buildLanguageDropdown(String currentLanguage) {
    final dashboardController = Modular.get<DashboardController>();
    
    return Container(
      height: isCompact ? 32 : 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TdResDimens.dp_4),
        border: Border.all(
          color: themeColors.primary.withAlpha(0x33),
          width: 1,
        ),
        color: themeColors.primary.withAlpha(0x08),
      ),
      child: DropdownButton<String>(
        key: ValueKey('aksharmukha_language_dropdown_$currentLanguage'), // Force rebuild on language change
        value: currentLanguage,
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: isCompact ? 12 : 16,
          color: themeColors.primary,
        ),
        underline: Container(),
        style: TdResTextStyles.caption.copyWith(
          color: themeColors.primary,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: themeColors.surface,
        borderRadius: BorderRadius.circular(TdResDimens.dp_8),
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 8),
        onChanged: (String? value) {
          if (value != null) {
            dashboardController.onVerseLanguageChange(value);
          }
        },
        selectedItemBuilder: (context) => _getSupportedLanguages().entries.map<Widget>((entry) {
          // Show compact script name for selected item
          return Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.translate,
                  size: isCompact ? 12 : 14,
                  color: themeColors.primary,
                ),
                SizedBox(width: isCompact ? 3 : 4),
                Text(
                  _getCompactScriptName(entry.key),
                  style: TdResTextStyles.caption.copyWith(
                    color: themeColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: isCompact ? 9 : 10,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        items: _getSupportedLanguages().entries.map<DropdownMenuItem<String>>((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Container(
              constraints: BoxConstraints(maxWidth: 200),
              child: Text(
                entry.value,
                style: TdResTextStyles.h5.copyWith(
                  color: themeColors.onSurface,
                  fontSize: isCompact ? 12 : 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Get supported languages from service
  Map<String, String> _getSupportedLanguages() {
    try {
      return Modular.get<SupportedLanguagesService>().getSupportedLanguages();
    } catch (e) {
      // Fallback to constants if service not available
      return VersesConstants.LANGUAGE_LABELS_MAP;
    }
  }

  /// Get compact language label for display
  String _getLanguageLabel(String languageId) {
    // Map all 15 supported languages to short labels
    switch (languageId) {
      case VersesConstants.LANGUAGE_DEVANAGARI:
        return 'देव';
      case VersesConstants.LANGUAGE_BENGALI:
        return 'বাং';
      case VersesConstants.LANGUAGE_TAMIL:
        return 'தமிழ்';
      case VersesConstants.LANGUAGE_TELUGU:
        return 'తెలుగు';
      case VersesConstants.LANGUAGE_GUJARATI:
        return 'ગુજ';
      case VersesConstants.LANGUAGE_KANNADA:
        return 'ಕನ್ನಡ';
      case VersesConstants.LANGUAGE_MALAYALAM:
        return 'മലയാളം';
      case VersesConstants.LANGUAGE_GURMUKHI:
        return 'ਗੁਰਮੁਖੀ';
      case VersesConstants.LANGUAGE_ASSAMESE:
        return 'অসমীয়া';
      case VersesConstants.LANGUAGE_IAST:
        return 'IAST';
      case VersesConstants.LANGUAGE_HARVARD_KYOTO:
        return 'HK';
      case VersesConstants.LANGUAGE_ITRANS:
        return 'ITRANS';
      case VersesConstants.LANGUAGE_SLP1:
        return 'SLP1';
      case VersesConstants.LANGUAGE_VELTHUIS:
        return 'VEL';
      case VersesConstants.LANGUAGE_WX:
        return 'WX';
      // Legacy support
      case VersesConstants.LANGUAGE_HINDI:
        return 'देव';
      case VersesConstants.LANGUAGE_ROMAN:
        return 'IAST';
      case VersesConstants.LANGUAGE_TELEGU:
        return 'తెలుగు';
      // Handle backend response names that might not match constants
      case 'Tamil':
        return 'தமிழ்';
      case 'Devanagari':
        return 'देव';
      case 'Bengali':
        return 'বাং';
      case 'Telugu':
        return 'తెలుగు';
      case 'Gujarati':
        return 'ગુજ';
      case 'Kannada':
        return 'ಕನ್ನಡ';
      case 'Malayalam':
        return 'മലയാളം';
      case 'Gurmukhi':
        return 'ਗੁਰਮੁਖੀ';
      case 'Assamese':
        return 'অসমীয়া';
      default:
        // For unknown languages, try to get a short version
        final fullName = VersesConstants.LANGUAGE_LABELS_MAP[languageId] ?? languageId;
        if (fullName.length <= 4) return fullName;
        return fullName.substring(0, 3).toUpperCase();
    }
  }

  /// Get compact script name for display in dropdown - Working implementation from QuickVerse
  String _getCompactScriptName(String language) {
    switch (language) {
      case VersesConstants.LANGUAGE_DEVANAGARI:
        return 'देव';
      case VersesConstants.LANGUAGE_BENGALI:
        return 'বাং';
      case VersesConstants.LANGUAGE_GUJARATI:
        return 'ગુજ';
      case VersesConstants.LANGUAGE_GURMUKHI:
        return 'ਗੁਰ';
      case VersesConstants.LANGUAGE_KANNADA:
        return 'ಕನ್ನ';
      case VersesConstants.LANGUAGE_MALAYALAM:
        return 'മল';
      case VersesConstants.LANGUAGE_TAMIL:
        return 'தமிழ்';
      case VersesConstants.LANGUAGE_TELUGU:
        return 'తెలు';
      case VersesConstants.LANGUAGE_ASSAMESE:
        return 'অসম';
      case VersesConstants.LANGUAGE_IAST:
        return 'IAST';
      case VersesConstants.LANGUAGE_HARVARD_KYOTO:
        return 'HK';
      case VersesConstants.LANGUAGE_ITRANS:
        return 'ITRANS';
      case VersesConstants.LANGUAGE_SLP1:
        return 'SLP1';
      case VersesConstants.LANGUAGE_VELTHUIS:
        return 'VEL';
      case VersesConstants.LANGUAGE_WX:
        return 'WX';
      // Legacy support
      case VersesConstants.LANGUAGE_HINDI:
        return 'देव';
      case VersesConstants.LANGUAGE_ROMAN:
        return 'IAST';
      case VersesConstants.LANGUAGE_TELEGU:
        return 'তেলু';
      // Handle backend response names that might not match constants
      case 'Tamil':
        return 'தமிழ்';
      case 'Devanagari':
        return 'देव';
      case 'Bengali':
        return 'বাং';
      case 'Telugu':
        return 'তেলু';
      case 'Gujarati':
        return 'ગુજ';
      case 'Kannada':
        return 'ಕನ್ನ';
      case 'Malayalam':
        return 'മल';
      case 'Gurmukhi':
        return 'ਗੁਰ';
      case 'Assamese':
        return 'অসম';
      case 'IAST':
        return 'IAST';
      case 'Harvard-Kyoto':
        return 'HK';
      case 'ITRANS':
        return 'ITRANS';
      case 'SLP1':
        return 'SLP1';
      case 'Velthuis':
        return 'VEL';
      case 'WX':
        return 'WX';
      default:
        // For unknown languages, try to get a short version from the full name
        final fullName = VersesConstants.LANGUAGE_LABELS_MAP[language] ?? language;
        if (fullName.length <= 4) return fullName.toUpperCase();
        return fullName.substring(0, 3).toUpperCase();
    }
  }
}
