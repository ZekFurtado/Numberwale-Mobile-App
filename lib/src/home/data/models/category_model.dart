import 'dart:convert';

import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/category.dart';

/// The model of the Category class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class CategoryModel extends Category {
  const CategoryModel({
    super.id,
    required super.name,
    required super.slug,
    super.description,
    super.iconName,
    super.color,
    super.count,
    super.order,
    super.isFeatured,
    super.isActive,
  });

  /// Generates an empty Category Model primarily for testing
  const CategoryModel.empty()
      : this(
          id: 'empty.id',
          name: 'empty.name',
          slug: 'empty',
          count: 0,
          order: 0,
        );

  /// Creates a CategoryModel from a JSON map
  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(jsonDecode(source) as DataMap);

  /// Creates a CategoryModel from a Map
  factory CategoryModel.fromMap(DataMap map) {
    return CategoryModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      slug: map['slug'] as String,
      description: map['description'] as String?,
      iconName: map['iconName'] as String? ?? map['icon_name'] as String?,
      color: map['color'] as String?,
      count: (map['count'] as num?)?.toInt() ?? 0,
      order: (map['order'] as num?)?.toInt() ?? 0,
      isFeatured: map['isFeatured'] as bool? ?? map['is_featured'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? map['is_active'] as bool? ?? true,
    );
  }

  /// Converts this CategoryModel to a JSON string
  String toJson() => jsonEncode(toMap());

  /// Converts this CategoryModel to a Map
  DataMap toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'slug': slug,
      if (description != null) 'description': description,
      if (iconName != null) 'iconName': iconName,
      if (color != null) 'color': color,
      'count': count,
      'order': order,
      'isFeatured': isFeatured,
      'isActive': isActive,
    };
  }
}
