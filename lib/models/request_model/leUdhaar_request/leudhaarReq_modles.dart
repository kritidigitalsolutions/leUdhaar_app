class RequestMoneyReqModel {
  final String requestTo;
  final int amount;
  final String reason;
  final String returnDate;
  final String repaymentMode;
  final String receiveMethod;
  final ReceiveDetails receiveDetails;

  RequestMoneyReqModel({
    required this.requestTo,
    required this.amount,
    required this.reason,
    required this.returnDate,
    required this.repaymentMode,
    required this.receiveMethod,
    required this.receiveDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      "requestTo": requestTo,
      "amount": amount,
      "reason": reason,
      "returnDate": returnDate,
      "repaymentMode": repaymentMode,
      "receiveMethod": receiveMethod,
      "receiveDetails": receiveDetails.toJson(),
    };
  }
}

class ReceiveDetails {
  final String? upiId;
  final String? accountHolderName;
  final String? accountNumber;
  final String? ifscCode;

  ReceiveDetails({
    this.upiId,
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
  });

  Map<String, dynamic> toJson() {
    return {
      if (upiId != null) "upiId": upiId,
      if (accountHolderName != null) "accountHolderName": accountHolderName,
      if (accountNumber != null) "accountNumber": accountNumber,
      if (ifscCode != null) "ifscCode": ifscCode,
    };
  }
}
