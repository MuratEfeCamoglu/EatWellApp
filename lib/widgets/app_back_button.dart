import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The rounded "back" icon button used at the top of most stack screens
/// (48x48, rounded-16, surface background, outline border).
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed, this.icon = Icons.arrow_back_ios_new_rounded});

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.dengeColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}
