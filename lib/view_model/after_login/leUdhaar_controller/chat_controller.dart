import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/contact_checked_res_model.dart';
import 'package:leudaar_app/repo/leUdhaar_repo.dart';

class ChatSearchController extends GetxController {
  final LeudhaarRepo _repo = LeudhaarRepo();

  var allContacts = <Contact>[].obs;

  var registeredContacts = <LeUdhaarContact>[].obs;
  var unregisteredContacts = <LeUdhaarContact>[].obs;

  var filteredRegistered = <LeUdhaarContact>[].obs;
  var filteredUnregistered = <LeUdhaarContact>[].obs;

  var recentSearches = <String>[].obs;

  var isLoading = true.obs;
  var isChecking = false.obs;

  final TextEditingController searchController = TextEditingController();

  final Map<String, Contact> _phoneToContact = {};

  @override
  void onInit() {
    super.onInit();
    fetchContacts();
    searchController.addListener(_filterContacts);
  }

  // ─────────────────────────────────────────────
  // FETCH CONTACTS (YOUR REQUESTED API STYLE)
  // ─────────────────────────────────────────────
  Future<void> fetchContacts() async {
    try {
      isLoading.value = true;

      // ✅ 1. Permission (YOUR STYLE)
      final status = await FlutterContacts.permissions.request(
        PermissionType.readWrite,
      );

      if (status != PermissionStatus.granted) {
        debugPrint('Permission denied');
        isLoading.value = false;
        return;
      }

      // ✅ 2. Get all contacts (fast)
      final contacts = await FlutterContacts.getAll();

      allContacts.value = contacts;

      // ─────────────────────────────────────
      // Extract + normalize phone numbers
      // ─────────────────────────────────────
      final Set<String> uniquePhones = {};

      for (final c in contacts) {
        // safer: fetch full contact only when needed
        Contact fullContact = c;

        if (c.id != null) {
          fullContact =
              await FlutterContacts.get(
                c.id!,
                properties: ContactProperties.all,
              ) ??
              c;
        }

        for (final p in fullContact.phones) {
          final normalized = _normalizePhone(p.number);

          if (normalized.isNotEmpty) {
            uniquePhones.add(normalized);
            _phoneToContact[normalized] = fullContact;
          }
        }
      }

      final phoneList = uniquePhones.toList();

      if (phoneList.isEmpty) {
        isLoading.value = false;
        return;
      }

      // ─────────────────────────────────────
      // Backend check (batch API)
      // ─────────────────────────────────────
      isChecking.value = true;

      final List<LeUdhaarContact> registered = [];
      final List<LeUdhaarContact> unregistered = [];

      const batchSize = 100;

      for (int i = 0; i < phoneList.length; i += batchSize) {
        final end = (i + batchSize > phoneList.length)
            ? phoneList.length
            : i + batchSize;

        final batch = phoneList.sublist(i, end);

        final response = await _repo.checkContact(batch);

        final contacts = response.data?.data?.contacts ?? [];

        for (final c in contacts) {
          if (c.isRegistered == true) {
            registered.add(c);
          } else {
            unregistered.add(c);
          }
        }
      }

      registeredContacts.value = registered;
      unregisteredContacts.value = unregistered;

      filteredRegistered.value = registered;
      filteredUnregistered.value = unregistered;
    } catch (e, stack) {
      debugPrint('fetchContacts error: $e');
      debugPrint('$stack');
    } finally {
      isLoading.value = false;
      isChecking.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // NORMALIZE PHONE
  // ─────────────────────────────────────────────
  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // ─────────────────────────────────────────────
  // LOCAL CONTACT MATCH
  // ─────────────────────────────────────────────
  Contact? getLocalContact(LeUdhaarContact lc) {
    final phone = lc.normalizedPhone ?? lc.inputPhone ?? '';
    return _phoneToContact[_normalizePhone(phone)];
  }

  // ─────────────────────────────────────────────
  // SEARCH FILTER
  // ─────────────────────────────────────────────
  void _filterContacts() {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      filteredRegistered.value = registeredContacts;
      filteredUnregistered.value = unregisteredContacts;
      return;
    }

    filteredRegistered.value = registeredContacts.where((c) {
      final name = (c.user?.fullName ?? c.inputPhone ?? '').toLowerCase();
      final phone = (c.normalizedPhone ?? '').toLowerCase();

      return name.contains(query) || phone.contains(query);
    }).toList();

    filteredUnregistered.value = unregisteredContacts.where((c) {
      final local = getLocalContact(c);

      final name = (local?.displayName ?? c.inputPhone ?? '').toLowerCase();
      final phone = (c.normalizedPhone ?? '').toLowerCase();

      return name.contains(query) || phone.contains(query);
    }).toList();
  }

  // ─────────────────────────────────────────────
  // RECENT SEARCH
  // ─────────────────────────────────────────────
  void addToRecentSearch(String name) {
    if (name.isEmpty) return;

    if (!recentSearches.contains(name)) {
      recentSearches.insert(0, name);

      if (recentSearches.length > 5) {
        recentSearches.removeLast();
      }
    }
  }

  // ─────────────────────────────────────────────
  // CLEANUP
  // ─────────────────────────────────────────────
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
