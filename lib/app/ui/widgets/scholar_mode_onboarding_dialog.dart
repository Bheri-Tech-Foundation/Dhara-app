import 'package:dharak_flutter/app/data/services/tester_mode_service.dart';
import 'package:dharak_flutter/res/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

/// Shows onboarding dialog when user enables Scholar Mode for the first time
Future<void> showScholarModeOnboarding(BuildContext context) async {
  final hasSeenOnboarding = await TesterModeService.instance.hasSeenOnboarding();
  
  if (hasSeenOnboarding) return;
  
  if (!context.mounted) return;
  
  final themeColors = Theme.of(context).extension<AppThemeColors>();
  
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.school,
            color: themeColors?.primary ?? Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Welcome to Scholar Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'As a scholar, your expert evaluation helps improve our Dhara app.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: themeColors?.onSurface.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 18),
            
            // Evaluation options
            Text(
              'Evaluation Scale (Consistent Pattern):',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeColors?.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            _buildRatingOption('✓✓', 'Highly X', 'Highly Faithful/Correct/Relevant', themeColors),
            const SizedBox(height: 8),
            _buildRatingOption('✓', 'X', 'Faithful/Correct/Relevant', themeColors),
            const SizedBox(height: 8),
            _buildRatingOption('?', 'Not Sure', 'Cannot verify or decide', themeColors),
            const SizedBox(height: 8),
            _buildRatingOption('✗', 'Not X', 'Not Faithful/Incorrect/Not Relevant', themeColors),
            
            const SizedBox(height: 18),
            Divider(color: themeColors?.onSurface.withOpacity(0.2), height: 1),
            const SizedBox(height: 18),
            
            // Instructions
            _buildInstructionItem(
              icon: Icons.search,
              title: 'Shodh (Search)',
              description: 'Rate relevance of each definition, verse, or book result',
              themeColors: themeColors,
            ),
            const SizedBox(height: 14),
            _buildInstructionItem(
              icon: Icons.chat,
              title: 'Prashna (AI Chat)',
              description: 'Evaluate faithfulness, correctness, and relevance of AI answers',
              themeColors: themeColors,
            ),
            const SizedBox(height: 14),
            _buildInstructionItem(
              icon: Icons.feedback_outlined,
              title: 'Share Feedback',
              description: 'Report missing resources and provide detailed comments',
              themeColors: themeColors,
            ),
            
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeColors?.primary.withOpacity(0.08) ?? Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: themeColors?.primary.withOpacity(0.25) ?? Colors.blue.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: themeColors?.primary ?? Colors.blue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your scholarly input directly improves the accuracy of Dhara for all users.',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeColors?.onSurface.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await TesterModeService.instance.markOnboardingAsSeen();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(
            'Got it!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeColors?.primary ?? Colors.blue,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildRatingOption(
  String symbol,
  String label,
  String description,
  AppThemeColors? themeColors,
) {
  return Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: themeColors?.primary.withOpacity(0.08) ?? Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: themeColors?.primary.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: themeColors?.onSurface,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: themeColors?.onSurface,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: themeColors?.onSurface.withOpacity(0.6),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildInstructionItem({
  required IconData icon,
  required String title,
  required String description,
  required AppThemeColors? themeColors,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: themeColors?.primary.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: themeColors?.primary ?? Colors.blue,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: themeColors?.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

