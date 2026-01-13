import 'package:dharak_flutter/app/data/services/tester_mode_service.dart';
import 'package:dharak_flutter/app/data/voting/voting_repository.dart';
import 'package:dharak_flutter/app/types/voting/vote_request.dart';
import 'package:dharak_flutter/app/types/voting/vote_type.dart';
import 'package:dharak_flutter/app/ui/widgets/feedback_modal.dart';
import 'package:dharak_flutter/app/ui/widgets/missing_count_modal.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:dharak_flutter/res/values/dimens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:logger/logger.dart';

/// Voting widget for tool cards
/// Shows vote buttons when tester mode is enabled
class VotingWidget extends StatefulWidget {
  final int? queryId;
  final String? itemId;
  final String? refId; // dict_ref_id, verse_pk, or chunk_ref_id
  final VoteContentType contentType;

  const VotingWidget({
    Key? key,
    required this.queryId,
    required this.itemId,
    required this.refId,
    required this.contentType,
  }) : super(key: key);

  @override
  State<VotingWidget> createState() => _VotingWidgetState();
}

class _VotingWidgetState extends State<VotingWidget> {
  final Logger _logger = Logger();
  VoteValue? _selectedVote;
  bool _isSubmitting = false;
  
  // Get repository from DI
  late final VotingRepository _votingRepository;
  
  @override
  void initState() {
    super.initState();
    _votingRepository = Modular.get<VotingRepository>();
  }

  Future<void> _submitVote(VoteValue voteValue) async {
    if (widget.queryId == null || widget.itemId == null || widget.refId == null) {
      _logger.w('⚠️ Missing voting data: queryId=${widget.queryId}, itemId=${widget.itemId}, refId=${widget.refId}');
      _showSnackBar('Unable to submit: missing required information');
      return;
    }

    // Toggle behavior: if clicking the same vote, set to neutral
    final VoteValue newVote = (_selectedVote == voteValue) ? VoteValue.neutral : voteValue;

    setState(() {
      _selectedVote = newVote;
      _isSubmitting = true;
    });

    try {
      final voteRequest = VoteRequest(
        itemId: widget.itemId!,
        queryId: widget.queryId!,
        value: widget.refId,
        vote: newVote.numericValue.toString(),
      );

      // Submit vote via API (with offline fallback)
      final success = await _votingRepository.submitVote(voteRequest);
      
      if (success) {
        if (newVote == VoteValue.neutral) {
          _showSnackBar('Evaluation cleared');
        } else {
          _showSnackBar('✓ Marked as ${newVote.label}');
        }
      } else {
        _showSnackBar('⏳ Saved offline, will sync later');
      }
      
      _logger.d('✅ Vote submitted: ${newVote.label} for ${widget.contentType.name}');
      
      // ✅ If user voted "Not Relevant", ask if they want to provide feedback
      if (newVote == VoteValue.notRelevant && mounted) {
        _askForFeedbackAfterNotRelevantVote();
      }
      
    } catch (e) {
      _logger.e('❌ Error submitting vote', error: e);
      _showSnackBar('Error submitting evaluation');
      setState(() {
        _selectedVote = null;
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _askForFeedbackAfterNotRelevantVote() async {
    if (!mounted) return;
    
    final shouldGiveFeedback = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share your insights?'),
        content: const Text(
          'Would you like to explain why this result isn\'t relevant? Your scholarly feedback helps improve our search accuracy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Provide Feedback'),
          ),
        ],
      ),
    );

    if (shouldGiveFeedback == true && mounted) {
      // Open the same feedback modal
      _showFeedbackModal(context);
    }
  }

  Future<void> _showFeedbackModal(BuildContext context) async {
    final feedback = await showDialog<String>(
      context: context,
      builder: (context) => FeedbackModal(
        queryId: widget.queryId,
        itemId: widget.itemId,
      ),
    );

    if (feedback != null && feedback.isNotEmpty) {
      _logger.d('📝 Feedback received: $feedback');
      _showSnackBar('Feedback submitted!');
    }
  }

  Future<void> _showMissingCountModal(BuildContext context) async {
    // Show the modal and wait for it to close, get the count
    final int? missingCount = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MissingCountModal(
        queryId: widget.queryId,
      ),
    );
    
