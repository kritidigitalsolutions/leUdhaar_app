import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:intl/intl.dart';
import 'package:leudaar_app/models/request_model/leUdhaar_request/leudhaarReq_modles.dart';
import 'package:leudaar_app/utils/custom_snackbar.dart';
import 'package:leudaar_app/utils/service/socket_service.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:leudaar_app/data/api_response.dart';
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

  late final SocketService _socketService;

  @override
  void onInit() {
    super.onInit();
    _socketService = Get.find<SocketService>();
  }

  Future<void> getChatList() async {
    chatListRes.value = ApiResponse.loading();
    try {
      final result = await _repo.getChatList();
      chatListRes.value = result;

      // Seed unread counts into SocketService after loading
      final chats = result.data?.data ?? [];
      for (final chat in chats) {
        if (chat.id != null && chat.unreadCount != null) {
          _socketService.setInitialUnread(chat.id!, chat.unreadCount!);
        }
      }
    } catch (e) {
      chatListRes.value = ApiResponse.error(e.toString());
    }
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
  final String? id;
  final String? text;
  final String? fileName;
  final String? imagePath;
  final String? imageUrl;
  final String? fileUrl;
  final bool isMe;
  final DateTime time;
  final MessageType type;
  final bool isPending;
  final String? status; // 'sent' | 'delivered' | 'read'

  // Udhaar-specific

  final double? udhaarAmount;
  final String? udhaarDueDate;
  final String? udhaarProtection;
  final PaymentMethod? paymentMethod;
  final String? upiId;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolder;

  // Request Money (received)
  final String? requestId;
  final String? requestStatus; // 'pending' | 'accepted' | 'rejected'

  ChatMessage({
    this.id,
    this.text,
    this.fileName,
    this.imagePath,
    this.imageUrl,
    this.fileUrl,
    required this.isMe,
    required this.time,
    required this.type,
    this.isPending = false,
    this.status = 'sent',
    this.udhaarAmount,
    this.udhaarDueDate,
    this.udhaarProtection,
    this.paymentMethod,
    this.upiId,
    this.accountNumber,
    this.ifscCode,
    this.accountHolder,
    this.requestId,
    this.requestStatus,
  });

  // ChatMessage mein full constructor wali jagah ek helper add karo
  ChatMessage withRequestStatus(String newStatus) {
    return ChatMessage(
      id: id,
      text: text,
      fileName: fileName,
      imagePath: imagePath,
      imageUrl: imageUrl,
      fileUrl: fileUrl,
      isMe: isMe,
      time: time,
      type: type,
      isPending: isPending,
      status: status,
      udhaarAmount: udhaarAmount,
      udhaarDueDate: udhaarDueDate,
      udhaarProtection: udhaarProtection,
      paymentMethod: paymentMethod,
      upiId: upiId,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      accountHolder: accountHolder,
      requestId: requestId,
      requestStatus: newStatus,
    );
  }

  factory ChatMessage.fromSocket(Map<String, dynamic> json, String myUserId) {
    final senderId = json['sender']?.toString() ?? '';
    final attachment = json['attachment'] as Map<String, dynamic>?;

    String? serverImageUrl;
    String? serverFileUrl;
    String? fileNameFromAttachment;

    if (attachment != null) {
      final url = attachment['url']?.toString();
      fileNameFromAttachment =
          attachment['originalName']?.toString() ??
          attachment['fileName']?.toString();

      if (url != null && url.isNotEmpty) {
        final fullUrl = url.startsWith('/')
            ? 'http://192.168.1.19:5005$url'
            : url;
        if (json['messageType'] == 'image') {
          serverImageUrl = fullUrl;
        } else {
          serverFileUrl = fullUrl;
        }
      }
    }

    // Handle request money payload embedded in message
    final requestData = json['requestData'] as Map<String, dynamic>?;
    double? udhaarAmount;
    String? udhaarDueDate;
    String? requestId;
    String? requestStatus;
    PaymentMethod? paymentMethod;
    String? upiId;
    String? accountNumber;
    String? ifscCode;
    String? accountHolder;

    if (requestData != null) {
      udhaarAmount = (requestData['amount'] as num?)?.toDouble();
      udhaarDueDate = requestData['returnDate']?.toString();
      requestId =
          requestData['_id']?.toString() ?? requestData['id']?.toString();
      requestStatus = requestData['status']?.toString() ?? 'pending';

      final receiveMethod = requestData['receiveMethod']?.toString();
      paymentMethod = receiveMethod == 'upi'
          ? PaymentMethod.upi
          : PaymentMethod.bank;

      final receiveDetails = requestData['receiveDetails'] as Map?;
      upiId = receiveDetails?['upiId']?.toString();
      accountNumber = receiveDetails?['accountNumber']?.toString();
      ifscCode = receiveDetails?['ifscCode']?.toString();
      accountHolder = receiveDetails?['accountHolderName']?.toString();
    }

    final msgType = json['messageType']?.toString() ?? '';

    return ChatMessage(
      id: json['_id']?.toString(),
      text: json['text']?.toString(),
      imageUrl: serverImageUrl,
      fileUrl: serverFileUrl,
      fileName: fileNameFromAttachment,
      isMe: senderId == myUserId,
      time: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      type: msgType == 'udhaar'
          ? MessageType.udhaar
          : _parseMessageType(msgType),
      isPending: false,
      status: json['status']?.toString() ?? 'sent',
      udhaarAmount: udhaarAmount,
      udhaarDueDate: udhaarDueDate,
      paymentMethod: paymentMethod,
      upiId: upiId,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      accountHolder: accountHolder,
      requestId: requestId,
      requestStatus: requestStatus,
    );
  }

  static MessageType _parseMessageType(String raw) {
    switch (raw) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'udhaar':
      case 'moneyRequest': // ← ADD THIS
        return MessageType.udhaar;
      default:
        return MessageType.text;
    }
  }

  ChatMessage copyWith({
    String? id,
    bool? isPending,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    String? status,
    String? requestStatus,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text,
      fileName: fileName ?? this.fileName,
      imagePath: imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      isMe: isMe,
      time: time,
      type: type,
      isPending: isPending ?? this.isPending,
      status: status ?? this.status,
      udhaarAmount: udhaarAmount,
      udhaarDueDate: udhaarDueDate,
      udhaarProtection: udhaarProtection,
      paymentMethod: paymentMethod,
      upiId: upiId,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      accountHolder: accountHolder,
      requestId: requestId,
      requestStatus: requestStatus ?? this.requestStatus,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAT CONTROLLER
// ─────────────────────────────────────────────────────────────────────────────

class ChatController extends GetxController {
  // ── Reactive State ──────────────────────────────────────────────────────
  final messages = <ChatMessage>[].obs;
  final messageController = TextEditingController();
  final isConnected = false.obs;
  final isOtherTyping = false.obs;
  final isSending = false.obs;
  final connectionStatus = 'Connecting…'.obs;

  // ── Online / Offline (read from SocketService) ──────────────────────────
  final isOtherUserOnline = false.obs;
  final otherUserLastSeen = Rxn<DateTime>();

  // ── Pagination ──────────────────────────────────────────────────────────
  final isLoadingHistory = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int _currentPage = 1;
  static const int _pageLimit = 50;

  // ── User Data ────────────────────────────────────────────────────────────
  late final String _jwtToken;
  late final String _myUserId;
  late String otherUserId;
  late final String _otherName;
  late final String _otherInitials;

  String get otherName => _otherName;
  String get otherInitials => _otherInitials;

  // ── Request Money ────────────────────────────────────────────────────────
  final isSendingRequest = false.obs;

  // ── Repos ────────────────────────────────────────────────────────────────
  final _repo = ProfileRepo();
  final LeudhaarRepo leRepo = LeudhaarRepo();
  final clearAllChatRes = Rx<ApiResponse<Map<String, dynamic>>?>(null);
  final msgRes = Rx<ApiResponse<Map<String, dynamic>>?>(null);

  // ── Socket (own instance for chat room) ─────────────────────────────────
  IO.Socket? _socket;
  bool _hasJoined = false;

  // ── SocketService (shared, for presence + unread) ────────────────────────
  late final SocketService _socketService;

  static const String _serverUrl = 'http://192.168.1.19:5005';

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _socketService = Get.find<SocketService>();
    _resolveIdentities();
    _loadChatHistory();
    _initSocket();
    _listenToPresence();
  }

  @override
  void onClose() {
    _debug('onClose called');
    _leaveChat();
    _socket?.dispose();
    messageController.dispose();
    super.onClose();
  }

  // ── Presence: watch SocketService reactive map ──────────────────────────
  void _listenToPresence() {
    if (otherUserId.isEmpty) return;

    // Initial check from cache
    _syncPresence();

    // Also request via socket after connect
    ever(isConnected, (bool connected) {
      if (connected) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _socketService.checkUserStatus(otherUserId, (isOnline, lastSeen) {
            isOtherUserOnline.value = isOnline;
            otherUserLastSeen.value = lastSeen;
          });
        });
      }
    });

    // Reactively update whenever SocketService.onlineUsers changes
    ever(_socketService.onlineUsers, (_) => _syncPresence());
    ever(_socketService.lastSeenMap, (_) => _syncLastSeen());
  }

  void _syncPresence() {
    final online = _socketService.onlineUsers[otherUserId];
    if (online != null) {
      isOtherUserOnline.value = online;
    }
  }

  void _syncLastSeen() {
    final lastSeen = _socketService.lastSeenMap[otherUserId];
    if (lastSeen != null) {
      otherUserLastSeen.value = lastSeen;
    }
  }

  // ── Resolve IDs ──────────────────────────────────────────────────────────
  void _resolveIdentities() {
    final String? token = AuthStorage.getToken();
    final user = AuthStorage.getUser();

    _jwtToken = token ?? '';
    _myUserId = user?.id ?? '';

    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _otherName = args["name"] ?? 'Unknown User';
      _otherInitials = _buildInitials(_otherName);
      otherUserId = args["id"] ?? '';
    } else {
      _otherName = 'Unknown';
      _otherInitials = 'U';
      otherUserId = '';
    }

    _debug('Resolved: myUserId=$_myUserId, otherUserId=$otherUserId');
  }

  // ── History ──────────────────────────────────────────────────────────────
  Future<void> _loadChatHistory({bool refresh = false}) async {
    if (otherUserId.isEmpty) return;

    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      messages.clear();
    }

    if (!hasMore.value && !refresh) return;

    if (refresh) {
      isLoadingHistory.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final token = AuthStorage.getToken();
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final url =
          '$_serverUrl/api/user/chats/with/$otherUserId/messages'
          '?page=$_currentPage&limit=$_pageLimit';

      final response = await dio.get(url);
      final model = ChatHistoryResModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (model.success == true && model.data != null) {
        final fetched = model.data!.messages.map((m) {
          // Check if it's a money request message
          final isMoneyRequest =
              m.messageType == 'moneyRequest' && m.moneyRequest != null;
          final mr = m.moneyRequest;

          if (isMoneyRequest && mr != null) {
            final receiveMethod = mr['receiveMethod']?.toString();
            final receiveDetails = mr['receiveDetails'] as Map?;
            final payMethod = receiveMethod == 'upi'
                ? PaymentMethod.upi
                : PaymentMethod.bank;

            final returnDateRaw = mr['returnDate']?.toString();
            String? formattedDueDate;
            if (returnDateRaw != null) {
              final parsed = DateTime.tryParse(returnDateRaw);
              if (parsed != null) {
                formattedDueDate = DateFormat('yyyy-MM-dd').format(parsed);
              }
            }

            return ChatMessage(
              id: m.id,
              isMe: m.sender == _myUserId,
              time: m.createdAt ?? DateTime.now(),
              type: MessageType.udhaar,
              isPending: false,
              status: m.status ?? 'sent',
              udhaarAmount: (mr['amount'] as num?)?.toDouble(),
              udhaarDueDate: formattedDueDate,
              udhaarProtection: mr['repaymentMode']?.toString(),
              paymentMethod: payMethod,
              upiId: receiveDetails?['upiId']?.toString(),
              accountNumber: receiveDetails?['accountNumber']?.toString(),
              ifscCode: receiveDetails?['ifscCode']?.toString(),
              accountHolder: receiveDetails?['accountHolderName']?.toString(),
              requestId: mr['_id']?.toString(),
              requestStatus: mr['status']?.toString() ?? 'pending',
            );
          }

          return ChatMessage(
            id: m.id,
            text: m.text,
            isMe: m.sender == _myUserId,
            time: m.createdAt ?? DateTime.now(),
            type: _mapMessageType(m.messageType),
            isPending: false,
            status: m.status ?? 'sent',
            imageUrl: _extractUrl(m, 'image'),
            fileUrl: _extractUrl(m, 'file'),
            fileName:
                m.attachment?['originalName']?.toString() ??
                m.attachment?['fileName']?.toString(),
          );
        }).toList();

        if (refresh) {
          messages.assignAll(fetched.reversed.toList());
        } else {
          messages.insertAll(0, fetched.reversed.toList());
        }

        _sortMessages();
        hasMore.value = model.data!.pagination?.hasMore ?? false;
        if (hasMore.value) _currentPage++;
      }
    } catch (e) {
      _debug('History error: $e');
    } finally {
      isLoadingHistory.value = false;
      isLoadingMore.value = false;
    }
  }

  String? _extractUrl(dynamic m, String type) {
    final url = m.attachment?['url']?.toString();
    if (url == null || url.isEmpty) return null;
    return url.startsWith('/') ? '$_serverUrl$url' : url;
  }

  Future<void> refreshHistory() => _loadChatHistory(refresh: true);

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
      case 'udhaar':
        return MessageType.udhaar;
      default:
        return MessageType.text;
    }
  }

  void _sortMessages() {
    messages.sort((a, b) => a.time.compareTo(b.time));
  }

  // ── Socket Init ──────────────────────────────────────────────────────────
  void _initSocket() {
    if (_jwtToken.isEmpty || otherUserId.isEmpty) {
      connectionStatus.value = 'Auth data missing';
      return;
    }

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
    });

    _socket?.onReconnect((_) {
      connectionStatus.value = 'Reconnected';
      _joinChat();
    });

    _socket?.onConnectError((error) {
      isConnected.value = false;
      connectionStatus.value = 'Connect error';
      _debug('Socket connect error: $error');
    });

    // ── New Message ─────────────────────────────────────────────────────
    _socket?.on('message:new', (raw) {
      _debug('message:new received');
      if (raw == null) return;

      Map<String, dynamic> data;
      if (raw is Map) {
        data = Map<String, dynamic>.from(raw);
      } else if (raw is String) {
        try {
          data = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {
          return;
        }
      } else {
        return;
      }

      try {
        // ── moneyRequest type handle karo ──────────────────────────
        final msgType = data['messageType']?.toString() ?? '';

        if (msgType == 'moneyRequest') {
          final mr = data['moneyRequest'] as Map<String, dynamic>?;
          if (mr == null) return;

          final senderId = data['sender']?.toString() ?? '';
          final receiveMethod = mr['receiveMethod']?.toString();
          final receiveDetails = mr['receiveDetails'] as Map?;
          final payMethod = receiveMethod == 'upi'
              ? PaymentMethod.upi
              : PaymentMethod.bank;

          final returnDateRaw = mr['returnDate']?.toString();
          String? formattedDueDate;
          if (returnDateRaw != null) {
            final parsed = DateTime.tryParse(returnDateRaw);
            if (parsed != null) {
              formattedDueDate = DateFormat('yyyy-MM-dd').format(parsed);
            }
          }

          final requestId = mr['_id']?.toString();

          // duplicate check
          if (messages.any(
            (m) => m.requestId == requestId && requestId != null,
          )) {
            return;
          }

          final msg = ChatMessage(
            id: data['_id']?.toString(),
            text: mr['reason']?.toString(),
            isMe: senderId == _myUserId,
            time: data['createdAt'] != null
                ? DateTime.tryParse(data['createdAt'].toString()) ??
                      DateTime.now()
                : DateTime.now(),
            type: MessageType.udhaar,
            isPending: false,
            status: 'sent',
            udhaarAmount: (mr['amount'] as num?)?.toDouble(),
            udhaarDueDate: formattedDueDate,
            udhaarProtection: mr['repaymentMode']?.toString(),
            paymentMethod: payMethod,
            upiId: receiveDetails?['upiId']?.toString(),
            accountNumber: receiveDetails?['accountNumber']?.toString(),
            ifscCode: receiveDetails?['ifscCode']?.toString(),
            accountHolder: receiveDetails?['accountHolderName']?.toString(),
            requestId: requestId,
            requestStatus: mr['status']?.toString() ?? 'pending',
          );

          messages.add(msg);
          _sortMessages();
          _markRead();
          return; // ← yahan return karo, neeche wala flow skip hoga
        }

        // ── normal messages (text/image/file) ──────────────────────
        final msg = ChatMessage.fromSocket(data, _myUserId);

        messages.removeWhere(
          (m) =>
              m.isPending &&
              m.isMe &&
              ((msg.type == MessageType.image && m.type == MessageType.image) ||
                  (msg.type == MessageType.file && m.type == MessageType.file)),
        );

        if (!messages.any((m) => m.id == msg.id && msg.id != null)) {
          messages.add(msg);
        }

        _sortMessages();
        _markRead();
      } catch (e) {
        _debug('Parse error in message:new: $e');
      }
    });
    // ── Message Read (update tick status) ─────────────────────────────

    // Payload: { chatId, readBy, readAt, messageIds }
    _socket?.on('message:read', (raw) {
      _debug('message:read event: $raw');
      if (raw is Map) {
        final readBy = raw['readBy']?.toString() ?? '';
        final messageIds = raw['messageIds'];

        if (readBy == otherUserId) {
          // Other user read our messages → update status to 'read'
          if (messageIds is List) {
            for (final id in messageIds) {
              final idx = messages.indexWhere((m) => m.id == id.toString());
              if (idx != -1) {
                messages[idx] = messages[idx].copyWith(status: 'read');
              }
            }
          } else {
            // Mark all sent messages as read
            for (int i = 0; i < messages.length; i++) {
              if (messages[i].isMe && messages[i].status != 'read') {
                messages[i] = messages[i].copyWith(status: 'read');
              }
            }
          }
          messages.refresh();
        }
      }
    });

    // ── Request Money received ─────────────────────────────────────────
    _socket?.on('request:new', (raw) {
      _debug('request:new received: $raw');
      if (raw == null) return;

      try {
        Map<String, dynamic> data;
        if (raw is Map) {
          data = Map<String, dynamic>.from(raw);
        } else if (raw is String) {
          data = jsonDecode(raw) as Map<String, dynamic>;
        } else {
          return;
        }

        // Server 'request:new' mein seedha request object bhejta hai
        // ya { request: {...} } ke andar
        final mr = (data['request'] as Map<String, dynamic>?) ?? data;

        final requestId = mr['_id']?.toString() ?? mr['id']?.toString();

        // Agar pehle se message:new se aa gaya to skip karo
        if (requestId != null &&
            messages.any((m) => m.requestId == requestId)) {
          _debug('request:new: already exists via message:new, skipping');
          return;
        }

        final senderId =
            mr['requestBy']?.toString() ??
            mr['requestFrom']?['_id']?.toString() ??
            '';
        final receiveMethod = mr['receiveMethod']?.toString();
        final receiveDetails = mr['receiveDetails'] as Map?;
        final payMethod = receiveMethod == 'upi'
            ? PaymentMethod.upi
            : PaymentMethod.bank;

        final returnDateRaw = mr['returnDate']?.toString();
        String? formattedDueDate;
        if (returnDateRaw != null) {
          final parsed = DateTime.tryParse(returnDateRaw);
          if (parsed != null) {
            formattedDueDate = DateFormat('yyyy-MM-dd').format(parsed);
          }
        }

        final msg = ChatMessage(
          id: requestId,
          text: mr['reason']?.toString(),
          isMe: senderId == _myUserId,
          time: mr['createdAt'] != null
              ? DateTime.tryParse(mr['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now(),
          type: MessageType.udhaar,
          isPending: false,
          status: 'sent',
          udhaarAmount: (mr['amount'] as num?)?.toDouble(),
          udhaarDueDate: formattedDueDate,
          udhaarProtection: mr['repaymentMode']?.toString(),
          paymentMethod: payMethod,
          upiId: receiveDetails?['upiId']?.toString(),
          accountNumber: receiveDetails?['accountNumber']?.toString(),
          ifscCode: receiveDetails?['ifscCode']?.toString(),
          accountHolder: receiveDetails?['accountHolderName']?.toString(),
          requestId: requestId,
          requestStatus: mr['status']?.toString() ?? 'pending',
        );

        messages.add(msg);
        _sortMessages();
      } catch (e) {
        _debug('request:new parse error: $e');
      }
    });

    // ── Typing ──────────────────────────────────────────────────────────
    _socket?.on('typing:start', (raw) {
      if (raw is Map && raw['userId']?.toString() != _myUserId) {
        isOtherTyping.value = true;
      }
    });

    _socket?.on('typing:stop', (raw) {
      if (raw is Map && raw['userId']?.toString() != _myUserId) {
        isOtherTyping.value = false;
      }
    });

    // ── Errors ──────────────────────────────────────────────────────────
    _socket?.on('chat:error', (raw) {
      final msg = raw is Map
          ? (raw['message']?.toString() ?? 'Error')
          : 'Socket error';
      Get.snackbar('Chat Error', msg, snackPosition: SnackPosition.TOP);
    });

    _socket?.connect();
  }

  // ── Chat Room ─────────────────────────────────────────────────────────────
  void _joinChat() {
    if (_hasJoined || otherUserId.isEmpty || _socket == null) return;

    _socket?.emitWithAck(
      'chat:join',
      {'receiverId': otherUserId},
      ack: (res) {
        if (res is Map && res['success'] == true) {
          _hasJoined = true;
          _markRead();
          // Also clear unread count in SocketService
          final chatId = res['data']?['chatId']?.toString();
          if (chatId != null) {
            _socketService.clearUnread(chatId);
          }
          _debug('chat:join success, chatId=$chatId');
        }
      },
    );
  }

  void _leaveChat() {
    if (_hasJoined && otherUserId.isNotEmpty) {
      _socket?.emit('chat:leave', {'receiverId': otherUserId});
    }
  }

  void _markRead() {
    if (otherUserId.isNotEmpty) {
      _socket?.emit('message:read', {'receiverId': otherUserId});
    }
  }

  // ── Typing ───────────────────────────────────────────────────────────────
  void onTypingChanged(String value) {
    if (otherUserId.isEmpty) return;
    final event = value.isNotEmpty ? 'typing:start' : 'typing:stop';
    _socket?.emit(event, {'receiverId': otherUserId});
  }

  // ── Send Text ────────────────────────────────────────────────────────────
  void sendText() {
    final text = messageController.text.trim();
    if (text.isEmpty || otherUserId.isEmpty || _socket == null) return;

    // Use a unique local id to find the optimistic message later
    // even if the list gets sorted
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final optimistic = ChatMessage(
      id: tempId,
      text: text,
      isMe: true,
      time: DateTime.now(),
      type: MessageType.text,
      isPending: true,
      status: 'sent',
    );

    messages.add(optimistic);
    messageController.clear();
    onTypingChanged('');

    _socket?.emitWithAck(
      'message:send',
      {'receiverId': otherUserId, 'text': text, 'messageType': 'text'},
      ack: (res) {
        _debug('message:send ack raw => $res (type: ${res.runtimeType})');

        // socket.io ack can come as List or Map — normalize it
        Map<String, dynamic>? response;

        if (res is Map) {
          response = Map<String, dynamic>.from(res);
        } else if (res is List && res.isNotEmpty && res[0] is Map) {
          response = Map<String, dynamic>.from(res[0] as Map);
        }

        if (response == null) {
          _debug(
            'Ack is null or unrecognized format — keeping message as pending',
          );
          // Don't remove it — treat as sent (server may have received it)
          final idx = messages.indexWhere((m) => m.id == tempId);
          if (idx != -1) {
            messages[idx] = optimistic.copyWith(isPending: false, id: tempId);
          }
          return;
        }

        final success = response['success'] == true;
        _debug('message:send ack success=$success');

        // Find by tempId (safe even after sort)
        final idx = messages.indexWhere((m) => m.id == tempId);

        if (success) {
          final serverData = response['data'];

          Map<String, dynamic>? dataMap;
          if (serverData is Map) {
            dataMap = Map<String, dynamic>.from(serverData);
          }

          if (idx != -1) {
            messages[idx] = optimistic.copyWith(
              id: dataMap?['_id']?.toString() ?? tempId,
              isPending: false,
              status: 'sent',
            );
            _debug('Optimistic replaced with serverId=${dataMap?['_id']}');
          }
        } else {
          final errMsg =
              response['message']?.toString() ?? 'Could not send message';
          _debug('message:send failed: $errMsg');

          if (idx != -1) messages.removeAt(idx);

          Get.snackbar(
            'Failed',
            errMsg,
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFE53935),
            colorText: Colors.white,
          );
        }
      },
    );
  }

  // ── Upload Attachment ─────────────────────────────────────────────────────
  Future<String?> _uploadAttachment(File file, String type) async {
    try {
      final token = AuthStorage.getToken();
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          file.path,
          filename: p.basename(file.path),
        ),
        'type': type,
      });

      final url = '$_serverUrl/api/user/chats/with/$otherUserId/attachments';
      final response = await dio.post(url, data: formData);

      if (response.data is Map<String, dynamic>) {
        final res = response.data as Map<String, dynamic>;
        if (res['success'] == true && res['data'] != null) {
          final messagesList = res['data']['messages'] as List<dynamic>?;
          if (messagesList != null && messagesList.isNotEmpty) {
            final msg = messagesList.first as Map<String, dynamic>;
            final attachment = msg['attachment'] as Map<String, dynamic>?;
            if (attachment != null) {
              String? fileUrl = attachment['url']?.toString();
              if (fileUrl != null && fileUrl.startsWith('/')) {
                fileUrl = '$_serverUrl$fileUrl';
              }
              return fileUrl;
            }
          }
        }
      }
      return null;
    } catch (e) {
      _debug('Upload error: $e');
      return null;
    }
  }

  Future<void> sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    isSending.value = true;
    await _uploadAttachment(File(pickedFile.path), 'image');
    isSending.value = false;
  }

  Future<void> sendFile() async {
    final result = await FilePicker.pickFiles(allowMultiple: false);
    if (result == null || result.files.isEmpty) return;

    isSending.value = true;
    await _uploadAttachment(File(result.files.single.path!), 'file');
    isSending.value = false;
  }

  // ── Request Money (Udhaar) ────────────────────────────────────────────────
  Future<void> sendUdhaarFromSheet({
    required RequestMoneyReqModel model,
    // Local fields for optimistic bubble
    required double amount,
    required String returnDate,
    required String repaymentMode,
    required String receiveMethod,
    String? upiId,
    String? accountNumber,
    String? ifscCode,
    String? accountHolderName,
    String? reason,
  }) async {
    isSending.value = true;

    _sortMessages();

    try {
      await leRepo.requestMoney(model);
    } catch (e) {
      _debug('sendUdhaarFromSheet error: $e');
      AppSnackbar.show(
        title: 'Error',
        message: e.toString(),
        type: SnackBarType.error,
      );
    } finally {
      isSending.value = false;
    }
  }

  // ── Delete / Clear ────────────────────────────────────────────────────────
  Future<void> clearAllChat(String otherUserId) async {
    clearAllChatRes.value = ApiResponse.loading();
    clearAllChatRes.value = await _repo.clearAllChats(otherUserId);
  }

  Future<void> msgDelete(String msgId) async {
    msgRes.value = ApiResponse.loading();
    msgRes.value = await _repo.deleteChatMsg(msgId);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _buildInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _debug(String message) {
    debugPrint('[ChatController] $message');
  }

  // money request approvel and reject api

  final acceptingRequestId = ''.obs; // jo request accept ho rahi hai uska id
  final rejectingRequestId = ''.obs;

  Future<void> respondToRequest({
    required String requestId,
    required String status,
    required ChatMessage msg,
  }) async {
    // ── Specific request ka id set karo ──
    if (status == 'approved') {
      acceptingRequestId.value = requestId;
    } else {
      rejectingRequestId.value = requestId;
    }

    try {
      final response = await leRepo.rejectApprovel(requestId, status);

      if (response.status == Status.completed &&
          response.data?['success'] == true) {
        final idx = messages.indexWhere((m) => m.requestId == requestId);
        if (idx != -1) {
          messages[idx] = messages[idx].withRequestStatus(
            status == 'approved' ? 'approved' : 'declined',
          );
          messages.refresh();
        }

        AppSnackbar.show(
          title: status == 'approved' ? 'Accepted' : 'Rejected',
          message: response.data?['message'] ?? 'Done',
          type: status == 'approved'
              ? SnackBarType.success
              : SnackBarType.error,
        );
      } else {
        AppSnackbar.show(
          title: 'Failed',
          message: response.data?['message'] ?? 'Something went wrong',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      AppSnackbar.show(
        title: 'Error',
        message: e.toString(),
        type: SnackBarType.error,
      );
    } finally {
      // ── Clear karo ──
      acceptingRequestId.value = '';
      rejectingRequestId.value = '';
    }
  }
}
