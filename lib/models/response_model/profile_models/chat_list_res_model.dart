class ChatListResModel {
  ChatListResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final List<ChatListData> data;

  factory ChatListResModel.fromJson(Map<String, dynamic> json) {
    return ChatListResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null
          ? []
          : List<ChatListData>.from(
              json["data"]!.map((x) => ChatListData.fromJson(x)),
            ),
    );
  }
}

class ChatListData {
  ChatListData({
    required this.id,
    required this.otherParticipant,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageText,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final Participant? otherParticipant;
  final List<Participant> participants;
  final LastMessage? lastMessage;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final int? unreadCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ChatListData.fromJson(Map<String, dynamic> json) {
    return ChatListData(
      id: json["_id"],
      otherParticipant: json["otherParticipant"] == null
          ? null
          : Participant.fromJson(json["otherParticipant"]),
      participants: json["participants"] == null
          ? []
          : List<Participant>.from(
              json["participants"]!.map((x) => Participant.fromJson(x)),
            ),
      lastMessage: json["lastMessage"] == null
          ? null
          : LastMessage.fromJson(json["lastMessage"]),
      lastMessageText: json["lastMessageText"],
      lastMessageAt: DateTime.tryParse(json["lastMessageAt"] ?? ""),
      unreadCount: json["unreadCount"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }
}

class LastMessage {
  LastMessage({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.messageType,
    required this.text,
    required this.isRead,
    required this.createdAt,
    required this.readAt,
  });

  final String? id;
  final String? sender;
  final String? receiver;
  final String? messageType;
  final String? text;
  final bool? isRead;
  final DateTime? createdAt;
  final DateTime? readAt;

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json["_id"],
      sender: json["sender"],
      receiver: json["receiver"],
      messageType: json["messageType"],
      text: json["text"],
      isRead: json["isRead"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      readAt: DateTime.tryParse(json["readAt"] ?? ""),
    );
  }
}

class Participant {
  Participant({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.profileImage,
  });

  final String? id;
  final String? fullName;
  final String? phone;
  final String? profileImage;

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json["_id"],
      fullName: json["fullName"],
      phone: json["phone"],
      profileImage: json["profileImage"],
    );
  }
}
