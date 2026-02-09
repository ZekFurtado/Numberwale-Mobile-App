import 'package:equatable/equatable.dart';

/// Represents a delivery/billing address in the app
class Address extends Equatable {
  /// Unique ID of the address
  final String? id;

  /// First line of the address (House No., Building Name)
  final String addressLine1;

  /// Second line of the address (Road, Area, Colony) - Optional
  final String? addressLine2;

  /// Landmark near the address - Optional
  final String? landmark;

  /// City name
  final String city;

  /// State name
  final String state;

  /// 6-digit PIN code
  final String pinCode;

  /// Whether this is the primary/default address
  final bool isPrimary;

  /// User ID this address belongs to
  final String? userId;

  /// Timestamp when address was created
  final DateTime? createdAt;

  /// Timestamp when address was last updated
  final DateTime? updatedAt;

  const Address({
    this.id,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.pinCode,
    this.isPrimary = false,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Generates an empty address primarily for tests
  const Address.empty()
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

  /// Creates a copy of this address with updated fields
  Address copyWith({
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
    return Address(
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

  /// Returns the full formatted address as a single string
  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      if (landmark != null && landmark!.isNotEmpty) 'Near $landmark',
      '$city, $state - $pinCode',
    ];
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [id];
}
