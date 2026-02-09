import 'dart:convert';

import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/address/domain/entities/location_info.dart';

/// The model of the LocationInfo class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class LocationInfoModel extends LocationInfo {
  const LocationInfoModel({
    required super.pinCode,
    required super.city,
    required super.state,
    super.district,
    required super.country,
  });

  /// Generates an empty LocationInfo Model primarily for testing
  const LocationInfoModel.empty()
      : this(
          pinCode: '000000',
          city: 'empty.city',
          state: 'empty.state',
          district: 'empty.district',
          country: 'India',
        );

  /// Creates a LocationInfoModel from a JSON map
  factory LocationInfoModel.fromJson(String source) =>
      LocationInfoModel.fromMap(jsonDecode(source) as DataMap);

  /// Creates a LocationInfoModel from a Map
  factory LocationInfoModel.fromMap(DataMap map) {
    return LocationInfoModel(
      pinCode: map['pinCode'] as String? ?? map['pin_code'] as String? ?? map['pincode'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      district: map['district'] as String?,
      country: map['country'] as String? ?? 'India',
    );
  }

  /// Converts this LocationInfoModel to a JSON string
  String toJson() => jsonEncode(toMap());

  /// Converts this LocationInfoModel to a Map
  DataMap toMap() {
    return {
      'pinCode': pinCode,
      'city': city,
      'state': state,
      if (district != null) 'district': district,
      'country': country,
    };
  }
}
