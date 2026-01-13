import 'package:dharak_flutter/app/data/voting/voting_repository.dart';
import 'package:dharak_flutter/app/data/services/tester_mode_service.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:dharak_flutter/res/styles/text_styles.dart';
import 'package:flutter/material.dart';

/// Simple widget to display total votes count for testers
class VoteCounterWidget extends StatelessWidget {
  final bool isCompact;

  const VoteCounterWidget({
    Key? key,
    this.isCompact = false,
  }) : super(key: key);

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

        return FutureBuilder<int>(
          future: VotingRepository.getTotalVotesCountStatic(),
          builder: (context, voteSnapshot) {
            final voteCount = voteSnapshot.data ?? 0;

            if (isCompact) {
              return _buildCompactView(voteCount, themeColors);
            } else {
              return _buildFullView(voteCount, themeColors);
            }
          },
        );
      },
    );
  }

  Widget _buildCompactView(int count, AppThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: themeColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: themeColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TdResTextStyles.caption.copyWith(
              color: themeColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullView(int count, AppThemeColors themeColors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColors.primary.withOpacity(0.1),
            themeColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Votes',
                style: TdResTextStyles.caption.copyWith(
                  color: themeColors.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: TdResTextStyles.h3.copyWith(
                  color: themeColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Floating vote counter badge that can be positioned anywhere
class FloatingVoteCounterBadge extends StatelessWidget {
  const FloatingVoteCounterBadge({Key? key}) : super(key: key);

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

        return FutureBuilder<int>(
          future: VotingRepository.getTotalVotesCountStatic(),
          builder: (context, voteSnapshot) {
            final voteCount = voteSnapshot.data ?? 0;

            return Positioned(
              bottom: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themeColors.primary, themeColors.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$voteCount vote${voteCount != 1 ? 's' : ''}',
                        style: TdResTextStyles.button.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}





