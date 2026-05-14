class RequestMoneyResModel {
  RequestMoneyResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final List<Datum> data;

  factory RequestMoneyResModel.fromJson(Map<String, dynamic> json) {
    return RequestMoneyResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }
}

class Datum {
  Datum({
    required this.receiveDetails,
    required this.id,
    required this.requestFrom,
    required this.requestTo,
    required this.amount,
    required this.reason,
    required this.returnDate,
    required this.repaymentMode,
    required this.receiveMethod,
    required this.status,
    required this.responseNote,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final ReceiveDetails? receiveDetails;
  final String? id;
  final Request? requestFrom;
  final Request? requestTo;
  final int? amount;
  final String? reason;
  final DateTime? returnDate;
  final String? repaymentMode;
  final String? receiveMethod;
  final String? status;
  final String? responseNote;
  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      receiveDetails: json["receiveDetails"] == null
          ? null
          : ReceiveDetails.fromJson(json["receiveDetails"]),
      id: json["_id"],
      requestFrom: json["requestFrom"] == null
          ? null
          : Request.fromJson(json["requestFrom"]),
      requestTo: json["requestTo"] == null
          ? null
          : Request.fromJson(json["requestTo"]),
      amount: json["amount"],
      reason: json["reason"],
      returnDate: DateTime.tryParse(json["returnDate"] ?? ""),
      repaymentMode: json["repaymentMode"],
      receiveMethod: json["receiveMethod"],
      status: json["status"],
      responseNote: json["responseNote"],
      isDeleted: json["isDeleted"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}

class ReceiveDetails {
  ReceiveDetails({
    required this.upiId,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
  });

  final String? upiId;
  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;

  factory ReceiveDetails.fromJson(Map<String, dynamic> json) {
    return ReceiveDetails(
      upiId: json["upiId"],
      accountHolderName: json["accountHolderName"],
      accountNumber: json["accountNumber"],
      ifscCode: json["ifscCode"],
    );
  }
}

class Request {
  Request({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.accountStatus,
    required this.kycStatus,
    required this.city,
  });

  final String? id;
  final String? fullName;
  final String? phone;
  final String? accountStatus;
  final String? kycStatus;
  final String? city;

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json["_id"],
      fullName: json["fullName"],
      phone: json["phone"],
      accountStatus: json["accountStatus"],
      kycStatus: json["kycStatus"],
      city: json["city"],
    );
  }
}
