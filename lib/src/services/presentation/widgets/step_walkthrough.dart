import 'package:flutter/material.dart';

const kServiceOrange = Color(0xFFFF8400);
const kServiceTitleGray = Color(0xFF474B67);
const kServiceBodyGray = Color(0xFF8A8A8A);

/// One numbered step in a "how it works" walkthrough: media (image, svg or
/// video) with a numbered badge overlay, an uppercase title, and a
/// justified description.
class StepItem {
  const StepItem({
    required this.number,
    required this.title,
    required this.text,
    required this.media,
    this.leadingIcon,
  });

  final int number;
  final String title;
  final String text;
  final Widget media;
  final Widget? leadingIcon;
}

/// Renders a vertical stack of [StepItem]s with a connector between each,
/// mirroring the numbered walkthrough sections used across the numberwale.com
/// product pages (Smart IVR, SMS Solutions, WhatsApp). The desktop site lays
/// these out as alternating left/right rows connected by a horizontal wavy
/// line; on a single mobile column that reverse-alternation has no visual
/// meaning, so every step just stacks media-then-text with a simple down
/// arrow connector.
class StepWalkthrough extends StatelessWidget {
  const StepWalkthrough({required this.steps, super.key});

  final List<StepItem> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _StepBlock(step: steps[i]),
          if (i < steps.length - 1) const _StepConnector(),
        ],
      ],
    );
  }
}

/// Sliver form of [StepWalkthrough] for use inside a [CustomScrollView].
/// Each step is only built while it's near the viewport, and disposed once
/// scrolled well away — unlike [StepWalkthrough]'s plain [Column], which
/// builds (and keeps alive) every step's media up front. That laziness
/// matters when a step's media is something costly like an autoplaying
/// video: mounting many at once can exhaust a device's hardware decoder
/// pool, and — if two steps happen to share one [StepItem.media] instance —
/// having both alive at the same time is what a shared video texture
/// doesn't reliably support rendering into more than one place at once.
class StepWalkthroughSliver extends StatelessWidget {
  const StepWalkthroughSliver({required this.steps, super.key});

  final List<StepItem> steps;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final isLast = index == steps.length - 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepBlock(step: steps[index]),
              if (!isLast) const _StepConnector(),
            ],
          );
        },
        childCount: steps.length,
      ),
    );
  }
}

class _StepBlock extends StatelessWidget {
  const _StepBlock({required this.step});

  final StepItem step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: step.media,
            ),
            Positioned(
              top: -12,
              left: -12,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: kServiceOrange,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${step.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (step.leadingIcon != null) ...[
              step.leadingIcon!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                step.title.toUpperCase(),
                style: const TextStyle(
                  color: kServiceTitleGray,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          step.text,
          textAlign: TextAlign.justify,
          style: const TextStyle(
              color: kServiceBodyGray, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}

/// Vertical stand-in for the wavy dashed connector drawn between steps on
/// the (horizontally laid out) desktop site.
class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 2,
              height: 16,
              color: kServiceOrange.withValues(alpha: 0.4),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: kServiceOrange, size: 20),
          ],
        ),
      ),
    );
  }
}

/// A network image sized/decorated to match the step media used across
/// these walkthroughs (fixed height, loading spinner, fallback icon).
class NetworkStepImage extends StatelessWidget {
  const NetworkStepImage({required this.url, this.height = 200, super.key});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: const Color(0xFFF3F4F6),
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 40),
        ),
      ),
    );
  }
}
