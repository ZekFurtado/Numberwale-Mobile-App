import 'package:equatable/equatable.dart';

/// Extended user profile entity with all profile fields
class UserProfile extends Equatable {
  final String? id;
  final String name;
  final String email;
  final String mobile;
  final String accountType; // 'Individual' or 'Corporate'
  final bool isVerified;
  final String status;
  final bool getWhatsappUpdate;
  final bool acceptTermsAndConditions;
  final String? companyName;
  final String? gstinNo;
  final String? profilePic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    this.accountType = 'Individual',
    this.isVerified = false,
    this.status = 'active',
    this.getWhatsappUpdate = false,
    this.acceptTermsAndConditions = true,
    this.companyName,
    this.gstinNo,
    this.profilePic,
    this.createdAt,
    this.updatedAt,
  });

  const UserProfile.empty()
      : this(
          id: 'empty.id',
          name: 'empty.name',
          email: 'empty@example.com',
          mobile: '0000000000',
        );

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? accountType,
    bool? isVerified,
    String? status,
    bool? getWhatsappUpdate,
    bool? acceptTermsAndConditions,
    String? companyName,
    String? gstinNo,
    String? profilePic,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      accountType: accountType ?? this.accountType,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      getWhatsappUpdate: getWhatsappUpdate ?? this.getWhatsappUpdate,
      acceptTermsAndConditions: acceptTermsAndConditions ?? this.acceptTermsAndConditions,
      companyName: companyName ?? this.companyName,
      gstinNo: gstinNo ?? this.gstinNo,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  @override
  List<Object?> get props => [id, email, mobile];
}
