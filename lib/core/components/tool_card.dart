import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:dharak_flutter/app/data/services/supported_languages_service.dart';
import 'package:dharak_flutter/app/data/services/tester_mode_service.dart';
import 'package:dharak_flutter/app/data/voting/voting_repository.dart';
import 'package:dharak_flutter/app/domain/verse/constants.dart';
import 'package:dharak_flutter/app/types/books/book_chunk.dart';
import 'package:dharak_flutter/app/types/dictionary/word_definitions.dart';
import 'package:dharak_flutter/app/types/unified/unified_response.dart';
import 'package:dharak_flutter/app/types/verse/verse.dart';
import 'package:dharak_flutter/app/types/voting/vote_request.dart';
import 'package:dharak_flutter/app/types/voting/vote_type.dart';
import 'package:dharak_flutter/app/ui/pages/dashboard/controller.dart';
import 'package:dharak_flutter/app/ui/pages/dashboard/cubit_states.dart';
import 'package:dharak_flutter/app/ui/widgets/missing_count_modal.dart';
import 'package:dharak_flutter/app/ui/widgets/scroll_hint_widget.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:dharak_flutter/res/theme/app_theme_display.dart';
import 'package:dharak_flutter/res/theme/theme_helper.dart';
import 'package:dharak_flutter/res/styles/text_styles.dart';
import 'package:dharak_flutter/res/values/dimens.dart';
import 'package:dharak_flutter/app/ui/pages/books/parts/item_lightweight.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dharak_flutter/core/components/word_definition_card.dart';
import 'package:dharak_flutter/core/components/verse_card.dart';
import 'package:dharak_flutter/core/components/prashna_tool_card_content.dart';
import 'package:dharak_flutter/core/models/graph_search_result.dart';
import 'package:dharak_flutter/core/controllers/unified_controller.dart';
import 'package:dharak_flutter/core/services/dictionary_service.dart';
import 'package:dharak_flutter/core/services/verse_service.dart';
import 'package:dharak_flutter/core/services/books_service.dart';
import 'package:dharak_flutter/app/domain/books/repo.dart';
import 'package:dharak_flutter/app/domain/base/domain_result.dart';
import 'package:dharak_flutter/app/types/books/book_chunk_nav_result.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/config/all.dart';

enum ExpandableToolType { definition, verse, chunk, prashna, graph }

extension ExpandableToolTypeExtension on ExpandableToolType {
  String get label {
    switch (this) {
      case ExpandableToolType.definition:
        return 'Dict';
      case ExpandableToolType.verse:
        return 'Verse';
      case ExpandableToolType.chunk:
        return 'Chunk';
      case ExpandableToolType.prashna:
        return 'Prashna';
      case ExpandableToolType.graph:
        return 'Graph';
    }
  }
}

class ToolCard extends StatefulWidget {
  final UnifiedSearchResult result;
  final ExpandableToolType toolType;
  final AppThemeColors themeColors;
  final Function(String)? onCopy;
  final Function(String)? onShare;
  final Function(String)? onReferenceClick;
  final bool isGreyedOut;

  const ToolCard({
    Key? key,
    required this.result,
    required this.toolType,
    required this.themeColors,
    this.onCopy,
    this.onShare,
    this.onReferenceClick,
    this.isGreyedOut = false,
  }) : super(key: key);

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  late ExpandableController _expandableController;
  late List<VerseRM> _currentVerses;
  late List<BookChunkRM> _currentChunks; // Local chunks state for managing navigation updates
  bool _isExpanded = false; // Track expansion state for UI updates
  
  // Report Missing state
  bool _isSubmittingMissing = false;
  final TextEditingController _missingController = TextEditingController();
  final List<String> _submittedMissingResources = [];

  @override
  void initState() {
    super.initState();
    _expandableController = ExpandableController(initialExpanded: false);
    _currentVerses = List.from(widget.result.verses ?? []);
    _currentChunks = List.from(widget.result.chunks ?? []); // Initialize chunks state
    
    // Listen to expansion changes to update UI
    _expandableController.addListener(() {
      if (mounted) {
        setState(() {
          _isExpanded = _expandableController.expanded;
        });
      }
    });
  }

