import 'package:dharak_flutter/app/data/services/tester_mode_service.dart';
import 'package:dharak_flutter/app/data/voting/voting_repository.dart';
import 'package:dharak_flutter/app/types/voting/vote_request.dart';
import 'package:dharak_flutter/app/types/voting/vote_type.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// Compact voting widget for individual cards (definitions, verses, chunks)
/// Shows only relevance voting buttons in a clean, minimal design
class CompactVotingWidget extends StatefulWidget {
  final int? queryId;
  final int? itemId;
  final String? refId; // dict_ref_id, verse_pk, or chunk_ref_id
  final VoteContentType contentType;
  final AppThemeColors themeColors;

  const CompactVotingWidget({
    Key? key,
    required this.queryId,
    required this.itemId,
    required this.refId,
    required this.contentType,
    required this.themeColors,
  }) : super(key: key);

  @override
  State<CompactVotingWidget> createState() => _CompactVotingWidgetState();
}

class _CompactVotingWidgetState extends State<CompactVotingWidget> {
  VoteValue? _selectedVote;
  bool _isSubmitting = false;
  final VotingRepository _votingRepository = Modular.get<VotingRepository>();

  @override
  void initState() {
    super.initState();
    _loadCachedVoteState();
  }

  /// Load cached vote state from repository
  void _loadCachedVoteState() {
    if (widget.queryId == null || widget.itemId == null || widget.refId == null) {
      return;
    }

    final cachedVote = _votingRepository.getCachedVoteState(
      queryId: widget.queryId!,
      itemId: widget.itemId.toString(),
      refId: widget.refId!,
    );

    if (cachedVote != null) {
      _selectedVote = _voteStringToVoteValue(cachedVote);
    }
  }

  /// Convert vote string to VoteValue enum
  VoteValue? _voteStringToVoteValue(String vote) {
    switch (vote) {
      case '2':
        return VoteValue.highlyRelevant;
      case '1':
        return VoteValue.relevant;
      case '0':
        return VoteValue.neutral;
      case '-1':
        return VoteValue.notRelevant;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show in Scholar Mode
    if (!TesterModeService.instance.isEnabled) {
      return const SizedBox.shrink();
    }

    // Validate required data
    if (widget.queryId == null || widget.itemId == null || widget.refId == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeColors.primary.withOpacity(0.05),
            widget.themeColors.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.themeColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.themeColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.rate_review,
                  size: 16,
                  color: widget.themeColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate this result',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.themeColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'How relevant is this to your search?',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.themeColors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Vote buttons with labels
          Row(
            children: [
              Expanded(child: _buildVoteButton(VoteValue.highlyRelevant)),
              const SizedBox(width: 8),
              Expanded(child: _buildVoteButton(VoteValue.relevant)),
              const SizedBox(width: 8),
              Expanded(child: _buildVoteButton(VoteValue.neutral)),
              const SizedBox(width: 8),
              Expanded(child: _buildVoteButton(VoteValue.notRelevant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(VoteValue voteValue) {
    final isSelected = _selectedVote == voteValue;
    final color = _getVoteColor(voteValue);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSubmitting
            ? null
            : () {
                // Toggle logic
                final newVote = isSelected ? VoteValue.neutral : voteValue;
                _submitVote(newVote);
              },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? color.withOpacity(0.15) 
                : widget.themeColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected 
                  ? color 
                  : widget.themeColors.onSurfaceDisable.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon/Emoji
              Text(
                voteValue.icon,
                style: TextStyle(
                  fontSize: 20,
                  color: isSelected ? color : widget.themeColors.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                _getShortLabel(voteValue),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : widget.themeColors.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getShortLabel(VoteValue voteValue) {
    switch (voteValue) {
      case VoteValue.highlyRelevant:
        return 'Highly\nRelevant';
      case VoteValue.relevant:
        return 'Relevant';
      case VoteValue.neutral:
        return 'Not\nSure';
      case VoteValue.notRelevant:
        return 'Not\nRelevant';
    }
  }

  Color _getVoteColor(VoteValue voteValue) {
    switch (voteValue) {
      case VoteValue.highlyRelevant:
        return const Color(0xFF10B981); // Green
      case VoteValue.relevant:
        return const Color(0xFF3B82F6); // Blue
      case VoteValue.neutral:
        return const Color(0xFF6B7280); // Gray
      case VoteValue.notRelevant:
        return const Color(0xFFEF4444); // Red
    }
  }

  Future<void> _submitVote(VoteValue voteValue) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _selectedVote = voteValue;
    });

    try {
      final voteRequest = VoteRequest(
        itemId: widget.itemId.toString(),
        queryId: widget.queryId!,
        value: widget.refId, // dict_ref_id, verse_pk, or chunk_ref_id
        vote: voteValue.numericValue.toString(),
      );

      final success = await _votingRepository.submitVote(voteRequest);

    } catch (e) {
      // Show error toast only for failures
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit vote - please try again'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

