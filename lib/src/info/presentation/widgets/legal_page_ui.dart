import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Exact color values used by the legal/CMS pages on numberwale.com
/// (Tailwind's default `orange` and `gray` scales, with `primary` aliased
/// to `orange-600`). Kept separate from the app's own [ColorScheme] since
/// the app's brand color does not match the website's.
class LegalColors {
  const LegalColors._();

  static const primary = Color(0xFFEA580C);
  static const orange400 = Color(0xFFFB923C);
  static const orange500 = Color(0xFFF97316);
  static const orange50 = Color(0xFFFFF7ED);
  static const orange100 = Color(0xFFFFEDD5);
  static const orange200 = Color(0xFFFED7AA);
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray900 = Color(0xFF111827);
}

/// The gradient hero banner at the top of a legal page: an
/// orange-500-to-primary rounded card with two soft blurred accent blobs,
/// an optional uppercase pill badge, an icon tile, a title and a subtitle.
class LegalHero extends StatelessWidget {
  const LegalHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [LegalColors.orange500, LegalColors.primary],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -64,
              right: -64,
              child: _blurBlob(256, Colors.white.withValues(alpha: 0.2)),
            ),
            Positioned(
              bottom: -48,
              left: -48,
              child: _blurBlob(192, Colors.black.withValues(alpha: 0.1)),
            ),
            Column(
              children: [
                if (badgeLabel != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      badgeLabel!,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: LegalColors.orange50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 30,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: LegalColors.orange50.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

/// A single full-width highlight/feature card (icon tile + title + desc),
/// stacked one-per-row the way the website's grid collapses to a single
/// column at phone widths.
class LegalHighlightCard extends StatelessWidget {
  const LegalHighlightCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LegalColors.gray100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LegalColors.orange50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: LegalColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: LegalColors.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    height: 1.5,
                    color: LegalColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The two-digit, gradient-filled, monospace section index (e.g. "01")
/// shown next to every section heading.
class LegalSectionNumber extends StatelessWidget {
  const LegalSectionNumber(this.index, {super.key, this.fontSize = 20});

  final int index;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [LegalColors.orange400, LegalColors.primary],
      ).createShader(bounds),
      child: Text(
        (index + 1).toString().padLeft(2, '0'),
        style: GoogleFonts.robotoMono(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// The sticky, horizontally-scrolling row of section pills shown on phone
/// widths in place of the desktop sidebar table of contents.
class LegalTocBar extends StatelessWidget {
  const LegalTocBar({
    super.key,
    required this.titles,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> titles;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (var i = 0; i < titles.length; i++) ...[
              _Pill(
                label: titles[i],
                active: i == activeIndex,
                onTap: () => onTap(i),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? LegalColors.primary : LegalColors.gray50,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: LegalColors.orange200.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : LegalColors.gray500,
          ),
        ),
      ),
    );
  }
}

/// Pinned [SliverPersistentHeaderDelegate] wrapper for [LegalTocBar].
class LegalTocBarDelegate extends SliverPersistentHeaderDelegate {
  LegalTocBarDelegate({
    required this.titles,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> titles;
  final int activeIndex;
  final ValueChanged<int> onTap;

  static const double height = 56;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: LegalColors.gray100)),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: LegalTocBar(
        titles: titles,
        activeIndex: activeIndex,
        onTap: onTap,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant LegalTocBarDelegate oldDelegate) {
    return oldDelegate.titles != titles ||
        oldDelegate.activeIndex != activeIndex;
  }
}
