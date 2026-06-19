import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// Runder 40x40 Surface-Button (z. B. für Header-Trailing oder Trash).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.danger = false,
    this.accent = false,
    this.size = 40,
    this.iconSize = 20,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool danger;
  final bool accent;
  final double size;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Color fg = danger
        ? AppColors.danger
        : (accent ? AppColors.accent : AppColors.textPrimary);
    final Color bg = danger
        ? AppColors.dangerSoft
        : (accent ? AppColors.accentSoft : AppColors.surface);
    final Color border = danger
        ? AppColors.danger.withValues(alpha: 0.4)
        : (accent ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      minimumSize: Size(size, size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 1),
        ),
        child: Icon(icon, color: fg, size: iconSize),
      ),
    );
  }
}
