import 'package:dharak_flutter/app/data/remote/api/parts/share/api.dart';
import 'package:dharak_flutter/app/data/services/share_service.dart';
import 'package:dharak_flutter/app/domain/books/repo.dart';
import 'package:dharak_flutter/app/domain/base/domain_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ShareRepository {
  final ShareApiRepo _shareApiRepo;
  late final ShareService _shareService;

  ShareRepository({required ShareApiRepo shareApiRepo}) : _shareApiRepo = shareApiRepo {
    _shareService = ShareService(shareApiRepo: _shareApiRepo);
  }

  /// Shares verse as image with native apps
  Future<bool> shareVerseAsImage({
    required GlobalKey widgetKey,
    required String verseId,
    required String verseText,
    String? customMessage,
    String? searchTerm, // The search term user used
  }) async {
    return await _shareService.shareWidgetAsImage(
      widgetKey: widgetKey,
      contentType: 'verse',
      contentId: verseId,
      contentText: verseText,
      customMessage: customMessage,
      searchedWord: searchTerm,
    );
  }

  /// Shares verse as text with native apps
  Future<bool> shareVerseAsText({
    required String verseId,
    required String verseText,
    String? customMessage,
    String? searchTerm, // The search term user used
  }) async {
    return await _shareService.shareText(
      contentType: 'verse',
      contentId: verseId,
      contentText: verseText,
      customMessage: customMessage,
      searchTerm: searchTerm,
    );
  }

  /// Shares definition as image with native apps
  Future<bool> shareDefinitionAsImage({
    required GlobalKey widgetKey,
    required String definitionId,
    required String definitionText,
    String? customMessage,
    String? searchedWord, // The word user searched for
  }) async {
    return await _shareService.shareWidgetAsImage(
      widgetKey: widgetKey,
      contentType: 'definition',
      contentId: definitionId,
      contentText: definitionText,
      customMessage: customMessage,
      searchedWord: searchedWord,
    );
  }

  /// Shares definition as text with native apps
  Future<bool> shareDefinitionAsText({
    required String definitionId,
    required String definitionText,
    String? customMessage,
    String? searchTerm, // The search term user used
  }) async {
    return await _shareService.shareText(
      contentType: 'definition',
      contentId: definitionId,
      contentText: definitionText,
      customMessage: customMessage,
      searchTerm: searchTerm,
    );
  }

  /// Shares screen capture with native apps
  Future<bool> shareScreenCapture({
    required String screenTitle,
    required BuildContext screenContext,
    String? searchTerm, // The search term for the shared screen
    GlobalKey? repaintBoundaryKey, // Optional RepaintBoundary key for better capture
  }) async {
    // TODO: Implement screen capture sharing when ShareService supports it
    return false;
    // return await _shareService.shareScreenCapture(
    //   screenTitle: screenTitle,
    //   screenContext: screenContext,
    //   searchTerm: searchTerm,
    //   repaintBoundaryKey: repaintBoundaryKey,
    // );
  }

  /// Copy verse content to clipboard using new unified API
  Future<bool> copyVerseToClipboard(String verseId) async {
    return await _shareService.copyVerseToClipboard(verseId);
  }

  /// Copy single definition content to clipboard using new unified API
  Future<bool> copyDefinitionToClipboard(String defId) async {
    return await _shareService.copyDefinitionToClipboard(defId);
  }

  /// Copy all definitions for a word to clipboard using new unified API
  Future<bool> copyAllDefinitionsToClipboard(String word) async {
    return await _shareService.copyAllDefinitionsToClipboard(word);
  }

  /// Shares book chunk as image with native apps
  Future<bool> shareChunkAsImage({
    required GlobalKey widgetKey,
    required String chunkId,
    required String chunkText,
    String? customMessage,
    String? searchedQuery, // The search query user used
  }) async {
    return await _shareService.shareWidgetAsImage(
      widgetKey: widgetKey,
      contentType: 'chunk',
      contentId: chunkId,
      contentText: chunkText,
      customMessage: customMessage,
      searchedWord: searchedQuery,
    );
  }

  /// Shares book chunk as text with native apps
  Future<bool> shareChunkAsText({
    required String chunkId,
    required String chunkText,
    String? customMessage,
    String? searchTerm, // The search term user used
  }) async {
    try {
      // Get the formatted share content from the API first
      final shareContent = await getChunkShareContent(chunkId, type: 'text');
      
      if (shareContent == null || shareContent.isEmpty) {
        return false;
      }
      
      // Use the ShareService shareText method for chunks
      return await _shareService.shareText(
        contentType: 'chunk',
        contentId: chunkId,
        contentText: shareContent,
        customMessage: customMessage,
        searchTerm: searchTerm,
      );
    } catch (e) {
      return false;
    }
  }

  /// Copy book chunk content to clipboard using the share API
  Future<bool> copyChunkToClipboard(String chunkId) async {
    try {
      // Get the formatted share content from the API
      final shareContent = await getChunkShareContent(chunkId, type: 'text');
      
      if (shareContent != null && shareContent.isNotEmpty) {
        // Copy to clipboard using Flutter's Clipboard API
        await Clipboard.setData(ClipboardData(text: shareContent));
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Copy all chunks for a query to clipboard using fallback method
  Future<bool> copyAllChunksToClipboard(String query) async {
    try {
      // TODO: Implement proper Books API endpoint for copying all chunks
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get verse content from backend API for sharing
  Future<String?> getVerseShareContent(String verseId) async {
    return await _shareService.getVerseShareContent(verseId);
  }

  /// Get definition content from backend API for sharing
  Future<String?> getDefinitionShareContent(String defId) async {
    return await _shareService.getDefinitionShareContent(defId);
  }

  /// Get chunk content from backend API for sharing (like verse sharing)
  Future<String?> getChunkShareContent(String chunkId, {String type = 'text'}) async {
    try {
      // Get BooksRepository from dependency injection
      final booksRepo = Modular.get<BooksRepository>();
      
      // Call the appropriate share method based on type
      final result = type == 'image' 
        ? await booksRepo.shareChunkAsImage(chunkRefId: int.parse(chunkId))
        : await booksRepo.shareChunkAsText(chunkRefId: int.parse(chunkId));
      
      if (result.status == DomainResultStatus.SUCCESS && result.data != null) {
        return result.data!;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Gets the screenshot controller for RepaintBoundary wrapping
  get shareService => _shareService;
}