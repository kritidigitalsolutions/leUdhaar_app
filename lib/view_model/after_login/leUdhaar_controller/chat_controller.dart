import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leudaar_app/data/api_response.dart';
import 'package:leudaar_app/models/response_model/auth_models/verify_res_model.dart';
import 'package:leudaar_app/models/response_model/leudhaar_res/contact_checked_res_model.dart';
import 'package:leudaar_app/models/response_model/profile_models/chat_history_res_model.dart';
import 'package:leudaar_app/models/response_model/profile_models/chat_list_res_model.dart';
import 'package:leudaar_app/repo/leUdhaar_repo.dart';
import 'package:leudaar_app/repo/profile_repo.dart';
import 'package:leudaar_app/utils/service/local_storage/auth_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatListController extends GetxController {
  final _repo = ProfileRepo();

  final chatListRes = ApiResponse<ChatListResModel>.loading().obs;

  Future<void> getChatList() async {
    // ← Renamed
    chatListRes.value = ApiResponse.loading();
    chatListRes.value = await _repo.getChatList();
  }
}

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

// ── Models ────────────────────────────────────────────────────────────────────

enum MessageType { text, image, file, udhaar, status }

enum PaymentMethod { upi, bank }

class ChatMessage {
  final String? id; // server _id (null for optimistic)
  final String? text;
  final String? fileName;
  final String? imagePath;
  final bool isMe;
  final DateTime time;
  final MessageType type;
  final bool isPending; // optimistic, not yet ack'd

  // Udhaar-specific
  final double? udhaarAmount;
  final String? udhaarDueDate;
  final String? udhaarProtection;
  final PaymentMethod? paymentMethod;
  final String? upiId;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolder;

  ChatMessage({
    this.id,
    this.text,
    this.fileName,
    this.imagePath,
    required this.isMe,
    required this.time,
    required this.type,
    this.isPending = false,
    this.udhaarAmount,
    this.udhaarDueDate,
    this.udhaarProtection,
    this.paymentMethod,
    this.upiId,
    this.accountNumber,
    this.ifscCode,
    this.accountHolder,
  });

  /// Build from a socket "message:new" payload
  // In your ChatMessage model
  factory ChatMessage.fromSocket(Map<String, dynamic> json, String myUserId) {
    final senderId = json['sender']?.toString() ?? '';
    final receiverId =
        json['receiverId']?.toString() ?? json['receiver']?.toString() ?? '';

    return ChatMessage(
      id: json['_id']?.toString(),
      text: json['text']?.toString() ?? '',
      imagePath: json['imageUrl']?.toString(), // if you support images later
      isMe: senderId == myUserId,
      time: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      type: MessageType.text, // change logic if you support other types
      isPending: false,
    );
  }

  ChatMessage copyWith({bool? isPending, String? id}) => ChatMessage(
    id: id ?? this.id,
    text: text,
    fileName: fileName,
    imagePath: imagePath,
    isMe: isMe,
    time: time,
    type: type,
    isPending: isPending ?? this.isPending,
    udhaarAmount: udhaarAmount,
    udhaarDueDate: udhaarDueDate,
    udhaarProtection: udhaarProtection,
    paymentMethod: paymentMethod,
    upiId: upiId,
    accountNumber: accountNumber,
    ifscCode: ifscCode,
    accountHolder: accountHolder,
  );
}

// ── Controller ────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// chat_controller.dart
// Place in: lib/view_model/after_login/leUdhaar_controller/chat_controller.dart
// ─────────────────────────────────────────────────────────────────────────────

class ChatController extends GetxController {
  // ── Reactive State ─────────────────────────────────────────────────────
  final messages = <ChatMessage>[].obs;
  final messageController = TextEditingController();
  final isConnected = false.obs;
  final isOtherTyping = false.obs;
  final isSending = false.obs;
  final connectionStatus = 'Connecting…'.obs;

  // ── User Data ───────────────────────────────────────────────────────────
  late final String _jwtToken;
  late final String _myUserId;
  late final String otherUserId; // This is receiverId
  late final String _otherName;
  late final String _otherInitials;

  String get otherName => _otherName;
  String get otherInitials => _otherInitials;

  // ── Add these new reactive fields ──────────────────────────────────────
  final isLoadingHistory = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int _currentPage = 1;
  static const int _pageLimit = 50;

  // ── Replace _seedDemoMessages() call in onInit() with: ─────────────────
  @override
  void onInit() {
    super.onInit();
    _resolveIdentities();
    _loadChatHistory(); // ← replaces _seedDemoMessages()
    _initSocket();
  }

