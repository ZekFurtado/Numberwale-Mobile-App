import 'package:equatable/equatable.dart';

/// Represents a phone number category (VIP, Fancy, Lucky, etc.)
class Category extends Equatable {
  /// Unique identifier for the category
  final String? id;

  /// Category name (e.g., "VIP Numbers", "Fancy Numbers")
  final String name;

  /// Category slug for URL/routing (e.g., "vip", "fancy")
  final String slug;

  /// Category description
  final String? description;

  /// Icon name or code
  final String? iconName;

  /// Category color hex code
  final String? color;

  /// Number of items in this category
  final int count;

  /// Display order (lower number = higher priority)
  final int order;

  /// Whether the category is featured on home screen
  final bool isFeatured;

  /// Whether the category is currently active
  final bool isActive;

  const Category({
    this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconName,
    this.color,
    this.count = 0,
    this.order = 0,
    this.isFeatured = false,
    this.isActive = true,
  });

  /// Generates an empty category primarily for tests
  const Category.empty()
      : this(
          id: 'empty.id',
          name: 'empty.name',
          slug: 'empty',
          count: 0,
          order: 0,
        );

  @override
  List<Object?> get props => [id, slug];
}
