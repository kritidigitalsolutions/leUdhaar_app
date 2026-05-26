import 'package:share_plus/share_plus.dart';

String getInitials(String? name) {
  if (name == null || name.trim().isEmpty) return "U";

  List<String> parts = name.trim().split(" ");

  if (parts.length == 1) {
    return parts[0][0].toUpperCase();
  }

  return (parts[0][0] + parts[1][0]).toUpperCase();
}

void shareViaWhatsApp(String name, dynamic inviteLink) {
  final link =
      inviteLink?.toString() ?? 'https://leudaar.app/refer?user=your_user_id';
  final message =
      "Hey $name 👋\n\nJoin me on Le'Udhaar — stress-free lending & borrowing!\n\n$link";
  SharePlus.instance.share(
    ShareParams(text: message, subject: "Join me on Le'Udhaar"),
  );
}

void shareInvite(String name, dynamic inviteLink) {
  final link =
      inviteLink?.toString() ?? 'https://leudaar.app/refer?user=your_user_id';
  final message =
      "Hey $name 👋\n\nI've invited you to join Le'Udhaar — a stress-free & automated platform for lending, borrowing, and repayments.\n\nJoin now:\n$link";
  SharePlus.instance.share(
    ShareParams(text: message, subject: "Join me on Le'Udhaar"),
  );
}
