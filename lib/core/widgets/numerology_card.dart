import 'package:flutter/material.dart';

class NumerologyCard extends StatefulWidget {
  const NumerologyCard({
    super.key,
    this.literSum,
    this.trapSum,
    this.scoreSum,
  });

  final int? literSum;
  final int? trapSum;
  final int? scoreSum;

  @override
  State<NumerologyCard> createState() => _NumerologyCardState();
}

class _NumerologyCardState extends State<NumerologyCard> {
  bool _isExpanded = false;

  String _getNumerologyMeaning(String type, int value) {
    // Simplified numerology meanings
    final meanings = {
      'liter': {
        1: 'Leadership, independence, and new beginnings',
        2: 'Partnership, balance, and diplomacy',
        3: 'Creativity, expression, and joy',
        4: 'Stability, hard work, and foundation',
        5: 'Freedom, adventure, and change',
        6: 'Love, harmony, and responsibility',
        7: 'Spirituality, wisdom, and introspection',
        8: 'Power, success, and material abundance',
        9: 'Completion, humanitarianism, and idealism',
      },
      'trap': {
        1: 'Strong willpower and determination',
        2: 'Cooperation and sensitivity',
        3: 'Optimism and enthusiasm',
        4: 'Practicality and organization',
        5: 'Versatility and resourcefulness',
        6: 'Nurturing and caring nature',
        7: 'Analytical and thoughtful',
        8: 'Ambitious and goal-oriented',
        9: 'Compassionate and selfless',
      },
      'score': {
        1: 'New opportunities and fresh starts',
        2: 'Collaboration and partnerships',
        3: 'Creative expression and communication',
        4: 'Building strong foundations',
        5: 'Embracing change and freedom',
        6: 'Family and domestic harmony',
        7: 'Spiritual growth and learning',
        8: 'Financial success and achievement',
        9: 'Universal love and wisdom',
      },
    };

    final typeMeanings = meanings[type] ?? {};
    return typeMeanings[value] ?? 'Positive energy';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = widget.literSum != null ||
        widget.trapSum != null ||
        widget.scoreSum != null;

    if (!hasData) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: 24,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Numerology Analysis',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to ${_isExpanded ? 'collapse' : 'expand'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Liter Sum
                  if (widget.literSum != null) ...[
                    _NumerologyItem(
                      label: 'Liter Sum',
                      value: widget.literSum!,
                      meaning: _getNumerologyMeaning('liter', widget.literSum!),
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Trap Sum
                  if (widget.trapSum != null) ...[
                    _NumerologyItem(
                      label: 'Trap Sum',
                      value: widget.trapSum!,
                      meaning: _getNumerologyMeaning('trap', widget.trapSum!),
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Score Sum
                  if (widget.scoreSum != null) ...[
                    _NumerologyItem(
                      label: 'Score Sum',
                      value: widget.scoreSum!,
                      meaning: _getNumerologyMeaning('score', widget.scoreSum!),
                      theme: theme,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // CTA for consultation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.tertiaryContainer,
                          theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Want a detailed analysis?',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get personalized numerology consultation from our experts',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NumerologyItem extends StatelessWidget {
  const _NumerologyItem({
    required this.label,
    required this.value,
    required this.meaning,
    required this.theme,
  });

  final String label;
  final int value;
  final String meaning;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meaning,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