  @override
  void didUpdateWidget(ToolCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update local state when the result data changes (e.g., when language processing completes)
    if (oldWidget.result != widget.result) {
      setState(() {
        _currentVerses = List.from(widget.result.verses ?? []);
        _currentChunks = List.from(widget.result.chunks ?? []);
      });
    }
  }

  @override
  void dispose() {
    _expandableController.dispose();
    _missingController.dispose();
    super.dispose();
  }

  /// Get intelligent display query - now uses the pre-processed query from service
  String _getDisplayQuery() {
    // The service now sets the correct query for each result type
    return widget.result.query;
  }

  /// Check if this result should show NEW badge (not greyed out = most recent search)
  bool _isRecentResult() {
    return !widget.isGreyedOut;
  }

  /// Check if this card should be greyed out (not the most recent search)
  bool _shouldGreyOut() {
    // Use the parameter passed from parent widget
    return widget.isGreyedOut;
  }

  /// Get color for tool type
  Color _getToolColor() {
    switch (widget.toolType) {
      case ExpandableToolType.definition:
        return const Color(0xFFF9140C);
      case ExpandableToolType.verse:
        return const Color(0xFF189565);
      case ExpandableToolType.chunk:
        return Colors.blue;
      case ExpandableToolType.prashna:
        return const Color(0xFF9333EA);
      case ExpandableToolType.graph:
        return const Color(0xFF00897B);
    }
  }

  /// Get icon for tool type
  IconData _getToolIcon() {
    switch (widget.toolType) {
      case ExpandableToolType.definition:
        return Icons.local_library_outlined;
      case ExpandableToolType.verse:
        return Icons.keyboard_command_key;
      case ExpandableToolType.chunk:
        return Icons.menu_book;
      case ExpandableToolType.prashna:
        return Icons.psychology_outlined;
      case ExpandableToolType.graph:
        return Icons.hub_outlined;
    }
  }

  Future<void> _handleVerseNavigation(int versePk, bool isNext) async {
    try {
      final verseService = VerseService.instance;
      
      // Find the current verse in our local list
      final currentIndex = _currentVerses.indexWhere((v) => v.versePk == versePk);
      if (currentIndex == -1) return;
      
      // Make the API call directly to repository (same as VerseService)
      final result = isNext 
        ? await verseService.repository.getNextVerse(versePk: versePk.toString())
        : await verseService.repository.getPreviousVerse(versePk: versePk.toString());

      if (result.status == DomainResultStatus.SUCCESS && result.data != null) {
        final newVerse = result.data!.getVerseData();
        if (newVerse != null) {
          // Update our local list (same logic as VerseService)
          setState(() {
            _currentVerses[currentIndex] = newVerse;
          });
          
          // Also add to VerseService cache so VerseCard StreamBuilder gets updates
          VerseService.instance.addVerseToCache(newVerse);
          
        }
      }
    } catch (e) {
    }
  }

