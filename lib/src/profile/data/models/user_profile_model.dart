import 'dart:convert';

import 'package:numberwale/core/utils/typedef.dart';
import 'package:numberwale/src/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    super.id,
    required super.name,
    required super.email,
    required super.mobile,
    super.accountType,
    super.isVerified,
    super.status,
    super.getWhatsappUpdate,
    super.acceptTermsAndConditions,
    super.companyName,
    super.gstinNo,
    super.profilePic,
    super.createdAt,
    super.updatedAt,
  });

  factory UserProfileModel.fromMap(DataMap map) {
    return UserProfileModel(
      id: map['_id'] as String? ?? map['id'] as String?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      mobile: map['mobile'] as String? ?? '',
      accountType: map['accountType'] as String? ?? 'Individual',
      isVerified: map['isVerified'] as bool? ?? false,
      status: map['status'] as String? ?? 'active',
      getWhatsappUpdate: map['getWhatsappUpdate'] as bool? ?? false,
      acceptTermsAndConditions: map['acceptTermsAndConditions'] as bool? ?? true,
      companyName: map['companyName'] as String?,
      gstinNo: map['gstinNo'] as String?,
      profilePic: map['profilePic'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }

  DataMap toMap() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'accountType': accountType,
      'isVerified': isVerified,
      'status': status,
      'getWhatsappUpdate': getWhatsappUpdate,
      'acceptTermsAndConditions': acceptTermsAndConditions,
      if (companyName != null) 'companyName': companyName,
      if (gstinNo != null) 'gstinNo': gstinNo,
      if (profilePic != null) 'profilePic': profilePic,
    };
  }

  factory UserProfileModel.fromJson(String source) =>
      UserProfileModel.fromMap(jsonDecode(source) as DataMap);

  String toJson() => jsonEncode(toMap());
}
