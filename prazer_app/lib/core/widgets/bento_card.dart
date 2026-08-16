import 'package:flutter/material.dart';
import '../theme/prazer_colors.dart';

/// Bento Grid card component adhering to prazer_design_prompt.md §2C
class BentoCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Border? border;
  final double borderRadius;

  const BentoCard({
    super.key,
    required this.child,
    this.backgroundColor = PrazerColors.surfaceWhite,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.border,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: PrazerColors.borderSubtle, width: 1),
        boxShadow: const [
          BoxShadow(
            color: PrazerColors.shadowSubtle,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          hoverColor: PrazerColors.coolHorizon.withOpacity(0.05),
          splashColor: PrazerColors.coolHorizon.withOpacity(0.1),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
