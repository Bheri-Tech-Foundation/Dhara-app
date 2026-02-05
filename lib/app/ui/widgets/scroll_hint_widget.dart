import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shows a subtle hint to scroll down for evaluation on first expanded card
class ScrollHintWidget extends StatefulWidget {
  const ScrollHintWidget({Key? key}) : super(key: key);

  @override
  State<ScrollHintWidget> createState() => _ScrollHintWidgetState();
}

class _ScrollHintWidgetState extends State<ScrollHintWidget>
    with SingleTickerProviderStateMixin {
  static const String _hasSeenScrollHintKey = 'has_seen_scroll_hint';
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _checkIfShouldShow();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );

    _controller.repeat(reverse: true);

    // Auto-hide after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _hide();
      }
    });
  }

  Future<void> _checkIfShouldShow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenHint = prefs.getBool(_hasSeenScrollHintKey) ?? false;
      
      if (hasSeenHint) {
        setState(() {
          _isVisible = false;
        });
      } else {
        // Mark as seen
        await prefs.setBool(_hasSeenScrollHintKey, true);
      }
    } catch (e) {
      // Silent fail
    }
  }

  void _hide() {
    setState(() {
      _isVisible = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 14,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Scroll down to evaluate',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}






