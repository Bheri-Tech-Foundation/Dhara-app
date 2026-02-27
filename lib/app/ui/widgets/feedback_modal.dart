import 'package:dharak_flutter/app/data/voting/voting_repository.dart';
import 'package:dharak_flutter/app/types/voting/vote_request.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:dharak_flutter/res/styles/text_styles.dart';
import 'package:dharak_flutter/res/values/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:logger/logger.dart';

/// Modal for collecting detailed feedback from testers
class FeedbackModal extends StatefulWidget {
  final int? queryId;
  final String? itemId;

  const FeedbackModal({
    Key? key,
    required this.queryId,
    this.itemId,
  }) : super(key: key);

  @override
  State<FeedbackModal> createState() => _FeedbackModalState();
}

class _FeedbackModalState extends State<FeedbackModal> {
  final TextEditingController _feedbackController = TextEditingController();
  final Logger _logger = Logger();
  bool _isSubmitting = false;
  late final VotingRepository _votingRepository;
  
  @override
  void initState() {
    super.initState();
    _votingRepository = Modular.get<VotingRepository>();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }

    if (widget.queryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to submit: missing query ID')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final voteRequest = VoteRequest(
        itemId: 'feed_back',  // ALWAYS use "feed_back" for feedback submissions
        queryId: widget.queryId!,
        value: widget.itemId,  // Optional: can specify which item the feedback is for
        vote: feedback,
      );

      final success = await _votingRepository.submitVote(voteRequest);
      
      _logger.d('✅ Feedback submitted: $success');
      
      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Thank you for your feedback!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⏳ Feedback saved, will sync later')),
          );
        }
      }
    } catch (e) {
      _logger.e('❌ Error submitting feedback', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting feedback')),
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

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<AppThemeColors>()!;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: themeColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.feedback_outlined,
                  color: themeColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Provide Feedback',
                  style: TdResTextStyles.h3.copyWith(
                    color: themeColors.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: themeColors.onSurface.withOpacity(0.6),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              'Help us improve by sharing your thoughts on this search result.',
              style: TdResTextStyles.p2.copyWith(
                color: themeColors.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Feedback TextField
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
                hintStyle: TextStyle(
                  color: themeColors.onSurface.withOpacity(0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeColors.onSurfaceDisable,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeColors.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: themeColors.surface.withOpacity(0.3),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: TdResTextStyles.p2.copyWith(
                color: themeColors.onSurface,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit Feedback',
                      style: TdResTextStyles.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

/// Helper function to show the feedback modal
void showFeedbackModal(BuildContext context, {required int? queryId, String? itemId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FeedbackModal(
      queryId: queryId,
      itemId: itemId,
    ),
  );
}

