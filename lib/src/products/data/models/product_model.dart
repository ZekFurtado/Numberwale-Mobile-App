import 'dart:convert';

import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/phone_number.dart';

/// The model for a PhoneNumber product from the Products API.
/// Maps from the backend response format:
/// productMobileNumber, pricing.nwFinalPrice, category object, etc.
class ProductModel extends PhoneNumber {
  const ProductModel({
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

  const ProductModel.empty()
      : this(
          id: 'empty.id',
          number: '0000000000',
          price: 0,
          category: 'empty',
          operator: 'empty',
        );

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(jsonDecode(source) as DataMap);

  /// Creates a ProductModel from the Products API response format
  factory ProductModel.fromMap(DataMap map) {
    // Handle pricing
    final pricing = map['pricing'] as DataMap?;
    final finalPrice = pricing != null
        ? (pricing['nwFinalPrice'] as num?)?.toDouble() ?? 0.0
        : (map['price'] as num?)?.toDouble() ?? 0.0;

    final basePrice = pricing != null
        ? (pricing['nwBasePrice'] != null
            ? ((pricing['nwBasePrice'] as DataMap)['inr'] as num?)?.toDouble()
            : null)
        : null;

    final discountPct = pricing != null
        ? (pricing['nwMyDiscount'] as num?)?.toInt() ?? 0
        : (map['discount'] as num?)?.toInt() ?? 0;

    // Handle category - can be object or string
    String categoryName = 'Unknown';
    String? categoryId;
    final categoryRaw = map['category'];
    if (categoryRaw is DataMap) {
      categoryName = categoryRaw['name'] as String? ?? 'Unknown';
      categoryId = categoryRaw['_id'] as String? ?? categoryRaw['id'] as String?;
    } else if (categoryRaw is String) {
      categoryName = categoryRaw;
    }

    // Handle availability
    final availability = map['availability'] as DataMap?;
    final isAvailable = availability != null
        ? (availability['status'] as String?) == 'available'
        : (map['isAvailable'] as bool? ?? true);

    // Handle readyToPort
    final rtpValue = map['readyToPort'] as String?;
    final isRTP = rtpValue == 'rtp';
    final isCRTP = rtpValue == 'crtp';

    // Handle features from numerology
    final numerologyMap = map['numerology'] as DataMap?;

    return ProductModel(
      id: map['_id'] as String? ?? map['id'] as String?,
      number: map['productMobileNumber'] as String? ??
          map['number'] as String? ??
          '0000000000',
      price: finalPrice,
      originalPrice: basePrice,
      discount: discountPct,
      category: categoryName,
      categoryId: categoryId,
      operator: map['productBrand'] as String? ??
          map['operator'] as String? ??
          'Unknown',
      features: map['features'] != null
          ? List<String>.from(map['features'] as List<dynamic>)
          : [],
      numerology: numerologyMap,
      isRTP: isRTP,
      isCRTP: isCRTP,
      isFeatured: map['isFeatured'] as bool? ?? false,
      isTrending: map['isTrending'] as bool? ?? false,
      isAvailable: isAvailable,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  DataMap toMap() {
    return {
      if (id != null) '_id': id,
      'productMobileNumber': number,
      'pricing': {
        'nwFinalPrice': price,
        if (originalPrice != null) 'nwBasePrice': {'inr': originalPrice},
        'nwMyDiscount': discount,
      },
      'category': categoryId ?? category,
      'productBrand': operator,
      'features': features,
      if (numerology != null) 'numerology': numerology,
      'readyToPort': isRTP
          ? 'rtp'
          : (isCRTP ? 'crtp' : null),
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'availability': {'status': isAvailable ? 'available' : 'sold'},
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());
}
