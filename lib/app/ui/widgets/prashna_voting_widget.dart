import 'dart:async';
import 'package:dharak_flutter/app/data/services/tester_mode_service.dart';
import 'package:dharak_flutter/app/data/voting/prashna_voting_repository.dart';
import 'package:dharak_flutter/app/types/prashna/vote_type.dart';
import 'package:dharak_flutter/res/styles/text_styles.dart';
import 'package:dharak_flutter/res/theme/app_theme_display.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// Voting widget for Prashna responses (3 dimensions + feedback)
class PrashnaVotingWidget extends StatefulWidget {
  final int? queryId;

  const PrashnaVotingWidget({
    Key? key,
    required this.queryId,
  }) : super(key: key);

  @override
  State<PrashnaVotingWidget> createState() => _PrashnaVotingWidgetState();
}

class _PrashnaVotingWidgetState extends State<PrashnaVotingWidget> {
  final _votingRepository = Modular.get<PrashnaVotingRepository>();
  final _feedbackController = TextEditingController();
  
  // Track votes for each dimension
  PrashnaVoteValue? _faithfulnessVote;
  PrashnaVoteValue? _relevanceVote;
  PrashnaVoteValue? _correctnessVote;

  bool _isSubmittingFeedback = false;

  @override
  void initState() {
    super.initState();
    _loadCachedVoteStates();
  }

  /// Load cached vote states from repository
  void _loadCachedVoteStates() {
    if (widget.queryId == null) return;

    // Load cached votes for each dimension
    final faithfulnessCache = _votingRepository.getCachedVoteState(
      queryId: widget.queryId!,
      voteType: PrashnaVoteType.faithfulness,
    );
    final relevanceCache = _votingRepository.getCachedVoteState(
      queryId: widget.queryId!,
      voteType: PrashnaVoteType.relevance,
    );
    final correctnessCache = _votingRepository.getCachedVoteState(
      queryId: widget.queryId!,
      voteType: PrashnaVoteType.correctness,
    );

    setState(() {
      _faithfulnessVote = _voteStringToPrashnaVoteValue(faithfulnessCache);
      _relevanceVote = _voteStringToPrashnaVoteValue(relevanceCache);
      _correctnessVote = _voteStringToPrashnaVoteValue(correctnessCache);
    });

    if (faithfulnessCache != null || relevanceCache != null || correctnessCache != null) {
      print('✅ Restored Prashna vote states: F=$_faithfulnessVote, R=$_relevanceVote, C=$_correctnessVote');
    }
  }

