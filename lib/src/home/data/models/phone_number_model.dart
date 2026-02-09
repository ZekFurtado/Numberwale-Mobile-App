import 'dart:convert';

import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';

/// The model of the PhoneNumber class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class PhoneNumberModel extends PhoneNumber {
  const PhoneNumberModel({
    super.id,
    required super.number,
    required super.price,
    super.originalPrice,
    super.discount,
    required super.category,
    super.categoryId,
    required super.operator,
    super.features,
    super.numerology,
    super.isRTP,
    super.isCRTP,
    super.isFeatured,
    super.isTrending,
    super.isAvailable,
    super.createdAt,
  });

  /// Generates an empty PhoneNumber Model primarily for testing
  const PhoneNumberModel.empty()
      : this(
          id: 'empty.id',
          number: '0000000000',
          price: 0,
          category: 'empty',
          operator: 'empty',
        );

  /// Creates a PhoneNumberModel from a JSON map
  factory PhoneNumberModel.fromJson(String source) =>
      PhoneNumberModel.fromMap(jsonDecode(source) as DataMap);

  /// Creates a PhoneNumberModel from a Map
  factory PhoneNumberModel.fromMap(DataMap map) {
    return PhoneNumberModel(
      id: map['id'] as String?,
      number: map['number'] as String,
      price: (map['price'] as num).toDouble(),
      originalPrice: map['originalPrice'] != null
          ? (map['originalPrice'] as num).toDouble()
          : (map['original_price'] != null
              ? (map['original_price'] as num).toDouble()
              : null),
      discount: (map['discount'] as num?)?.toInt() ?? 0,
      category: map['category'] as String,
      categoryId: map['categoryId'] as String? ?? map['category_id'] as String?,
      operator: map['operator'] as String,
      features: map['features'] != null
          ? List<String>.from(map['features'] as List<dynamic>)
          : [],
      numerology: map['numerology'] as Map<String, dynamic>?,
      isRTP: map['isRTP'] as bool? ?? map['is_rtp'] as bool? ?? false,
      isCRTP: map['isCRTP'] as bool? ?? map['is_crtp'] as bool? ?? false,
      isFeatured: map['isFeatured'] as bool? ?? map['is_featured'] as bool? ?? false,
      isTrending: map['isTrending'] as bool? ?? map['is_trending'] as bool? ?? false,
      isAvailable: map['isAvailable'] as bool? ?? map['is_available'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : (map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : null),
    );
  }

  /// Converts this PhoneNumberModel to a JSON string
  String toJson() => jsonEncode(toMap());

  /// Converts this PhoneNumberModel to a Map
  DataMap toMap() {
    return {
      if (id != null) 'id': id,
      'number': number,
      'price': price,
      if (originalPrice != null) 'originalPrice': originalPrice,
      'discount': discount,
      'category': category,
      if (categoryId != null) 'categoryId': categoryId,
      'operator': operator,
      'features': features,
      if (numerology != null) 'numerology': numerology,
      'isRTP': isRTP,
      'isCRTP': isCRTP,
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'isAvailable': isAvailable,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
