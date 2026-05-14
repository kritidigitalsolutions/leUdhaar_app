// ========================== Terms And condition and Privacy policy =================
//
// =========================

class PolicyResModel {
  PolicyResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final Data? data;

  factory PolicyResModel.fromJson(Map<String, dynamic> json) {
    return PolicyResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.title,
    required this.version,
    required this.effectiveDate,
    required this.content,
  });

  final String? title;
  final String? version;
  final String? effectiveDate;
  final String? content;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      title: json["title"],
      version: json["version"],
      effectiveDate: json["effectiveDate"],
      content: json["content"],
    );
  }
}

// ====================== Help & Support ==================================
//
//===============================================

class HelpSupportResModel {
  HelpSupportResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final HelpSupData? data;

  factory HelpSupportResModel.fromJson(Map<String, dynamic> json) {
    return HelpSupportResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : HelpSupData.fromJson(json["data"]),
    );
  }
}

class HelpSupData {
  HelpSupData({
    required this.title,
    required this.description,
    required this.supportEmail,
    required this.supportPhone,
    required this.availability,
    required this.faqs,
  });

  final String? title;
  final String? description;
  final String? supportEmail;
  final String? supportPhone;
  final String? availability;
  final List<Faq> faqs;

  factory HelpSupData.fromJson(Map<String, dynamic> json) {
    return HelpSupData(
      title: json["title"],
      description: json["description"],
      supportEmail: json["supportEmail"],
      supportPhone: json["supportPhone"],
      availability: json["availability"],
      faqs: json["faqs"] == null
          ? []
          : List<Faq>.from(json["faqs"]!.map((x) => Faq.fromJson(x))),
    );
  }
}

class Faq {
  Faq({required this.question, required this.answer});

  final String? question;
  final String? answer;

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(question: json["question"], answer: json["answer"]);
  }
}

// ================= About us res ===================================
//
// =================================================

class AboutUsResModel {
  AboutUsResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final AboutUsData? data;

  factory AboutUsResModel.fromJson(Map<String, dynamic> json) {
    return AboutUsResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : AboutUsData.fromJson(json["data"]),
    );
  }
}

class AboutUsData {
  AboutUsData({
    required this.appName,
    required this.version,
    required this.tagline,
    required this.description,
    required this.companyName,
    required this.contactEmail,
  });

  final String? appName;
  final String? version;
  final String? tagline;
  final String? description;
  final String? companyName;
  final String? contactEmail;

  factory AboutUsData.fromJson(Map<String, dynamic> json) {
    return AboutUsData(
      appName: json["appName"],
      version: json["version"],
      tagline: json["tagline"],
      description: json["description"],
      companyName: json["companyName"],
      contactEmail: json["contactEmail"],
    );
  }
}
