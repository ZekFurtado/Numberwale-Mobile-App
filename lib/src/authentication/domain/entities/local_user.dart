import 'package:equatable/equatable.dart';

/// Represents the field resource that will use the app
class LocalUser extends Equatable {
  /// Unique ID of the visitor assigned by Firebase
  final String? uid;

  /// Username of the visitor if set
  final String? name;

  /// First name of the user
  final String? firstName;

  /// Last name of the user
  final String? lastName;

  /// Email of the visitor
  final String? email;

  /// Visitor phone
  final String? phone;

  /// URL of the profile picture of the user if set
  final String? profilePic;

  /// User role (admin or user)
  final String? role;

  /// User coin balance
  final int coins;

  /// Whether this is a first-time user (for onboarding)
  final bool isFirstTime;

  const LocalUser({
    this.uid,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.profilePic,
    this.role,
    this.coins = 0,
    this.isFirstTime = false,
  });

  /// Generates a default visitor primarily for tests
  const LocalUser.empty()
      : this(
          email: 'empty.email',
          name: 'empty.name',
          firstName: 'empty.firstName',
          lastName: 'empty.lastName',
          uid: 'empty.uid',
          role: 'user',
          coins: 500,
          isFirstTime: false,
        );

  LocalUser copyWith({
    String? uid,
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profilePic,
    String? role,
    int? coins,
    bool? isFirstTime,
  }) {
    return LocalUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePic: profilePic ?? this.profilePic,
      role: role ?? this.role,
      coins: coins ?? this.coins,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }

  @override
  List<Object?> get props => [uid];
}
