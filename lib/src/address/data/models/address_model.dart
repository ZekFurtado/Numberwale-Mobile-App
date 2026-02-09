import 'dart:convert';

import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/address/domain/entities/address.dart';

/// The model of the Address class. This model extends the entity and adds
/// additional features to it (serialization/deserialization). This is the
/// model that will be used throughout the data layer.
class AddressModel extends Address {
  const AddressModel({
    super.id,
    required super.addressLine1,
    super.addressLine2,
    super.landmark,
    required super.city,
    required super.state,
    required super.pinCode,
    super.isPrimary,
    super.userId,
    super.createdAt,
    super.updatedAt,
  });

  /// Generates an empty Address Model primarily for testing
  const AddressModel.empty()
      : this(
          id: 'empty.id',
          addressLine1: 'empty.addressLine1',
          addressLine2: 'empty.addressLine2',
          landmark: 'empty.landmark',
          city: 'empty.city',
          state: 'empty.state',
          pinCode: '000000',
          isPrimary: false,
          userId: 'empty.userId',
        );

  /// Creates a copy of this address model with updated fields
  @override
  AddressModel copyWith({
    String? id,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? state,
    String? pinCode,
    bool? isPrimary,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      isPrimary: isPrimary ?? this.isPrimary,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates an AddressModel from a JSON map
  factory AddressModel.fromJson(String source) =>
      AddressModel.fromMap(jsonDecode(source) as DataMap);

  /// Creates an AddressModel from a Map
  factory AddressModel.fromMap(DataMap map) {
    return AddressModel(
      id: map['id'] as String?,
      addressLine1: map['addressLine1'] as String? ?? map['address_line_1'] as String,
      addressLine2: map['addressLine2'] as String? ?? map['address_line_2'] as String?,
      landmark: map['landmark'] as String?,
      city: map['city'] as String,
      state: map['state'] as String,
      pinCode: map['pinCode'] as String? ?? map['pin_code'] as String,
      isPrimary: map['isPrimary'] as bool? ?? map['is_primary'] as bool? ?? false,
      userId: map['userId'] as String? ?? map['user_id'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : (map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : null),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : (map['updated_at'] != null
              ? DateTime.parse(map['updated_at'] as String)
              : null),
    );
  }

  /// Converts this AddressModel to a JSON string
  String toJson() => jsonEncode(toMap());

  /// Converts this AddressModel to a Map
  DataMap toMap() {
    return {
      if (id != null) 'id': id,
      'addressLine1': addressLine1,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      if (landmark != null) 'landmark': landmark,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'isPrimary': isPrimary,
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
