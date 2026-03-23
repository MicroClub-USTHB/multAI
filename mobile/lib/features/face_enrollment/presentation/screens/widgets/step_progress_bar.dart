import 'package:flutter/material.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../../../../core/theme/theme.dart';
 
class StepProgressBar extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
 
  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });
 
  @override
  State<StepProgressBar> createState() => _StepProgressBarState();
}
 
class _StepProgressBarState extends State<StepProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
 
  double get _targetProgress => widget.currentStep / widget.totalSteps;
 
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    // ✅ starts from 0 always
    _animation = Tween<double>(begin: 0.0, end: _targetProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }
 
  @override
  void didUpdateWidget(StepProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: _targetProgress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller
        ..reset()
        ..forward();
    }
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ✅ bold
            Text(
              'Step ${widget.currentStep} of ${widget.totalSteps}',
              style: tt.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
            // ✅ gold color + bold
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => Text(
                '${(_animation.value * 100).toInt()}%',
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.heightCalculated(8)),
 
        // ✅ thicker progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => LinearProgressIndicator(
              value: _animation.value,
              backgroundColor: AppTheme.inputBorderColor,
              color: AppTheme.primaryColor,
              minHeight: context.heightCalculated(6),
            ),
          ),
        ),
      ],
    );
  }
}