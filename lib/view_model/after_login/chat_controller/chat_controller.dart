import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';

class ChatSearchController extends GetxController {
  var allContacts = <Contact>[].obs;
  var filteredContacts = <Contact>[].obs;
  var recentSearches = <String>["Amit Bhai", "Mukesh"].obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchContacts();
    searchController.addListener(_filterContacts);
  }

  Future<void> fetchContacts() async {
    try {
      final status = await FlutterContacts.permissions.request(
        PermissionType.readWrite,
      );

      if (status == PermissionStatus.granted ||
          status == PermissionStatus.limited) {
        final contacts = await FlutterContacts.getAll(
          properties: {ContactProperty.photoThumbnail},
        );

        allContacts.value = contacts;
        filteredContacts.value = contacts;
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _filterContacts() {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      filteredContacts.value = allContacts;
    } else {
      filteredContacts.value = allContacts.where((contact) {
        return (contact.displayName ?? '').toLowerCase().contains(query);
      }).toList();
    }
  }

  void addToRecentSearch(String name) {
    if (name.isEmpty) return;

    if (!recentSearches.contains(name)) {
      recentSearches.insert(0, name);

      if (recentSearches.length > 5) {
        recentSearches.removeLast();
      }
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

//====================================================
// chat page
// ==========================================================

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    messages.addAll([
      ChatMessage(
        text: "Bhai kab dega paisa?",
        isMe: true,
        time: DateTime.now(),
        type: MessageType.text,
      ),
      ChatMessage(
        text: "15 ko auto debit ho jayega bhai",
        isMe: false,
        time: DateTime.now(),
        type: MessageType.text,
      ),
    ]);
  }

  void sendText() {
    if (messageController.text.trim().isEmpty) return;

    messages.add(
      ChatMessage(
        text: messageController.text.trim(),
        isMe: true,
        time: DateTime.now(),
        type: MessageType.text,
      ),
    );

    messageController.clear();
  }

  Future<void> sendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      messages.add(
        ChatMessage(
          imagePath: image.path,
          isMe: true,
          time: DateTime.now(),
          type: MessageType.image,
        ),
      );
    }
  }

  Future<void> sendFile() async {
    FilePickerResult? result = await FilePicker.pickFiles();

    if (result != null) {
      messages.add(
        ChatMessage(
          fileName: result.files.single.name,
          isMe: true,
          time: DateTime.now(),
          type: MessageType.file,
        ),
      );
    }
  }

  void sendUdhaarRequest({
    required double amount,
    required String dueDate,
    required String protection,
  }) {
    messages.add(
      ChatMessage(
        isMe: true,
        time: DateTime.now(),
        type: MessageType.udhaar,
        udhaarAmount: amount,
        udhaarDueDate: dueDate,
        udhaarProtection: protection,
      ),
    );

    // Add waiting pill below
    messages.add(
      ChatMessage(
        isMe: false,
        time: DateTime.now(),
        type: MessageType.status,
        text: "Waiting for Amit Kumar to accept the terms...",
      ),
    );
  }
}

// Add to ChatMessage model:
class ChatMessage {
  final String? text;
  final String? fileName;
  final String? imagePath;
  final bool isMe;
  final DateTime time;
  final MessageType type;

  // Udhaar-specific fields
  final double? udhaarAmount;
  final String? udhaarDueDate;
  final String? udhaarProtection;

  ChatMessage({
    this.text,
    this.fileName,
    this.imagePath,
    required this.isMe,
    required this.time,
    required this.type,
    this.udhaarAmount,
    this.udhaarDueDate,
    this.udhaarProtection,
  });
}

// Add to enum:
enum MessageType { text, image, file, udhaar, status }

// Add to ChatController:
