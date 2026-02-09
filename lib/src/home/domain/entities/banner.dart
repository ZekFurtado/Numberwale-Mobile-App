import 'package:equatable/equatable.dart';

/// Represents a promotional banner displayed on the home screen
class Banner extends Equatable {
  /// Unique identifier for the banner
  final String? id;

  /// Banner title
  final String title;

  /// Banner subtitle/description
  final String subtitle;

  /// Call-to-action button text
  final String buttonText;

  /// Banner image URL (optional, can use icon instead)
  final String? imageUrl;

  /// Icon name or code (if not using image)
  final String? iconName;

  /// Background color hex code
  final String? backgroundColor;

  /// Text color hex code
  final String? textColor;

  /// Deep link or route to navigate to when banner is tapped
  final String? actionUrl;

  /// Display order/priority (lower number = higher priority)
  final int order;

  /// Whether the banner is currently active
  final bool isActive;

  const Banner({
    this.id,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.imageUrl,
    this.iconName,
    this.backgroundColor,
    this.textColor,
    this.actionUrl,
    this.order = 0,
    this.isActive = true,
  });

  /// Generates an empty banner primarily for tests
  const Banner.empty()
      : this(
          id: 'empty.id',
          title: 'empty.title',
          subtitle: 'empty.subtitle',
          buttonText: 'empty.buttonText',
          order: 0,
          isActive: true,
        );

  @override
  List<Object?> get props => [id];
}
