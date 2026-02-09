import 'dart:developer';

import '../../../../core/utils/typedef.dart';
import '../../domain/entities/local_user.dart';

/// The model of the visitor class. This model extends the entity and adds
/// additional features to it. This is the model that will be used throughout
/// the data layer.
class LocalUserModel extends LocalUser {
  const LocalUserModel({
    super.uid,
    super.name,
    super.firstName,
    super.lastName,
    super.email,
    super.phone,
    super.profilePic,
    super.role,
    super.coins,
    super.isFirstTime,
  });

  /// Generates a default Visitor Model. This is also primary used for testing.
  const LocalUserModel.empty()
      : this(
          uid: 'empty.uid',
          name: 'empty.name',
          firstName: 'empty.firstName',
          lastName: 'empty.lastName',
          email: 'empty.email',
          role: 'user',
          coins: 500,
          isFirstTime: false,
        );


  /// Adds the new properties to the existing [LocalUser] object. This method is
  /// called after the visitor has signed in to Firebase and has retrieved its
  /// additional data after calling our backend APIs
  @override
  LocalUserModel copyWith({
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
    return LocalUserModel(
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

  /// Creates a [LocalUserModel] from a map (JSON object from API)
  factory LocalUserModel.fromMap(DataMap map) {
    return LocalUserModel(
      uid: map['_id'] as String? ?? map['id'] as String?,
      name: map['name'] as String?,
      firstName: map['firstName'] as String?,
      lastName: map['lastName'] as String?,
      email: map['email'] as String?,
      phone: map['mobile'] as String? ?? map['phone'] as String?,
      profilePic: map['profilePic'] as String?,
      role: map['role'] as String? ?? 'user',
      coins: map['coins'] as int? ?? 0,
      isFirstTime: map['isFirstTime'] as bool? ?? false,
    );
  }

  /// Converts the [LocalUserModel] to a map for JSON serialization
  DataMap toMap() {
    return {
      'id': uid,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profilePic': profilePic,
      'role': role,
      'coins': coins,
      'isFirstTime': isFirstTime,
    };
  }

  /// Creates a [LocalUserModel] from a JSON string
  factory LocalUserModel.fromJson(String source) {
    return LocalUserModel.fromMap(
      (source as Map<String, dynamic>),
    );
  }

  /// Converts the [LocalUserModel] to a JSON string
  String toJson() => toMap().toString();
}
