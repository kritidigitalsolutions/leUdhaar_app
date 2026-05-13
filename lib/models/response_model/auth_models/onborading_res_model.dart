class OnboradingResModel {
  OnboradingResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final List<OnboradingData> data;

  factory OnboradingResModel.fromJson(Map<String, dynamic> json) {
    return OnboradingResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null
          ? []
          : List<OnboradingData>.from(
              json["data"]!.map((x) => OnboradingData.fromJson(x)),
            ),
    );
  }
}

class OnboradingData {
  OnboradingData({
    required this.title,
    required this.label,
    required this.description,
    required this.badgeText,
    required this.iconKey,
    required this.order,
  });

  final String? title;
  final String? label;
  final String? description;
  final String? badgeText;
  final String? iconKey;
  final int? order;

  factory OnboradingData.fromJson(Map<String, dynamic> json) {
    return OnboradingData(
      title: json["title"],
      label: json["label"],
      description: json["description"],
      badgeText: json["badgeText"],
      iconKey: json["iconKey"],
      order: json["order"],
    );
  }
}
