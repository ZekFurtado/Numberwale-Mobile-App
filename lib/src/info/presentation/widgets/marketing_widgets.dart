import 'package:flutter/material.dart';

/// Soft cream-to-white gradient used behind the hero of numberwale.com's
/// marketing pages (Contact Us, FAQ, Why Us).
class MarketingBackground extends StatelessWidget {
  const MarketingBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF1E3), Color(0xFFFFFFFF)],
          stops: [0.0, 0.45],
        ),
      ),
      child: child,
    );
  }
}

/// Small rounded, uppercase badge (e.g. "CONNECT INSTANTLY").
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.label,
    this.background,
    this.foreground,
  });

  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foreground ?? theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// A small orange dot followed by a bold uppercase-ish label, used as a
/// section heading (e.g. "• Corporate & Support").
class DotSectionLabel extends StatelessWidget {
  const DotSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// A colored, rounded-square container for an icon (used in the benefit /
/// feature cards).
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 44,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: foreground, size: size * 0.5),
    );
  }
}