    // After the modal closes, ask if user wants to add missing items
    if (mounted && missingCount != null && missingCount > 0) {
      final shouldAdd = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Missing Items?'),
          content: Text(
            'Would you like to tell us what $missingCount result${missingCount > 1 ? 's are' : ' is'} missing? This helps us improve search quality.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Add'),
            ),
          ],
        ),
      );

      if (shouldAdd == true && mounted) {
        _showAddMissingItemsDialog(context, missingCount);
      }
    }
  }

  Future<void> _showAddMissingItemsDialog(BuildContext context, int count) async {
    // Create controllers for each text field
    final controllers = List.generate(count, (_) => TextEditingController());
    
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $count Missing Item${count > 1 ? 's' : ''}'),
        content: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please list the missing items:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                ...List.generate(count, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: controllers[index],
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Item ${index + 1}',
                        hintText: 'E.g., "Verse from Bhagavad Gita 2.47"',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (submitted == true) {
      // Collect all non-empty items
      final items = controllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (items.isNotEmpty) {
        try {
          // Join all items with newlines
          final combinedItems = items.join('\n');
          
          final addMissingRequest = VoteRequest(
            itemId: 'feed_back',
            queryId: widget.queryId!,
            value: 'add_missing',
            vote: combinedItems,
          );

          final success = await _votingRepository.submitVote(addMissingRequest);
          
          _logger.d('✅ Missing items added: $combinedItems');
          
          if (mounted) {
            if (success) {
              _showSnackBar('✅ Thank you for adding ${items.length} missing item${items.length > 1 ? 's' : ''}!');
            } else {
              _showSnackBar('⏳ Saved ${items.length} item${items.length > 1 ? 's' : ''}, will sync later');
            }
          }
        } catch (e) {
          _logger.e('❌ Error submitting missing items', error: e);
        }
      }
    }
    
    // Dispose all controllers
    for (var controller in controllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).extension<AppThemeColors>()!;

    return StreamBuilder<bool>(
      stream: TesterModeService.instance.testerModeStream,
      initialData: TesterModeService.instance.isEnabled,
      builder: (context, snapshot) {
        final isTesterMode = snapshot.data ?? false;
        
        if (!isTesterMode) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(TdResDimens.dp_16),
          decoration: BoxDecoration(
            color: themeColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: themeColors.onSurface.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: themeColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 16,
                      color: themeColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Evaluate Relevance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeColors.onSurface,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Vote buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildVoteButton(
                    context,
                    VoteValue.highlyRelevant,
                    themeColors,
                  ),
                  _buildVoteButton(
                    context,
                    VoteValue.relevant,
                    themeColors,
                  ),
                  _buildVoteButton(
                    context,
                    VoteValue.neutral,
                    themeColors,
                  ),
                  _buildVoteButton(
                    context,
                    VoteValue.notRelevant,
                    themeColors,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Additional actions row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : () => _showFeedbackModal(context),
                      icon: Icon(Icons.edit_note, size: 13, color: themeColors.onSurface.withOpacity(0.7)),
                      label: Text(
                        'Notes',
                        style: TextStyle(fontSize: 10, color: themeColors.onSurface.withOpacity(0.8)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        side: BorderSide(color: themeColors.onSurfaceDisable.withOpacity(0.5)),
                        minimumSize: const Size(0, 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : () => _showMissingCountModal(context),
                      icon: Icon(Icons.playlist_add, size: 13, color: themeColors.onSurface.withOpacity(0.7)),
                      label: Text(
                        'Missing',
                        style: TextStyle(fontSize: 10, color: themeColors.onSurface.withOpacity(0.8)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        side: BorderSide(color: themeColors.onSurfaceDisable.withOpacity(0.5)),
                        minimumSize: const Size(0, 30),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoteButton(
    BuildContext context,
    VoteValue voteValue,
    AppThemeColors themeColors,
  ) {
    final isSelected = _selectedVote == voteValue;
    
    // Academic color scheme (muted, professional)
    Color getButtonColor() {
      if (!isSelected) return themeColors.surface;
      
      switch (voteValue) {
        case VoteValue.highlyRelevant:
          return const Color(0xFF2E7D32); // Deep green
        case VoteValue.relevant:
          return const Color(0xFF1976D2); // Deep blue
        case VoteValue.neutral:
          return const Color(0xFF616161); // Gray
        case VoteValue.notRelevant:
          return const Color(0xFFD84315); // Deep orange
      }
    }
    
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isSubmitting ? null : () => _submitVote(voteValue),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: getButtonColor().withOpacity(isSelected ? 0.1 : 0.02),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected 
                      ? getButtonColor() 
                      : themeColors.onSurfaceDisable.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    voteValue.icon,
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? getButtonColor() : themeColors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voteValue.shortLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? getButtonColor() : themeColors.onSurface.withOpacity(0.7),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

