import 'package:flutter/material.dart';

/// Page indicator voor de onboarding-flow (taal → rijbewijs → regio).
/// Toont een rij bolletjes met een geanimeerde "pill" die naar de actieve stap schuift.
class OnboardingPageIndicator extends StatefulWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.currentIndex,
    this.totalSteps = 3,
  }) : assert(currentIndex >= 0 && currentIndex < totalSteps);

  final int currentIndex;
  final int totalSteps;

  @override
  State<OnboardingPageIndicator> createState() =>
      _OnboardingPageIndicatorState();
}

class _OnboardingPageIndicatorState extends State<OnboardingPageIndicator>
    with SingleTickerProviderStateMixin {
  static const double _dotSize = 8.0;
  static const double _stepWidth = 32.0;
  static const double _pillWidth = 24.0;
  static const double _pillHeight = 8.0;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(OnboardingPageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final inactiveColor = Colors.grey.shade300;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final pillLeft =
            (widget.currentIndex * _stepWidth + (_stepWidth - _pillWidth) / 2) *
                _animation.value;

        return SizedBox(
          height: 24,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.totalSteps, (i) {
                  return SizedBox(
                    width: _stepWidth,
                    child: Center(
                      child: Container(
                        width: _dotSize,
                        height: _dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: inactiveColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Positioned(
                left: pillLeft,
                child: Container(
                  width: _pillWidth,
                  height: _pillHeight,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(_pillHeight / 2),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
