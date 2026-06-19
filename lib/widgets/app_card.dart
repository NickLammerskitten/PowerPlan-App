import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Container-Karte im Dark-Look. Optional mit Tap-Press-Feedback.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.borderColor,
    this.margin,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppRadius.lgAll;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.color ?? AppColors.surface,
        borderRadius: radius,
        border: Border.all(
          color: widget.borderColor ?? AppColors.border,
          width: 1,
        ),
      ),
      transform: _pressed
          ? (Matrix4.identity()..scaleByDouble(0.985, 0.985, 1.0, 1.0))
          : Matrix4.identity(),
      transformAlignment: Alignment.center,
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: card,
    );
  }
}
