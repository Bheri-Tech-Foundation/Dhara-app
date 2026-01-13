import 'package:dharak_flutter/app/data/voting/voting_repository.dart';
import 'package:dharak_flutter/app/types/voting/vote_request.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:dharak_flutter/res/styles/text_styles.dart';
import 'package:dharak_flutter/res/values/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:logger/logger.dart';

/// Modal for reporting missing or incomplete results
class MissingCountModal extends StatefulWidget {
  final int? queryId;

  const MissingCountModal({
    Key? key,
    required this.queryId,
  }) : super(key: key);

  @override
  State<MissingCountModal> createState() => _MissingCountModalState();
}

class _MissingCountModalState extends State<MissingCountModal> {
  final Logger _logger = Logger();
  int _missingCount = 0;
  bool _isSubmitting = false;
  late final VotingRepository _votingRepository;
  
  @override
  void initState() {
    super.initState();
    _votingRepository = Modular.get<VotingRepository>();
  }

  Future<void> _submitMissingCount() async {
    if (widget.queryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to submit: missing query ID')),
      );
      return;
    }

    if (_missingCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a count')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final voteRequest = VoteRequest(
        itemId: 'feed_back',  // Special item ID for missing count
        queryId: widget.queryId!,
        value: 'missing_count',
        vote: _missingCount.toString(),
      );

      final success = await _votingRepository.submitVote(voteRequest);
      
      _logger.d('✅ Missing count submitted: $_missingCount, success: $success');
      
      if (mounted) {
        // Close the bottom sheet and return the count
        Navigator.of(context).pop(_missingCount);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Thank you! Reported $_missingCount missing results')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⏳ Report saved ($_missingCount), will sync later')),
          );
        }
      }
    } catch (e) {
      _logger.e('❌ Error submitting missing count', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting report')),
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
                  Icons.report_outlined,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Report Missing Results',
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
              'How many relevant results do you think are missing from this search?',
              style: TdResTextStyles.p2.copyWith(
                color: themeColors.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Count Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isSubmitting || _missingCount <= 0
                      ? null
                      : () => setState(() => _missingCount--),
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 36,
                  color: themeColors.primary,
                ),
                
                const SizedBox(width: 24),
                
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: themeColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: themeColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _missingCount.toString(),
                      style: TdResTextStyles.h1.copyWith(
                        color: themeColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 24),
                
                IconButton(
                  onPressed: _isSubmitting || _missingCount >= 20
                      ? null
                      : () => setState(() => _missingCount++),
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 36,
                  color: themeColors.primary,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Range: 0-20 missing results',
              textAlign: TextAlign.center,
              style: TdResTextStyles.p3.copyWith(
                color: themeColors.onSurface.withOpacity(0.5),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Select Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [1, 3, 5, 10].map((count) {
                return OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => setState(() => _missingCount = count),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeColors.primary,
                    side: BorderSide(color: themeColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('+$count'),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting || _missingCount == 0 ? null : _submitMissingCount,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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
                      'Submit Report',
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

/// Helper function to show the missing count modal
void showMissingCountModal(BuildContext context, {required int? queryId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MissingCountModal(queryId: queryId),
  );
}

