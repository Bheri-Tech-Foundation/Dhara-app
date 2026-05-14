import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dharak_flutter/app/types/dhara_insights/dhara_insight_chunk.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:dharak_flutter/res/theme/app_theme_display.dart';

class DharaInsightItemWidget extends StatefulWidget {
  final DharaInsightChunkRM chunk;
  final AppThemeColors? themeColors;
  final int? queryId;
  final int? itemId;

  const DharaInsightItemWidget({
    super.key,
    required this.chunk,
    this.themeColors,
    this.queryId,
    this.itemId,
  });

  @override
  State<DharaInsightItemWidget> createState() => _DharaInsightItemWidgetState();
}

class _DharaInsightItemWidgetState extends State<DharaInsightItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeColors = widget.themeColors ?? Theme.of(context).extension<AppThemeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF6A1B9A).withOpacity(0.08)
        : const Color(0xFF6A1B9A).withOpacity(0.04);
    final borderColor = isDark
        ? const Color(0xFF6A1B9A).withOpacity(0.3)
        : const Color(0xFF6A1B9A).withOpacity(0.15);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with source info and score
          _buildHeader(themeColors),
          
          // Text content
          _buildTextContent(themeColors),
          
          // Reference
          if (widget.chunk.reference != null && widget.chunk.reference!.isNotEmpty)
            _buildReference(themeColors),

          // Actions
          _buildActions(themeColors),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors themeColors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.chunk.sourceTitle != null)
                  Text(
                    widget.chunk.sourceTitle!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6A1B9A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (widget.chunk.sourceType != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B9A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.chunk.sourceType!,
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFF6A1B9A).withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.chunk.score != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6A1B9A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(widget.chunk.score! * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextContent(AppThemeColors themeColors) {
    final text = widget.chunk.text ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    final isLong = text.length > 300;
    final displayText = (!_isExpanded && isLong)
        ? '${text.substring(0, 300)}...'
        : text;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            displayText,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: themeColors.onSurface,
            ),
          ),
          if (isLong)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _isExpanded ? 'Show less' : 'Read more',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6A1B9A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReference(AppThemeColors themeColors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          Icon(Icons.format_quote, size: 14, color: themeColors.onSurface.withOpacity(0.4)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.chunk.reference!,
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: themeColors.onSurface.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppThemeColors themeColors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.chunk.sourceUrl != null && widget.chunk.sourceUrl!.isNotEmpty)
            IconButton(
              icon: Icon(Icons.open_in_new, size: 16, color: themeColors.onSurface.withOpacity(0.5)),
              onPressed: () async {
                final uri = Uri.parse(widget.chunk.sourceUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              tooltip: 'Open source',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          IconButton(
            icon: Icon(Icons.copy, size: 16, color: themeColors.onSurface.withOpacity(0.5)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.chunk.text ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
              );
            },
            tooltip: 'Copy text',
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
