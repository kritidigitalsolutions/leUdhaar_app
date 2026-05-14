class ContactCheckedResModel {
  ContactCheckedResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final Data? data;

  factory ContactCheckedResModel.fromJson(Map<String, dynamic> json) {
    return ContactCheckedResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.totalReceived,
    required this.totalValid,
    required this.totalInvalid,
    required this.totalRegistered,
    required this.totalUnregistered,
    required this.contacts,
  });

  final int? totalReceived;
  final int? totalValid;
  final int? totalInvalid;
  final int? totalRegistered;
  final int? totalUnregistered;
  final List<LeUdhaarContact> contacts;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      totalReceived: json["totalReceived"],
      totalValid: json["totalValid"],
      totalInvalid: json["totalInvalid"],
      totalRegistered: json["totalRegistered"],
      totalUnregistered: json["totalUnregistered"],
      contacts: json["contacts"] == null
          ? []
          : List<LeUdhaarContact>.from(
              json["contacts"]!.map((x) => LeUdhaarContact.fromJson(x)),
            ),
    );
  }
}

class LeUdhaarContact {
  LeUdhaarContact({
    required this.inputPhone,
    required this.normalizedPhone,
    required this.isValidPhone,
    required this.isRegistered,
    required this.contactType,
    required this.user,
    required this.actions,
  });

  final String? inputPhone;
  final String? normalizedPhone;
  final bool? isValidPhone;
  final bool? isRegistered;
  final String? contactType;
  final LeUdhaarUser? user;
  final Actions? actions;

  factory LeUdhaarContact.fromJson(Map<String, dynamic> json) {
    return LeUdhaarContact(
      inputPhone: json["inputPhone"],
      normalizedPhone: json["normalizedPhone"],
      isValidPhone: json["isValidPhone"],
      isRegistered: json["isRegistered"],
      contactType: json["contactType"],
      user: json["user"] == null ? null : LeUdhaarUser.fromJson(json["user"]),
      actions: json["actions"] == null
          ? null
          : Actions.fromJson(json["actions"]),
    );
  }
}

class Actions {
  Actions({
    required this.canSendMoneyRequest,
    required this.canSendSms,
    required this.canSendWhatsapp,
    required this.inviteLink,
  });

  final bool? canSendMoneyRequest;
  final bool? canSendSms;
  final bool? canSendWhatsapp;
  final dynamic inviteLink;

  factory Actions.fromJson(Map<String, dynamic> json) {
    return Actions(
      canSendMoneyRequest: json["canSendMoneyRequest"],
      canSendSms: json["canSendSms"],
      canSendWhatsapp: json["canSendWhatsapp"],
      inviteLink: json["inviteLink"],
    );
  }
}

class LeUdhaarUser {
  LeUdhaarUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.profileImage,
    required this.accountStatus,
    required this.kycStatus,
  });

  final String? id;
  final String? fullName;
  final String? phone;
  final String? profileImage;
  final String? accountStatus;
  final String? kycStatus;

  factory LeUdhaarUser.fromJson(Map<String, dynamic> json) {
    return LeUdhaarUser(
      id: json["_id"],
      fullName: json["fullName"],
      phone: json["phone"],
      profileImage: json["profileImage"],
      accountStatus: json["accountStatus"],
      kycStatus: json["kycStatus"],
    );
  }
}
