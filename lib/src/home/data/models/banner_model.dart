import 'dart:convert';

import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/home/domain/entities/banner.dart';

/// The model of the Banner class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class BannerModel extends Banner {
  const BannerModel({
    super.id,
    required super.title,
    required super.subtitle,
    required super.buttonText,
    super.imageUrl,
    super.iconName,
    super.backgroundColor,
    super.textColor,
    super.actionUrl,
    super.order,
    super.isActive,
  });

  /// Generates an empty Banner Model primarily for testing
  const BannerModel.empty()
      : this(
          id: 'empty.id',
          title: 'empty.title',
          subtitle: 'empty.subtitle',
          buttonText: 'empty.buttonText',
          order: 0,
          isActive: true,
        );

  /// Creates a BannerModel from a JSON map
  factory BannerModel.fromJson(String source) =>
      BannerModel.fromMap(jsonDecode(source) as DataMap);

  /// Creates a BannerModel from a Map
  factory BannerModel.fromMap(DataMap map) {
    return BannerModel(
      id: map['id'] as String?,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      buttonText: map['buttonText'] as String? ?? map['button_text'] as String,
      imageUrl: map['imageUrl'] as String? ?? map['image_url'] as String?,
      iconName: map['iconName'] as String? ?? map['icon_name'] as String?,
      backgroundColor: map['backgroundColor'] as String? ?? map['background_color'] as String?,
      textColor: map['textColor'] as String? ?? map['text_color'] as String?,
      actionUrl: map['actionUrl'] as String? ?? map['action_url'] as String?,
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? map['is_active'] as bool? ?? true,
    );
  }

  /// Converts this BannerModel to a JSON string
  String toJson() => jsonEncode(toMap());

  /// Converts this BannerModel to a Map
  DataMap toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'subtitle': subtitle,
      'buttonText': buttonText,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (iconName != null) 'iconName': iconName,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (textColor != null) 'textColor': textColor,
      if (actionUrl != null) 'actionUrl': actionUrl,
      'order': order,
      'isActive': isActive,
    };
  }
}