  // ── Add this method ────────────────────────────────────────────────────
  Future<void> _loadChatHistory({bool refresh = false}) async {
    if (otherUserId.isEmpty) return;
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
    }
    if (!hasMore.value) return;

    refresh ? isLoadingHistory.value = true : isLoadingMore.value = true;

    try {
      final token = AuthStorage.getToken();
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final url =
          '$_serverUrl/api/user/chats/with/$otherUserId/messages'
          '?page=$_currentPage&limit=$_pageLimit';

      _debug('Fetching chat history: $url');
      final response = await dio.get(url);

      final model = ChatHistoryResModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success == true && model.data != null) {
        final fetched = model.data!.messages
            .map(
              (m) => ChatMessage(
                id: m.id,
                text: m.text,
                isMe: m.sender == _myUserId,
                time: m.createdAt ?? DateTime.now(),
                type: _mapMessageType(m.messageType),
                isPending: false,
              ),
            )
            .toList();

        // History comes newest-first from the API; reverse so oldest is at top
        final ordered = fetched.reversed.toList();

        if (refresh) {
          // Replace everything except optimistic (pending) messages
          final pending = messages.where((m) => m.isPending).toList();
          messages
            ..clear()
            ..addAll(ordered)
            ..addAll(pending);
        } else {
          // Prepend older page at the top (load-more scenario)
          messages.insertAll(0, ordered);
        }

        hasMore.value = model.data!.pagination?.hasMore ?? false;
        _currentPage++;
        _debug(
          'History loaded: ${fetched.length} msgs, page=$_currentPage, hasMore=${hasMore.value}',
        );
      }
    } on DioException catch (e) {
      _debug('History fetch error: ${e.message}');
      Get.snackbar('Error', 'Could not load chat history');
    } catch (e) {
      _debug('History unexpected error: $e');
    } finally {
      isLoadingHistory.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Pull-to-refresh (called from UI)
  Future<void> refreshHistory() => _loadChatHistory(refresh: true);

  /// Load older messages when user scrolls to the top
  Future<void> loadMoreHistory() async {
    if (isLoadingMore.value || !hasMore.value) return;
    await _loadChatHistory(refresh: false);
  }

  MessageType _mapMessageType(String? raw) {
    switch (raw) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }

  // delete chat and msg
  //
  // ====================================================

  final _repo = ProfileRepo();

  final clearAllChatRes = Rx<ApiResponse<Map<String, dynamic>>?>(null);
  Future<void> clearAllChat(String otherUserId) async {
    clearAllChatRes.value = ApiResponse.loading();
    clearAllChatRes.value = await _repo.clearAllChats(otherUserId);
  }

  final msgRes = Rx<ApiResponse<Map<String, dynamic>>?>(null);
  Future<void> msgDelete(String msgId) async {
    msgRes.value = ApiResponse.loading();
    msgRes.value = await _repo.deleteChatMsg(msgId);
  }

  // ── Socket ─────────────────────────────────────────────────────────────
  IO.Socket? _socket;
  bool _hasJoined = false;

  static const String _serverUrl =
      'http://192.168.1.17:5005'; // Change as needed

  @override
  void onClose() {
    _debug('onClose called');
    _leaveChat();
    _socket?.dispose();
    messageController.dispose();
    super.onClose();
  }

  // ── Resolve User IDs ───────────────────────────────────────────────────
  void _resolveIdentities() {
    final String? token = AuthStorage.getToken();
    final User? me = AuthStorage.getUser();

    _jwtToken = token ?? '';
    _myUserId = me?.id ?? '';
    _debug(
      'Resolved auth: token=${_jwtToken.isNotEmpty ? 'present(${_jwtToken.length})' : 'missing'}, myUserId=$_myUserId',
    );

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _otherName = args["name"] ?? 'Unknown User';
      _otherInitials = _buildInitials(_otherName);
      otherUserId = args["id"] ?? '';
      _debug(
        'Resolved chat user: otherUserId=$otherUserId, otherName=$_otherName',
      );

      if (otherUserId.isEmpty) {
        debugPrint('⚠️ Warning: otherUserId (receiverId) is empty');
      }
    } else {
      _otherName = 'Unknown';

      otherUserId = '';
      _debug('Warning: Get.arguments is not LeUdhaarContact');
    }
  }

  // ── Initialize Socket ──────────────────────────────────────────────────
  void _initSocket() {
    if (_jwtToken.isEmpty || otherUserId.isEmpty) {
      connectionStatus.value = 'Auth data missing';
      _debug(
        'Socket init skipped: jwtTokenEmpty=${_jwtToken.isEmpty}, otherUserIdEmpty=${otherUserId.isEmpty}',
      );
      return;
    }

    _debug('Socket init: server=$_serverUrl, receiverId=$otherUserId');
    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': _jwtToken})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    // Connection Events
    _socket?.onConnect((_) {
      isConnected.value = true;
      connectionStatus.value = 'Connected';
      _debug('Socket connected: id=${_socket?.id}');
      _joinChat();
    });

    _socket?.onDisconnect((reason) {
      isConnected.value = false;
      _hasJoined = false;
      connectionStatus.value = 'Disconnected';
      _debug('Socket disconnected: reason=$reason');
    });

    _socket?.onReconnect((attempt) {
      connectionStatus.value = 'Reconnected';
      _debug('Socket reconnected: attempt=$attempt, id=${_socket?.id}');
      _joinChat();
    });

    _socket?.onReconnectAttempt((attempt) {
      _debug('Socket reconnect attempt: $attempt');
    });

    _socket?.onReconnectError((error) {
      _debug('Socket reconnect error: $error');
    });

    _socket?.onReconnectFailed((_) {
      connectionStatus.value = 'Reconnect failed';
      _debug('Socket reconnect failed');
    });

    _socket?.onConnectError((error) {
      isConnected.value = false;
      connectionStatus.value = 'Connect error';
      _debug('Socket connect error: $error');
    });

    _socket?.onError((error) {
      _debug('Socket error: $error');
    });

    // New Message
    _socket?.on('message:new', (raw) {
      _debug('Socket received message:new raw=$raw');

      if (raw == null) {
        _debug('message:new ignored: payload is null');
        return;
      }

      Map<String, dynamic> data;

      if (raw is Map) {
        data = Map<String, dynamic>.from(raw);
      } else if (raw is String) {
        try {
          data = jsonDecode(raw) as Map<String, dynamic>;
        } catch (e) {
          _debug('Failed to decode string payload: $e');
          return;
        }
      } else {
        _debug('message:new ignored: unsupported type ${raw.runtimeType}');
        return;
      }

      try {
        final msg = ChatMessage.fromSocket(data, _myUserId);

        if (!messages.any(
          (m) => m.id == msg.id && msg.id != null && msg.id!.isNotEmpty,
        )) {
          messages.add(msg);
          _debug('message:new added: id=${msg.id}, isMe=${msg.isMe}');
        } else {
          _debug('message:new ignored duplicate');
        }

        _markRead();
      } catch (e, stack) {
        _debug('Error parsing message:new: $e\n$stack');
        Get.snackbar('Parse Error', 'Failed to parse incoming message');
      }
    });

    // Typing
    _socket?.on('typing:start', (raw) {
      _debug('Socket received typing:start raw=$raw');
      if (raw is Map && raw['userId']?.toString() != _myUserId) {
        isOtherTyping.value = true;
        _debug('Typing started by userId=${raw['userId']}');
      }
    });

    _socket?.on('typing:stop', (raw) {
      _debug('Socket received typing:stop raw=$raw');
      if (raw is Map && raw['userId']?.toString() != _myUserId) {
        isOtherTyping.value = false;
        _debug('Typing stopped by userId=${raw['userId']}');
      }
    });

    // Error Handling
    _socket?.on('chat:error', (raw) {
      _debug('Socket received chat:error raw=$raw');
      final msg = raw is Map
          ? (raw['message']?.toString() ?? 'Error')
          : 'Socket error';
      Get.snackbar('Chat Error', msg, snackPosition: SnackPosition.TOP);
    });

    _debug('Socket connect requested');
    _socket?.connect();
  }

  // ── Chat Room Management ───────────────────────────────────────────────
  void _joinChat() {
    final socket = _socket;
    if (_hasJoined || otherUserId.isEmpty || socket == null) {
      _debug(
        'chat:join skipped: hasJoined=$_hasJoined, otherUserIdEmpty=${otherUserId.isEmpty}, socketReady=${socket != null}',
      );
      return;
    }

    _debug('Emit chat:join receiverId=$otherUserId');
    socket.emitWithAck(
      'chat:join',
      {'receiverId': otherUserId}, // ← Changed to receiverId
      ack: (res) {
        _debug('Ack chat:join res=$res');
        if (res is Map && res['success'] == true) {
          _hasJoined = true;
          _debug('chat:join success');
          _markRead();
        } else {
          _debug('chat:join failed or unexpected ack');
        }
      },
    );
  }

  void _leaveChat() {
    if (_hasJoined && otherUserId.isNotEmpty) {
      _debug('Emit chat:leave receiverId=$otherUserId');
      _socket?.emit('chat:leave', {'receiverId': otherUserId}); // ← receiverId
    }
  }

  void _markRead() {
    if (otherUserId.isNotEmpty) {
      _debug('Emit message:read receiverId=$otherUserId');
      _socket?.emit('message:read', {
        'receiverId': otherUserId,
      }); // ← receiverId
    }
  }

  // ── Typing Indicator ───────────────────────────────────────────────────
  void onTypingChanged(String value) {
    if (otherUserId.isEmpty) return;
    final event = value.isNotEmpty ? 'typing:start' : 'typing:stop';
    _debug('Emit $event receiverId=$otherUserId');
    _socket?.emit(event, {'receiverId': otherUserId});
  }

  // ── Send Text Message ──────────────────────────────────────────────────
  void sendText() {
    final text = messageController.text.trim();
    final socket = _socket;
    if (text.isEmpty || otherUserId.isEmpty || socket == null) {
      _debug(
        'message:send skipped: textEmpty=${text.isEmpty}, otherUserIdEmpty=${otherUserId.isEmpty}, socketReady=${socket != null}',
      );
      return;
    }

    final optimistic = ChatMessage(
      text: text,
      isMe: true,
      time: DateTime.now(),
      type: MessageType.text,
      isPending: true,
    );

    messages.add(optimistic);
    _debug(
      'Optimistic message added: textLength=${text.length}, total=${messages.length}, connected=${isConnected.value}',
    );
    messageController.clear();
    onTypingChanged(''); // stop typing

    _debug(
      'Emit message:send receiverId=$otherUserId, textLength=${text.length}',
    );
    socket.emitWithAck(
      'message:send',
      {
        'receiverId': otherUserId, // ← Changed to receiverId
        'text': text,
      },
      ack: (res) {
        _debug('Ack message:send res=$res');
        if (res is Map && res['success'] == true) {
          final serverData = res['data'] as Map<String, dynamic>?;
          if (serverData != null) {
            final index = messages.indexOf(optimistic);
            if (index != -1) {
              messages[index] = optimistic.copyWith(
                id: serverData['_id']?.toString(),
                isPending: false,
              );
              _debug(
                'message:send success: serverId=${serverData['_id']}, index=$index',
              );
            } else {
              _debug(
                'message:send ack received but optimistic message not found',
              );
            }
          } else {
            _debug('message:send success but data is null');
          }
        } else {
          messages.remove(optimistic);
          _debug('message:send failed: optimistic message removed');
          Get.snackbar('Failed', 'Could not send message');
        }
      },
    );
  }
  // ── Send image ───────────────────────────────────────────────────────────────

  Future<void> sendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    messages.add(
      ChatMessage(
        imagePath: image.path,
        isMe: true,
        time: DateTime.now(),
        type: MessageType.image,
        isPending: true,
      ),
    );
    // TODO: upload to server & send URL via socket/REST
  }

  // ── Send file ────────────────────────────────────────────────────────────────

  Future<void> sendFile() async {
    final result = await FilePicker.pickFiles();
    if (result == null) return;

    messages.add(
      ChatMessage(
        fileName: result.files.single.name,
        isMe: true,
        time: DateTime.now(),
        type: MessageType.file,
        isPending: true,
      ),
    );
    // TODO: upload to server
  }

  // ── Send Udhaar request ──────────────────────────────────────────────────────

  void sendUdhaarRequest({
    required double amount,
    required String dueDate,
    required String protection,
    required PaymentMethod paymentMethod,
    String? upiId,
    String? accountNumber,
    String? ifscCode,
    String? accountHolder,
  }) {
    messages.add(
      ChatMessage(
        isMe: true,
        time: DateTime.now(),
        type: MessageType.udhaar,
        udhaarAmount: amount,
        udhaarDueDate: dueDate,
        udhaarProtection: protection,
        paymentMethod: paymentMethod,
        upiId: upiId,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        accountHolder: accountHolder,
      ),
    );

    messages.add(
      ChatMessage(
        isMe: false,
        time: DateTime.now(),
        type: MessageType.status,
        text: 'Waiting for $_otherName to accept the terms…',
      ),
    );

    if (otherUserId.isNotEmpty) {
      final summary =
          '[UDHAAR_REQUEST] ₹$amount | due:$dueDate | via:${paymentMethod.name}';
      _socket?.emitWithAck('message:send', {
        'chatId': otherUserId,
        'text': summary,
      }, ack: (_) {});
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _buildInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _debug(String message) {
    debugPrint('[ChatController] $message');
  }
}
