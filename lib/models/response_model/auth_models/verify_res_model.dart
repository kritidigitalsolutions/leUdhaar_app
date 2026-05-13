class VerifyResModel {
  VerifyResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final Data? data;

  factory VerifyResModel.fromJson(Map<String, dynamic> json) {
    return VerifyResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  Data({required this.token, required this.user});

  final String? token;
  final User? user;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      token: json["token"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {"token": token, "user": user?.toJson()};
}

class User {
  User({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.profileImage,
    required this.walletBalance,
    required this.totalLent,
    required this.totalBorrowed,
    required this.totalRecovered,
    required this.pendingAmount,
    required this.overdueAmount,
    required this.accountStatus,
    required this.kycStatus,
    required this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String? fullName;
  final String? phone;
  final String? profileImage;
  final int? walletBalance;
  final int? totalLent;
  final int? totalBorrowed;
  final int? totalRecovered;
  final int? pendingAmount;
  final int? overdueAmount;
  final String? accountStatus;
  final String? kycStatus;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"],
      fullName: json["fullName"],
      phone: json["phone"],
      profileImage: json["profileImage"],
      walletBalance: json["walletBalance"],
      totalLent: json["totalLent"],
      totalBorrowed: json["totalBorrowed"],
      totalRecovered: json["totalRecovered"],
      pendingAmount: json["pendingAmount"],
      overdueAmount: json["overdueAmount"],
      accountStatus: json["accountStatus"],
      kycStatus: json["kycStatus"],
      lastLoginAt: DateTime.tryParse(json["lastLoginAt"] ?? ""),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "phone": phone,
    "profileImage": profileImage,
    "walletBalance": walletBalance,
    "totalLent": totalLent,
    "totalBorrowed": totalBorrowed,
    "totalRecovered": totalRecovered,
    "pendingAmount": pendingAmount,
    "overdueAmount": overdueAmount,
    "accountStatus": accountStatus,
    "kycStatus": kycStatus,
    "lastLoginAt": lastLoginAt?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
