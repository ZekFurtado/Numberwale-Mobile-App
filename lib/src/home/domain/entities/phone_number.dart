import 'package:equatable/equatable.dart';

/// Represents a phone number product available for purchase
class PhoneNumber extends Equatable {
  /// Unique identifier
  final String? id;

  /// The 10-digit phone number
  final String number;

  /// Price in rupees
  final double price;

  /// Original price (if on discount)
  final double? originalPrice;

  /// Discount percentage (0-100)
  final int discount;

  /// Category name (VIP, Fancy, Lucky, etc.)
  final String category;

  /// Category ID/slug
  final String? categoryId;

  /// Operator (Airtel, Jio, Vi, BSNL)
  final String operator;

  /// Special features/tags (Sequential, Premium, Easy, etc.)
  final List<String> features;

  /// Numerology details
  final Map<String, dynamic>? numerology;

  /// Whether it's ready to port (RTP)
  final bool isRTP;

  /// Whether it's CRTP (Corporate RTP)
  final bool isCRTP;

  /// Whether it's featured on home screen
  final bool isFeatured;

  /// Whether it's a trending number
  final bool isTrending;

  /// Whether it's currently available for purchase
  final bool isAvailable;

  /// Created date
  final DateTime? createdAt;

  const PhoneNumber({
    this.id,
    required this.number,
    required this.price,
    this.originalPrice,
    this.discount = 0,
    required this.category,
    this.categoryId,
    required this.operator,
    this.features = const [],
    this.numerology,
    this.isRTP = false,
    this.isCRTP = false,
    this.isFeatured = false,
    this.isTrending = false,
    this.isAvailable = true,
    this.createdAt,
  });

  /// Generates an empty phone number primarily for tests
  const PhoneNumber.empty()
      : this(
          id: 'empty.id',
          number: '0000000000',
          price: 0,
          category: 'empty',
          operator: 'empty',
        );

  /// Returns the discounted price
  double get discountedPrice {
    if (discount > 0 && originalPrice != null) {
      return originalPrice! * (1 - discount / 100);
    }
    return price;
  }

  /// Returns whether the number is on discount
  bool get hasDiscount => discount > 0 && originalPrice != null;

  @override
  List<Object?> get props => [id, number];
}
