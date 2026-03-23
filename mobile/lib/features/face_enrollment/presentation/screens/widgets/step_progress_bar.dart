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
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.0, end: _targetProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }
 
  @override
  void didUpdateWidget(StepProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      // animate from current value to new target
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
    final cs = context.theme.colorScheme;
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${widget.currentStep} of ${widget.totalSteps}',
              style: tt.labelMedium?.copyWith(color: cs.onSurface),
            ),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => Text(
                '${(_animation.value * 100).toInt()}%',
                style: tt.labelMedium?.copyWith(color: cs.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: context.heightCalculated(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => LinearProgressIndicator(
              value: _animation.value,
              backgroundColor: AppTheme.inputBorderColor,
              color: cs.primary,
              minHeight: context.heightCalculated(4),
            ),
          ),
        ),
      ],
    );
  }
}
 