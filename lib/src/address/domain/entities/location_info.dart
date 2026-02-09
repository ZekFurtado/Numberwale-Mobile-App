import 'package:equatable/equatable.dart';

/// Represents location information retrieved from a PIN code
class LocationInfo extends Equatable {
  /// PIN code
  final String pinCode;

  /// City name
  final String city;

  /// State name
  final String state;

  /// District name - Optional
  final String? district;

  /// Country name
  final String country;

  const LocationInfo({
    required this.pinCode,
    required this.city,
    required this.state,
    this.district,
    required this.country,
  });

  /// Generates an empty location info primarily for tests
  const LocationInfo.empty()
      : this(
          pinCode: '000000',
          city: 'empty.city',
          state: 'empty.state',
          district: 'empty.district',
          country: 'India',
        );

  @override
  List<Object?> get props => [pinCode, city, state];
}
