class ChatHistoryResModel {
  ChatHistoryResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final Data? data;

  factory ChatHistoryResModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.otherUser,
    required this.messages,
    required this.pagination,
  });

  final OtherUser? otherUser;
  final List<Message> messages;
  final Pagination? pagination;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      otherUser: json["otherUser"] == null
          ? null
          : OtherUser.fromJson(json["otherUser"]),
      messages: json["messages"] == null
          ? []
          : List<Message>.from(
              json["messages"]!.map((x) => Message.fromJson(x)),
            ),
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
    );
  }
}

class Message {
  Message({
    this.id,
    this.sender,
    this.receiver,
    this.messageType,
    this.text,
    this.attachment, // ← NEW
    this.status,
    this.isRead,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? sender;
  final String? receiver;
  final String? messageType;
  final String? text;
  final String? status;
  final Map<String, dynamic>? attachment; // ← NEW (Important)
  final bool? isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json["_id"],
      sender: json["sender"],
      receiver: json["receiver"],
      messageType: json["messageType"],
      text: json["text"],
      status: json['status'],
      attachment: json["attachment"] is Map<String, dynamic>
          ? json["attachment"] as Map<String, dynamic>
          : null,
      isRead: json["isRead"],
      readAt: DateTime.tryParse(json["readAt"] ?? ""),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }
}

class OtherUser {
  OtherUser({
    this.id,
    this.fullName,
    this.phone,
    this.profileImage,
    this.accountStatus,
  });

  final String? id;
  final String? fullName;
  final String? phone;
  final dynamic profileImage;
  final String? accountStatus;

  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json["_id"],
      fullName: json["fullName"],
      phone: json["phone"],
      profileImage: json["profileImage"],
      accountStatus: json["accountStatus"],
    );
  }
}

class Pagination {
  Pagination({this.page, this.limit, this.totalMessages, this.hasMore});

  final int? page;
  final int? limit;
  final int? totalMessages;
  final bool? hasMore;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json["page"],
      limit: json["limit"],
      totalMessages: json["totalMessages"],
      hasMore: json["hasMore"],
    );
  }
}