  /// Convert vote string to PrashnaVoteValue enum
  PrashnaVoteValue? _voteStringToPrashnaVoteValue(String? vote) {
    if (vote == null) return null;
    switch (vote) {
      case '2':
        return PrashnaVoteValue.excellent;
      case '1':
        return PrashnaVoteValue.good;
      case '0':
        return PrashnaVoteValue.neutral;
      case '-1':
        return PrashnaVoteValue.poor;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<AppThemeColors>()!;
    
    final isScholarMode = TesterModeService.instance.isEnabled;
    final queryId = widget.queryId;
    
    print('═══════════════════════════════════════');
    print('🔍 PRASHNA VOTING WIDGET DEBUG:');
    print('   Scholar Mode: $isScholarMode');
    print('   Query ID: $queryId');
    print('   Will show: ${isScholarMode && queryId != null}');
    print('═══════════════════════════════════════');
    
    // Only show in Scholar Mode
    if (!isScholarMode) {
      print('⚠️ Prashna voting hidden: Scholar Mode OFF');
      return const SizedBox.shrink();
    }

    // Must have queryId
    if (queryId == null) {
      print('⚠️ Prashna voting hidden: No queryId');
      return const SizedBox.shrink();
    }
    
    print('✅ Showing Prashna voting widget!');


    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: themeColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeColors.primary.withOpacity(0.15),
                      themeColors.secondaryColor.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.assessment_outlined,
                  size: 16,
                  color: themeColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Evaluate Response',
                style: TdResTextStyles.p2.copyWith(
                  color: themeColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Faithfulness rating
          _buildRatingSection(
            themeColors: themeColors,
            voteType: PrashnaVoteType.faithfulness,
            currentVote: _faithfulnessVote,
            onVoteChanged: (value) {
              setState(() {
                _faithfulnessVote = value;
              });
            },
          ),
          const SizedBox(height: 10),
          
          // Relevance rating
          _buildRatingSection(
            themeColors: themeColors,
            voteType: PrashnaVoteType.relevance,
            currentVote: _relevanceVote,
            onVoteChanged: (value) {
              setState(() {
                _relevanceVote = value;
              });
            },
          ),
          const SizedBox(height: 10),
          
          // Correctness rating
          _buildRatingSection(
            themeColors: themeColors,
            voteType: PrashnaVoteType.correctness,
            currentVote: _correctnessVote,
            onVoteChanged: (value) {
              setState(() {
                _correctnessVote = value;
              });
            },
          ),
          const SizedBox(height: 12),
          
          // Feedback section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💬 Detailed Feedback (Optional)',
                style: TdResTextStyles.p3.copyWith(
                  color: themeColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Share additional thoughts about this response',
                style: TdResTextStyles.p3.copyWith(
                  color: themeColors.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _feedbackController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g., "Good answer but missing context"',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: themeColors.onSurface.withOpacity(0.4),
                        ),
                        filled: true,
                        fillColor: themeColors.onSurface.withOpacity(0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: themeColors.onSurface.withOpacity(0.15),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: themeColors.onSurface.withOpacity(0.15),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: themeColors.secondaryColor,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: themeColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    child: Material(
                      color: themeColors.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: _isSubmittingFeedback ? null : _submitFeedback,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: _isSubmittingFeedback
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection({
    required AppThemeColors themeColors,
    required PrashnaVoteType voteType,
    required PrashnaVoteValue? currentVote,
    required Function(PrashnaVoteValue?) onVoteChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          voteType.displayName,
          style: TdResTextStyles.p3.copyWith(
            color: themeColors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 3),
        // Description
        Text(
          voteType.description,
          style: TdResTextStyles.p3.copyWith(
            color: themeColors.onSurface.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        // Rating buttons
        Row(
          children: PrashnaVoteValue.values.map((value) {
            final isSelected = currentVote == value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _buildVoteButton(
                  themeColors: themeColors,
                  voteType: voteType,
                  voteValue: value,
                  isSelected: isSelected,
                  onTap: () async {
                    // Toggle behavior: if already selected, deselect (set to null)
                    final newVote = isSelected ? null : value;
                    onVoteChanged(newVote);
                    
                    // Submit the vote
                    if (newVote != null) {
                      await _submitRatingVote(voteType, newVote);
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVoteButton({
    required AppThemeColors themeColors,
    required PrashnaVoteType voteType,
    required PrashnaVoteValue voteValue,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color getBorderColor() {
      if (isSelected) {
        switch (voteValue) {
          case PrashnaVoteValue.excellent:
            return const Color(0xFF10B981); // Green (same as Shodh)
          case PrashnaVoteValue.good:
            return const Color(0xFF3B82F6); // Blue (same as Shodh)
          case PrashnaVoteValue.neutral:
            return const Color(0xFF6B7280); // Gray (same as Shodh)
          case PrashnaVoteValue.poor:
            return const Color(0xFFEF4444); // Red (same as Shodh)
        }
      }
      return themeColors.onSurface.withOpacity(0.2);
    }

    Color getBackgroundColor() {
      if (isSelected) {
        switch (voteValue) {
          case PrashnaVoteValue.excellent:
            return const Color(0xFF10B981).withOpacity(0.15); // Green bg
          case PrashnaVoteValue.good:
            return const Color(0xFF3B82F6).withOpacity(0.15); // Blue bg
          case PrashnaVoteValue.neutral:
            return const Color(0xFF6B7280).withOpacity(0.15); // Gray bg
          case PrashnaVoteValue.poor:
            return const Color(0xFFEF4444).withOpacity(0.15); // Red bg
        }
      }
      return Colors.transparent;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: getBorderColor(),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          children: [
            Text(
              voteValue.icon,
              style: TextStyle(fontSize: isSelected ? 20 : 16),
            ),
            const SizedBox(height: 2),
            Text(
              voteValue.labelForType(voteType),
              style: TdResTextStyles.p3.copyWith(
                color: themeColors.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 10,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRatingVote(PrashnaVoteType voteType, PrashnaVoteValue voteValue) async {
    if (widget.queryId == null) return;

    try {
      final voteRequest = PrashnaVoteRequest.rating(
        queryId: widget.queryId!,
        voteType: voteType,
        voteValue: voteValue,
      );

      print('⭐ Submitting PRASHNA RATING: ${voteType.displayName} = ${voteValue.labelForType(voteType)} (${voteValue.numericValue})');
      final success = await _votingRepository.submitVote(voteRequest);
      
      // Visual feedback is handled by the colored border state
      // No toast needed - user can see their vote from the button color
      if (success) {
        print('✅ ${voteType.displayName} rating submitted successfully');
      }
    } catch (e) {
      print('❌ Failed to submit ${voteType.displayName} rating: $e');
      // Show error toast only for failures
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating - please try again'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }
    
    if (widget.queryId == null) return;

    print('🔵 STARTING PRASHNA FEEDBACK SUBMISSION...');
    print('   QueryID: ${widget.queryId}');
    print('   Feedback length: ${feedback.length} chars');
    
    setState(() {
      _isSubmittingFeedback = true;
    });

    try {
      final voteRequest = PrashnaVoteRequest.feedback(
        queryId: widget.queryId!,
        feedbackText: feedback,
      );

      print('💬 Calling API with: queryId=${widget.queryId}, v_type=feedback, vote="$feedback"');
      
      final success = await _votingRepository.submitVote(voteRequest).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ PRASHNA FEEDBACK TIMEOUT after 10 seconds!');
          throw TimeoutException('Request timed out');
        },
      );
      
      print('🔵 API call completed. Success: $success');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✅ Feedback submitted successfully'
                  : '❌ Failed to submit. Please try again.',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        
        if (success) {
          _feedbackController.clear();
        }
      }
    } on TimeoutException catch (e) {
      print('❌ TIMEOUT ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Request timed out. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ PRASHNA FEEDBACK ERROR: $e');
      print('📍 Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      print('🔵 FINALLY block - resetting loading state');
      if (mounted) {
        setState(() {
          _isSubmittingFeedback = false;
        });
      }
    }
  }
}