  Future<void> _handleBookmarkToggle(int versePk) async {
    try {
      final verseService = VerseService.instance;
      
      // Find the current verse in our local list by versePk
      final currentIndex = _currentVerses.indexWhere((v) => v.versePk == versePk);
      if (currentIndex == -1) {
        return;
      }
      
      final currentVerse = _currentVerses[currentIndex];
      final isCurrentlyBookmarked = currentVerse.isStarred ?? false;
      
      
      // Make the API call with the ACTUAL verse PK (same as VerseService)
      final result = await verseService.repository.toggleBookmark(
        currentVerse.versePk,  // Use the current verse's actual PK
        isToRemove: isCurrentlyBookmarked,
      );

      if (result.status == DomainResultStatus.SUCCESS && result.data != null) {
        if (result.data!.success) {
          // Update bookmark status (same logic as VerseService)
          final updatedVerse = currentVerse.copyWith(
            isStarred: !isCurrentlyBookmarked,
          );
          
          
          setState(() {
            _currentVerses[currentIndex] = updatedVerse;
          });
          
          // Also add to VerseService cache so VerseCard StreamBuilder gets updates
          VerseService.instance.addVerseToCache(updatedVerse);
          
        } else {
        }
      } else {
        // Handle API errors (like "already bookmarked") gracefully
        
        // If it's an "already bookmarked" error, sync the state with server
        if (result.message?.contains("already bookmarked") == true || 
            result.message?.contains("already") == true) {
          
          // If we tried to bookmark but it's already bookmarked, set it as bookmarked
          final correctedVerse = currentVerse.copyWith(
            isStarred: !isCurrentlyBookmarked, // The opposite of what we thought
          );
          
          setState(() {
            _currentVerses[currentIndex] = correctedVerse;
          });
          
          // Also add to VerseService cache
          VerseService.instance.addVerseToCache(correctedVerse);
          
        }
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecent = _isRecentResult();
    final shouldGreyOut = _shouldGreyOut();
    final toolColor = _getToolColor();
    
    const greyColor = Color(0xFF9CA3AF);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: shouldGreyOut 
          ? widget.themeColors.surface.withOpacity(0.6)
          : widget.themeColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: shouldGreyOut
            ? greyColor.withOpacity(0.2)
            : (isRecent 
              ? toolColor.withOpacity(0.4)
              : toolColor.withOpacity(0.15)),
          width: isRecent ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: shouldGreyOut
              ? greyColor.withOpacity(0.05)
              : (isRecent 
                ? toolColor.withOpacity(0.15)
                : toolColor.withOpacity(0.08)),
            blurRadius: isRecent ? 8 : 4,
            offset: Offset(0, isRecent ? 2 : 1),
          ),
        ],
      ),
      child: ExpandableNotifier(
        controller: _expandableController,
        child: Column(
          children: [
            _buildHeader(),
            ExpandablePanel(
              controller: _expandableController,
              theme: const ExpandableThemeData(
                hasIcon: false,
                tapHeaderToExpand: false,
                tapBodyToExpand: false,
                tapBodyToCollapse: false,
              ),
              collapsed: const SizedBox.shrink(),
              expanded: _buildExpandedContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const greyColor = Color(0xFF9CA3AF);
    final shouldGreyOut = _shouldGreyOut();
    final toolColor = _getToolColor();
    final displayColor = shouldGreyOut ? greyColor : toolColor;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: [
          // Main Row: Icon, Query+Tool Name, Controls
          Row(
            children: [
              // Big Tool Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: displayColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: displayColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  _getToolIcon(),
                  size: 24,
                  color: displayColor,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Query and Tool Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Query
                    Text(
                      _getDisplayQuery(),
                      style: TdResTextStyles.p1.copyWith(
                        color: widget.themeColors.onSurface.withOpacity(shouldGreyOut ? 0.6 : 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Tool Name
                    Text(
                      widget.toolType.label,
                      style: TdResTextStyles.p3.copyWith(
                        color: displayColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // NEW Badge and Expand Button
              Column(
                children: [
                  if (_isRecentResult()) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'NEW',
                        style: TdResTextStyles.caption.copyWith(
                          color: widget.themeColors.surface,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Compact expand button
                  InkWell(
                    onTap: () => _expandableController.toggle(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded ? 'Less' : 'More',
                            style: TdResTextStyles.p3.copyWith(
                              color: displayColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isExpanded 
                                ? Icons.keyboard_arrow_up_rounded 
                                : Icons.keyboard_arrow_down_rounded,
                            color: displayColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // AI Summary preview (2 lines only for Dictionary cards when collapsed)
          if (widget.toolType == ExpandableToolType.definition && 
              widget.result.definition?.details.llmDef != null &&
              widget.result.definition!.details.llmDef!.isNotEmpty &&
              !_isExpanded) ...[
            const SizedBox(height: 12),
            _buildAISummaryPreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildAISummaryPreview() {
    const greyColor = Color(0xFF9CA3AF);
    final shouldGreyOut = _shouldGreyOut();
    final toolColor = _getToolColor();
    final displayColor = shouldGreyOut ? greyColor : toolColor;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: displayColor.withOpacity(0.05),
        border: Border.all(
          color: displayColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: displayColor,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Summary',
                style: TdResTextStyles.p2.copyWith(
                  color: displayColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.result.definition!.details.llmDef!,
            style: TdResTextStyles.p3.copyWith(
              color: widget.themeColors.onSurface.withOpacity(shouldGreyOut ? 0.6 : 0.8),
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryFull() {
    const greyColor = Color(0xFF9CA3AF);
    final shouldGreyOut = _shouldGreyOut();
    final toolColor = _getToolColor();
    final displayColor = shouldGreyOut ? greyColor : toolColor;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: displayColor.withOpacity(0.08),
        border: Border.all(
          color: displayColor.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: displayColor,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Summary',
                style: TdResTextStyles.p1.copyWith(
                  color: displayColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.result.definition!.details.llmDef!,
            style: TdResTextStyles.p2.copyWith(
              color: widget.themeColors.onSurface.withOpacity(shouldGreyOut ? 0.7 : 0.85),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        children: [
          // Separator line
          Container(
            height: 1,
            color: widget.themeColors.onSurface.withOpacity(0.1),
            margin: const EdgeInsets.only(bottom: 16),
          ),
          
          // AI Summary (full version for Dictionary cards)
          if (widget.toolType == ExpandableToolType.definition && 
              widget.result.definition?.details.llmDef != null &&
              widget.result.definition!.details.llmDef!.isNotEmpty)
            _buildAISummaryFull(),
          
          // Tool-specific content
          _buildToolContent(),
          
          // Report Missing section (tool-level, only in Scholar Mode)
          if (_isExpanded && TesterModeService.instance.isEnabled && widget.toolType != ExpandableToolType.prashna)
            _buildReportMissingSection(),
          
          // Scroll hint (shown first time user expands a card in Scholar Mode)
          if (_isExpanded)
            const ScrollHintWidget(),
        ],
      ),
    );
  }
  
  Widget _buildToolContent() {
    switch (widget.toolType) {
      case ExpandableToolType.definition:
        return _buildDefinitionContent();
      case ExpandableToolType.verse:
        return _buildVerseContent();
      case ExpandableToolType.chunk:
        return _buildChunkContent();
      case ExpandableToolType.prashna:
        return _buildPrashnaContent();
      case ExpandableToolType.graph:
        return _buildGraphToolContent();
    }
  }

  Widget _buildDefinitionContent() {
    if (widget.result.definition == null) {
      return const Text('No definition data available');
    }

    final definitions = widget.result.definition!.details.definitions;
    final similarWords = widget.result.definition!.similarWords;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Word Definitions',
              style: TdResTextStyles.h4.copyWith(
                color: widget.themeColors.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${definitions.length} result${definitions.length != 1 ? 's' : ''}',
              style: TdResTextStyles.p3.copyWith(
                color: widget.themeColors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Definition cards
        ...definitions.map((definition) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: WordDefinitionCard(
            definition: definition,
            themeColors: widget.themeColors,
            appThemeDisplay: TdThemeHelper.prepareThemeDisplay(context), // Default display
            showLLMSummary: false, // LLM summary shown in header
            onCopy: widget.onCopy != null 
                ? () => widget.onCopy!(definition.text) 
                : null,
            onSourceClick: widget.onReferenceClick,
            // Pass voting data (parse itemId from String to int)
            queryId: widget.result.queryId,
            itemId: widget.result.itemId != null ? int.tryParse(widget.result.itemId.toString()) : null,
          ),
        )).toList(),
        
        // Similar Words Section
        if (similarWords.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Similar Words',
            style: TdResTextStyles.h4.copyWith(
              color: widget.themeColors.onSurface.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: similarWords.map((word) {
              return Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => _searchSimilarWord(word),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getToolColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getToolColor().withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      word,
                      style: TdResTextStyles.p2.copyWith(
                        color: _getToolColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
  
  /// Search for a similar word
  void _searchSimilarWord(String word) {
    // Get the unified controller and perform search
    final controller = BlocProvider.of<UnifiedController>(context);
    controller.searchUnified(word);
  }

  Widget _buildVerseContent() {
    // Check if we have verse data but it's being processed (language transformation)
    final isProcessing = widget.result.verses != null && 
                        widget.result.verses!.isNotEmpty && 
                        widget.result.outputScript == null;
    
    if (widget.result.verses == null || widget.result.verses!.isEmpty) {
      // Check if this might be a verse result that's still loading
      if (widget.toolType == ExpandableToolType.verse) {
        return _buildVerseLoadingState();
      }
      return const Text('No verse data available');
    }

    // Show loading state if verses exist but are being processed
    if (isProcessing) {
      return _buildVerseProcessingState();
    }

    final verses = widget.result.verses!;
    
    return Column(
      children: [
        // Header
        Row(
          children: [
            Text(
              'Verses',
              style: TdResTextStyles.h4.copyWith(
                color: widget.themeColors.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${verses.length} result${verses.length != 1 ? 's' : ''}',
              style: TdResTextStyles.p3.copyWith(
                color: widget.themeColors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Aksharamukha bar (transcription credit + language selector)
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: widget.themeColors.primary.withAlpha(0x20),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.themeColors.primary.withAlpha(0x1A),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Left side: Transcription credit (flexible to prevent overflow)
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.translate,
                      size: 12,
                      color: widget.themeColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "Transcription by Aksharamukha",
                        style: TdResTextStyles.caption.copyWith(
                          color: widget.themeColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${verses.length} verses',
                      style: TdResTextStyles.caption.copyWith(
                        color: widget.themeColors.onSurface.withAlpha(0xAA),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Right side: Language selector (fixed width)
              _buildCompactLanguageSelector(),
            ],
          ),
        ),
        
        // Verse cards with local state (exactly like VerseService logic)
        ..._currentVerses.asMap().entries.map((entry) {
          final index = entry.key;
          final verse = entry.value;
          
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
            child: VerseCard(
              verse: verse,
              themeColors: widget.themeColors,
              appThemeDisplay: TdThemeHelper.prepareThemeDisplay(context),
              // Same navigation logic as VerseService but locally managed
              onPrevious: () => _handleVerseNavigation(verse.versePk, false),
              onNext: () => _handleVerseNavigation(verse.versePk, true),
              onBookmark: () => _handleBookmarkToggle(verse.versePk),
              onCopy: widget.onCopy != null 
                  ? () => widget.onCopy!(verse.verseText ?? 'No verse text available') 
                  : null,
              // Pass voting data (parse itemId from String to int)
              queryId: widget.result.queryId,
              itemId: widget.result.itemId != null ? int.tryParse(widget.result.itemId.toString()) : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildChunkContent() {
    if (widget.result.chunks == null || widget.result.chunks!.isEmpty) {
      return const Text('No chunk data available');
    }

    final chunks = widget.result.chunks!;
    
    return Column(
      children: [
        // Header
        Row(
          children: [
            Text(
              'Book Chunks',
              style: TdResTextStyles.h4.copyWith(
                color: widget.themeColors.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              '${chunks.length} result${chunks.length != 1 ? 's' : ''}',
              style: TdResTextStyles.p3.copyWith(
                color: widget.themeColors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Chunk cards with local state (exactly like verse logic)
        ..._currentChunks.asMap().entries.map((entry) {
          final index = entry.key;
          final chunk = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BookChunkItemLightweightWidget(
              chunk: chunk,
              onSourceClick: (url) async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              onNavigateNext: () => _handleNextChunk(chunk),
              onNavigatePrevious: () => _handlePreviousChunk(chunk),
              // Pass voting data (parse itemId from String to int)
              queryId: widget.result.queryId,
              itemId: widget.result.itemId != null ? int.tryParse(widget.result.itemId.toString()) : null,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPrashnaContent() {
    // Prashna content requires queryId and query
    if (widget.result.queryId == null) {
      return const Text('No query ID available for Prashna');
    }

    // Use originalQuery if available, otherwise fall back to query
    final queryToSend = widget.result.originalQuery ?? widget.result.query;

    // Debug: Log what we're passing to Prashna

    return PrashnaToolCardContent(
      key: ValueKey('prashna_${widget.result.queryId}'), // Prevent recreating widget on rebuild
      query: queryToSend,
      queryId: widget.result.queryId!,
      isExpanded: _isExpanded, // Pass expansion state
      themeColors: widget.themeColors,
    );
  }

  Widget _buildGraphToolContent() {
    if (widget.result.graphLoading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: const Color(0xFF00897B),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Querying knowledge graph...',
              style: TextStyle(
                fontSize: 13,
                color: widget.themeColors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.result.graphError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: Colors.red.shade400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.result.graphError!,
                style: TextStyle(fontSize: 13, color: Colors.red.shade400),
              ),
            ),
          ],
        ),
      );
    }

    final result = widget.result.graphResult;
    if (result == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No graph data available'),
      );
    }

    return _GraphToolResultContent(
      result: result,
      themeColors: widget.themeColors,
    );
  }

  Widget _buildReportMissingSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.themeColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.themeColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: widget.themeColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Are we missing anything?',
                style: TextStyle(
                  fontSize: 13,
                  color: widget.themeColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Help us improve by sharing what\'s missing',
            style: TextStyle(
              fontSize: 11,
              color: widget.themeColors.onSurface.withOpacity(0.6),
            ),
          ),
          
          // Input fields (always shown)
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active text box (primary)
              TextField(
                  controller: _missingController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'e.g., "Missing Bhagavad Gita Chapter 2, Verse 47"',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: widget.themeColors.onSurface.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: widget.themeColors.onSurface.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: widget.themeColors.onSurface.withOpacity(0.15),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: widget.themeColors.onSurface.withOpacity(0.15),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: widget.themeColors.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.themeColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Placeholder text box (greyed out - indicates multiple entries)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.themeColors.onSurface.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.themeColors.onSurface.withOpacity(0.08),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add another reference...',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.themeColors.onSurface.withOpacity(0.25),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: widget.themeColors.onSurface.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                // Add button (full width for better UX)
                ElevatedButton.icon(
                  onPressed: _isSubmittingMissing ? null : _submitMissingResource,
                  icon: _isSubmittingMissing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.add_circle_outline, size: 18),
                  label: Text(
                    _isSubmittingMissing ? 'Adding...' : 'Add to List',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
            ],
          ),
          
          // Display submitted missing resources
          if (_submittedMissingResources.isNotEmpty) ...[
            const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.themeColors.primary.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.themeColors.primary.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: widget.themeColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Submitted (${_submittedMissingResources.length})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: widget.themeColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _submittedMissingResources.asMap().entries.map((entry) {
                        final index = entry.key;
                        final resource = entry.value;
                        return Chip(
                          label: Text(
                            resource,
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.themeColors.onSurface,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 14,
                            color: widget.themeColors.onSurface.withOpacity(0.6),
                          ),
                          onDeleted: () => _removeMissingResource(index),
                          backgroundColor: widget.themeColors.surface,
                          side: BorderSide(
                            color: widget.themeColors.primary.withOpacity(0.25),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          labelPadding: const EdgeInsets.only(left: 4),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }

  void _removeMissingResource(int index) {
    setState(() {
      _submittedMissingResources.removeAt(index);
    });
  }

  Future<void> _submitMissingResource() async {
    if (_missingController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe what\'s missing')),
      );
      return;
    }

    if (widget.result.itemId == null || widget.result.queryId == null) {
      return;
    }

    setState(() => _isSubmittingMissing = true);

    try {
      final votingRepository = Modular.get<VotingRepository>();
      final voteRequest = VoteRequest(
        itemId: widget.result.itemId!, // Use the TOOL's item_id (0, 1, 2, etc.)
        queryId: widget.result.queryId!,
        value: 'add_missing', // Specifies this is a missing resource report
        vote: _missingController.text.trim(), // The actual text
      );


      await votingRepository.submitVote(voteRequest);

      if (mounted) {
        setState(() {
          _submittedMissingResources.add(_missingController.text.trim());
        });
        _missingController.clear();
        // Don't hide the field - allow multiple entries
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Missing resource added'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to report - please try again'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingMissing = false);
      }
    }
  }

  /// Compact language selector for the Aksharamukha bar - exactly like random folder
  Widget _buildCompactLanguageSelector() {
    final dashboardController = Modular.get<DashboardController>();

    return BlocBuilder<DashboardController, DashboardCubitState>(
      bloc: dashboardController,
      buildWhen: (previous, current) =>
          current.verseLanguagePref != previous.verseLanguagePref,
      builder: (context, state) {
        final currentLanguage = state.verseLanguagePref?.output ?? VersesConstants.LANGUAGE_DEFAULT;
        
        return PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: widget.themeColors.primary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getLanguageLabel(currentLanguage),
                  style: TdResTextStyles.caption.copyWith(
                    color: widget.themeColors.surface,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 12,
                  color: widget.themeColors.surface,
                ),
              ],
            ),
          ),
          onSelected: (String value) {
            dashboardController.onVerseLanguageChange(value);
          },
          itemBuilder: (context) => _getSupportedLanguages().entries.map<PopupMenuItem<String>>((entry) {
            return PopupMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: TdResTextStyles.buttonSmall.copyWith(
                  color: widget.themeColors.onSurface,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// Get language label from constants
  String _getLanguageLabel(String language) {
    return VersesConstants.LANGUAGE_LABELS_MAP[language] ?? language;
  }

  /// Get supported languages from service
  Map<String, String> _getSupportedLanguages() {
    try {
      return SupportedLanguagesService().getSupportedLanguages();
    } catch (e) {
      return VersesConstants.LANGUAGE_LABELS_MAP.map((k, v) => MapEntry(k, v ?? k));
    }
  }


  /// Handle chunk navigation with local state management (similar to verse navigation)
  Future<void> _handleChunkNavigation(int chunkRefId, bool isNext) async {
    try {
      final booksRepo = Modular.get<BooksRepository>();
      
      // Find the current chunk in our local list
      final currentIndex = _currentChunks.indexWhere((c) => c.chunkRefId == chunkRefId);
      if (currentIndex == -1) return;
      
      // Make the API call directly to repository
      final result = isNext 
        ? await booksRepo.getNextChunk(chunkRefId: chunkRefId.toString())
        : await booksRepo.getPreviousChunk(chunkRefId: chunkRefId.toString());

      if (result.status == DomainResultStatus.SUCCESS && result.data != null) {
        final newChunk = isNext 
          ? (result.data as BookChunkNextResultRM).getNextChunk()
          : (result.data as BookChunkPrevResultRM).getPrevChunk();
        if (newChunk != null) {
          // Update our local list
          setState(() {
            _currentChunks[currentIndex] = newChunk;
          });
          
        }
      }
    } catch (e) {
    }
  }

  /// 🔄 Handle previous chunk navigation (uses local state management)
  void _handlePreviousChunk(chunk) {
    if (chunk.chunkRefId == null) return;
    _handleChunkNavigation(chunk.chunkRefId!, false);
  }

  /// ⏭️ Handle next chunk navigation (uses local state management)
  void _handleNextChunk(chunk) {
    if (chunk.chunkRefId == null) return;
    _handleChunkNavigation(chunk.chunkRefId!, true);
  }

  /// Loading state for when no verse data is available yet
  Widget _buildVerseLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_getToolColor()),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading verses...',
            style: TdResTextStyles.p2.copyWith(
              color: widget.themeColors.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Searching through ancient texts',
            style: TdResTextStyles.p3.copyWith(
              color: widget.themeColors.onSurface.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Processing state for when verses are being language-transformed
  Widget _buildVerseProcessingState() {
    final verseCount = widget.result.verses?.length ?? 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(_getToolColor()),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Processing $verseCount verse${verseCount != 1 ? 's' : ''}...',
            style: TdResTextStyles.p2.copyWith(
              color: widget.themeColors.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Applying language transformations',
            style: TdResTextStyles.p3.copyWith(
              color: widget.themeColors.onSurface.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

}

/// Displays graph (NL-to-Cypher) results inside a ToolCard
class _GraphToolResultContent extends StatelessWidget {
  final GraphSearchResult result;
  final AppThemeColors themeColors;

  const _GraphToolResultContent({
    required this.result,
    required this.themeColors,
  });

  /// Resolve a neo4j node ID to its entity name for relationship display.
  String _resolveNodeName(int? neo4jId, GraphSearchResult result) {
    if (neo4jId == null) return '?';
    // Search entities from db_results first
    for (final entity in result.entities) {
      if (entity.neo4jId == neo4jId) return entity.name;
    }
    // Then search subgraph nodes
    for (final sg in result.graphSubgraphs) {
      for (final node in sg.nodes) {
        if (node.neo4jId == neo4jId) return node.name;
      }
    }
    return 'Node#$neo4jId';
  }

  @override
  Widget build(BuildContext context) {
    const graphColor = Color(0xFF00897B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Interpretation banner
        if (result.interpretation.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              result.interpretation,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: themeColors.onSurface,
              ),
            ),
          ),

        // Result count + method + time
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: graphColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${result.resultCount} result${result.resultCount != 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: graphColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: themeColors.onSurface.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'via ${result.generationMethod}',
                  style: TextStyle(fontSize: 11, color: themeColors.onSurface.withOpacity(0.5)),
                ),
              ),
              if (result.timeTaken != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: themeColors.onSurface.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${result.timeTaken!.toStringAsFixed(1)}s',
                    style: TextStyle(fontSize: 11, color: themeColors.onSurface.withOpacity(0.5)),
                  ),
                ),
              if (result.allRelationships.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B1FA2).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${result.allRelationships.length} relation${result.allRelationships.length != 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7B1FA2)),
                  ),
                ),
            ],
          ),
        ),

        // Entity list
        if (result.entities.isNotEmpty)
          ...result.entities.map((entity) => _GraphEntityItem(
            entity: entity,
            themeColors: themeColors,
          )),

        if (result.entities.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No entities found for this query',
              style: TextStyle(fontSize: 13, color: themeColors.onSurface.withOpacity(0.5)),
            ),
          ),

        // Relationships (collapsible)
        if (result.allRelationships.isNotEmpty)
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              leading: Icon(Icons.link, size: 16, color: const Color(0xFF7B1FA2).withOpacity(0.6)),
              title: Text(
                'Relationships (${result.allRelationships.length})',
                style: TextStyle(fontSize: 12, color: themeColors.onSurface.withOpacity(0.5)),
              ),
              children: [
                ...result.allRelationships.map((rel) {
                  final startName = _resolveNodeName(rel.startNodeNeo4jId, result);
                  final endName = _resolveNodeName(rel.endNodeNeo4jId, result);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColors.onSurface.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: themeColors.onSurface.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                startName,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: themeColors.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7B1FA2).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  rel.type.replaceAll('_', ' '),
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF7B1FA2), letterSpacing: 0.3),
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward, size: 12, color: Color(0xFF7B1FA2)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                endName,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: themeColors.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (rel.details != null && rel.details!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            rel.details!,
                            style: TextStyle(fontSize: 11, color: themeColors.onSurface.withOpacity(0.55), height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

        // Cypher query (collapsible)
        if (result.cypherQuery.isNotEmpty)
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              leading: Icon(Icons.code, size: 16, color: themeColors.onSurface.withOpacity(0.4)),
              title: Text(
                'Cypher Query',
                style: TextStyle(fontSize: 12, color: themeColors.onSurface.withOpacity(0.5)),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColors.onSurface.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    result.cypherQuery,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: themeColors.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Raw JSON (collapsible)
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            leading: Icon(Icons.data_object, size: 16, color: themeColors.onSurface.withOpacity(0.4)),
            title: Text(
              'Raw Response',
              style: TextStyle(fontSize: 12, color: themeColors.onSurface.withOpacity(0.5)),
            ),
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    result.rawJsonPretty,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFFD4D4D4),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single entity row inside the Graph tool card
class _GraphEntityItem extends StatefulWidget {
  final GraphEntity entity;
  final AppThemeColors themeColors;

  const _GraphEntityItem({
    required this.entity,
    required this.themeColors,
  });

  @override
  State<_GraphEntityItem> createState() => _GraphEntityItemState();
}

class _GraphEntityItemState extends State<_GraphEntityItem> {
  bool _summaryExpanded = false;

  Color _getLabelColor(String label) {
    switch (label.toUpperCase()) {
      case 'DEITY': return const Color(0xFFFF8F00);
      case 'PERSON': return const Color(0xFF1565C0);
      case 'DEMON': return const Color(0xFFC62828);
      case 'ANIMAL': return const Color(0xFF2E7D32);
      case 'KINGDOM': return const Color(0xFF6A1B9A);
      case 'WEAPON': return const Color(0xFF4E342E);
      case 'PLACE': return const Color(0xFF00695C);
      case 'EVENT': return const Color(0xFFE65100);
      default: return const Color(0xFF546E7A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entity = widget.entity;
    final themeColors = widget.themeColors;
    final primaryColor = _getLabelColor(entity.primaryLabel);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeColors.onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: primaryColor, width: 3)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entity.name,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: themeColors.onSurface),
                      ),
                    ),
                    if (entity.role.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF00897B).withOpacity(0.3)),
                        ),
                        child: Text(
                          entity.role,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF00897B)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: entity.labels.map((label) {
                    final labelColor = _getLabelColor(label);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: labelColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: labelColor, letterSpacing: 0.5),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Summary
          if (entity.summary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    _summaryExpanded ? entity.summary : entity.summaryPreview,
                    style: TextStyle(fontSize: 12, color: themeColors.onSurface.withOpacity(0.7), height: 1.5),
                  ),
                  if (entity.hasLongSummary) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => setState(() => _summaryExpanded = !_summaryExpanded),
                      child: Text(
                        _summaryExpanded ? 'Show less' : 'Read more',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF00897B)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
