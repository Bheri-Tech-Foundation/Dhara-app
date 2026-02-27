import 'package:dharak_flutter/app/domain/prashna/repo.dart';
import 'package:dharak_flutter/app/types/prashna/ai_model.dart';
import 'package:dharak_flutter/app/types/prashna/chat_message.dart';
import 'package:dharak_flutter/app/types/prashna/sse_event.dart';
import 'package:dharak_flutter/app/ui/widgets/prashna_voting_widget.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'dart:async';

/// Widget for displaying Prashna AI response in Shodh screen (Scholar Mode only)
/// Reuses existing Prashna widgets to maintain consistency
class PrashnaToolCardContent extends StatefulWidget {
  final String query;
  final int queryId;
  final bool isExpanded;
  final AppThemeColors themeColors;

  const PrashnaToolCardContent({
    Key? key,
    required this.query,
    required this.queryId,
    required this.isExpanded,
    required this.themeColors,
  }) : super(key: key);

  @override
  State<PrashnaToolCardContent> createState() => _PrashnaToolCardContentState();
}

// Cache model for Prashna content
class _PrashnaContentCache {
  final String content;
  final int? fetchedQueryId;
  final bool hasError;
  final String? errorMessage;

  _PrashnaContentCache({
    required this.content,
    this.fetchedQueryId,
    this.hasError = false,
    this.errorMessage,
  });
}

class _PrashnaToolCardContentState extends State<PrashnaToolCardContent> {
  final PrashnaRepository _prashnaRepo = Modular.get<PrashnaRepository>();
  StreamSubscription<SseEventResult>? _streamSubscription;
  
  String _content = '';
  bool _isStreaming = false;
  bool _hasError = false;
  String? _errorMessage;
  int? _fetchedQueryId; // QueryID from SSE stream
  
  // Static cache to track active streams across widget recreations
  static final Set<int> _activeStreams = {};
  
  // Static cache to store content across widget recreations
  static final Map<int, _PrashnaContentCache> _contentCache = {};

  @override
  void initState() {
    super.initState();
    _loadCachedContentOrStartStream();
  }

  void _loadCachedContentOrStartStream() {
    // Check if we have cached content for this queryId
    if (_contentCache.containsKey(widget.queryId)) {
      final cached = _contentCache[widget.queryId]!;
      setState(() {
        _content = cached.content;
        _fetchedQueryId = cached.fetchedQueryId;
        _hasError = cached.hasError;
        _errorMessage = cached.errorMessage;
        _isStreaming = false;
      });
      return;
    }

    // Only start stream if expanded
    if (widget.isExpanded) {
      _startPrashnaStream();
    } else {
    }
  }

  @override
  void didUpdateWidget(PrashnaToolCardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle query/queryId changes
    if (oldWidget.query != widget.query || oldWidget.queryId != widget.queryId) {
      _activeStreams.remove(oldWidget.queryId); // Remove old queryId from cache
      _streamSubscription?.cancel();
      _content = '';
      _isStreaming = false;
      _hasError = false;
      _errorMessage = null;
      _fetchedQueryId = null;
      _loadCachedContentOrStartStream();
      return;
    }
    
    // Handle expansion changes
    if (oldWidget.isExpanded != widget.isExpanded && widget.isExpanded) {
      // Card just expanded
      if (!_contentCache.containsKey(widget.queryId) && !_activeStreams.contains(widget.queryId)) {
        setState(() {
          _isStreaming = true; // Set loading state BEFORE starting stream
        });
        _startPrashnaStream();
      }
    }
  }

  @override
  void dispose() {
    // Remove from active streams when widget is disposed
    _activeStreams.remove(widget.queryId);
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _startPrashnaStream() {
    // Check static cache to prevent multiple streams for the same queryId
    if (_activeStreams.contains(widget.queryId)) {
      return;
    }

    // Mark this queryId as having an active stream
    _activeStreams.add(widget.queryId);

    _streamSubscription = _prashnaRepo.sendStandaloneQuery(
      query: widget.query,
      sodhQueryId: widget.queryId,
    ).listen(
      (result) {
        if (result.hasError) {
          setState(() {
            _hasError = true;
            _errorMessage = result.error;
            _isStreaming = false;
          });
          return;
        }

        if (result.isComplete) {
          setState(() {
            _isStreaming = false;
          });
          return;
        }

        final event = result.event;
        if (event == null) return;

        // Handle QueryID event
        if (event is QueryIdEvent) {
          final prashnaQueryId = event.queryId;
          if (prashnaQueryId != null) {
            setState(() {
              _fetchedQueryId = prashnaQueryId;
            });
          }
        }

        // Handle content events
        if (event is ContentDeltaEvent || event is RunContentEvent) {
          final contentDelta = event.content ?? '';
          setState(() {
            _content += contentDelta;
          });
          
          // Update cache with current content
          _contentCache[widget.queryId] = _PrashnaContentCache(
            content: _content,
            fetchedQueryId: _fetchedQueryId,
          );
        }
      },
      onError: (error) {
        _activeStreams.remove(widget.queryId); // Remove from cache on error
        
        // Cache error state
        _contentCache[widget.queryId] = _PrashnaContentCache(
          content: _content,
          fetchedQueryId: _fetchedQueryId,
          hasError: true,
          errorMessage: error.toString(),
        );
        
        setState(() {
          _hasError = true;
          _errorMessage = error.toString();
          _isStreaming = false;
        });
      },
      onDone: () {
        _activeStreams.remove(widget.queryId); // Remove from cache on completion
        
        // Cache final content
        _contentCache[widget.queryId] = _PrashnaContentCache(
          content: _content,
          fetchedQueryId: _fetchedQueryId,
        );
        
        setState(() {
          _isStreaming = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Response content
          if (_hasError) ...[
            _buildErrorWidget(),
          ] else if (_content.isEmpty && _isStreaming) ...[
            _buildLoadingWidget(),
          ] else if (_content.isEmpty && !_isStreaming) ...[
            // Not yet loaded (card was collapsed)
            _buildPlaceholderWidget(),
          ] else ...[
            _buildContentWidget(),
          ],

          // Voting widget (only show when streaming is complete and we have Prashna's queryId)
          if (!_isStreaming && _content.isNotEmpty && _fetchedQueryId != null) ...[
            const SizedBox(height: 16),
            PrashnaVotingWidget(
              queryId: _fetchedQueryId!, // Use Prashna's QueryID (NOT Shodh's queryId)
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 48,
              color: widget.themeColors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'AI analysis will load when you expand this card',
              style: TextStyle(
                color: widget.themeColors.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              color: widget.themeColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'AI is analyzing your query...',
              style: TextStyle(
                color: widget.themeColors.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error loading AI response',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.withOpacity(0.8),
                      fontSize: 12,
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

  Widget _buildContentWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Markdown content
        MarkdownBlock(
          data: _content,
          config: MarkdownConfig(
            configs: [
              H1Config(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.themeColors.onSurface,
                ),
              ),
              H2Config(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: widget.themeColors.onSurface,
                ),
              ),
              PConfig(
                textStyle: TextStyle(
                  fontSize: 14,
                  color: widget.themeColors.onSurface,
                  height: 1.5,
                ),
              ),
              CodeConfig(
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: widget.themeColors.primary,
                  backgroundColor: widget.themeColors.surface.withOpacity(0.5),
                ),
              ),
              const BlockquoteConfig(),
            ],
          ),
        ),

        // Streaming indicator
        if (_isStreaming) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.themeColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Generating response...',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.themeColors.onSurface.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

