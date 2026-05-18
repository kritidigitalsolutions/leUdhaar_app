import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService extends GetxService {
  IO.Socket? socket;

  final isConnected = false.obs;

  /// userId -> true/false
  final onlineUsers = <String, bool>{}.obs;

  /// userId -> lastSeenAt (when offline)
  final lastSeenMap = <String, DateTime?>{}.obs;

  /// chatId -> unread count  (key = chat._id from server)
  final unreadCounts = <String, int>{}.obs;

  /// Total unread across all chats
  final totalUnread = 0.obs;

  static const String serverUrl = 'http://192.168.1.15:5005';

  String? token;
  String? myUserId;

  Future<SocketService> init(String jwt, String userId) async {
    token = jwt;
    myUserId = userId;
    _connect();
    return this;
  }

  void _connect() {
    if (token == null || token!.isEmpty) {
      _debug('⚠️ Token empty, skipping socket connect');
      return;
    }

    _debug('🔌 Connecting socket...');

    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    socket?.onConnect((_) {
      isConnected.value = true;
      _debug('✅ Connected: ${socket?.id}');
      _listen();
    });

    socket?.onDisconnect((_) {
      isConnected.value = false;
      _debug('❌ Disconnected');
    });

    socket?.onReconnect((_) {
      isConnected.value = true;
      _debug('🔄 Reconnected');
    });

    socket?.onConnectError((err) {
      isConnected.value = false;
      _debug('⚠️ Connect error => $err');
    });

    socket?.onError((err) {
      _debug('🚨 Socket error => $err');
    });

    socket?.connect();
  }

  void _listen() {
    _debug('🎧 Registering event listeners...');

    // ── Presence ─────────────────────────────────────────────────────────
    // Server emits: user:status, user:online, user:offline
    // Payload: { userId, isOnline, lastSeenAt }

    socket?.on('user:status', _handleUserStatus);
    socket?.on('user:online', _handleUserStatus);
    socket?.on('user:offline', _handleUserStatus);

    // ── Unread Counts ─────────────────────────────────────────────────────
    // Server emits: unread:updated
    // Payload: { chatId, otherUserId, unreadCount }
    socket?.on('unread:updated', (data) {
      _debug('📩 unread:updated => $data');
      try {
        final chatId = data['chatId']?.toString() ?? '';
        final count = (data['unreadCount'] as num?)?.toInt() ?? 0;

        if (chatId.isNotEmpty) {
          unreadCounts[chatId] = count;
          unreadCounts.refresh();

          // Recalculate total
          _recalcTotal();
        }
      } catch (e) {
        _debug('❌ unread:updated error => $e');
      }
    });

    // ── Message Read (update status in chat) ──────────────────────────────
    // Server emits: message:read
    // Payload: { chatId, readBy, readAt, messageIds }
    socket?.on('message:read', (data) {
      _debug('✅ message:read => $data');
      // ChatController handles this internally
      // But if a chatId is read, set that chat unread = 0
      try {
        final chatId = data['chatId']?.toString() ?? '';
        final readBy = data['readBy']?.toString() ?? '';

        // If the other user read our messages (not us)
        if (chatId.isNotEmpty && readBy != myUserId) {
          // Don't clear our unread here — server sends unread:updated for that
          _debug('📖 Messages read by $readBy in chat $chatId');
        }
      } catch (e) {
        _debug('❌ message:read error => $e');
      }
    });

    // ── Chat List Updated ─────────────────────────────────────────────────
    // Server emits: chat:updated
    // Payload: chat object (for refreshing chat list)
    socket?.on('chat:updated', (data) {
      _debug('🔄 chat:updated => $data');
      // ChatListController will re-fetch or update its list
      // We just broadcast this via a stream / callback
    });
  }

  void _handleUserStatus(dynamic data) {
    _debug('📡 user status event => $data');
    try {
      final userId = data['userId']?.toString() ?? '';
      final isOnline = data['isOnline'] == true;
      final lastSeenRaw = data['lastSeenAt']?.toString();

      if (userId.isNotEmpty) {
        onlineUsers[userId] = isOnline;
        onlineUsers.refresh();

        if (!isOnline && lastSeenRaw != null) {
          lastSeenMap[userId] = DateTime.tryParse(lastSeenRaw);
          lastSeenMap.refresh();
        } else if (isOnline) {
          lastSeenMap[userId] = null;
          lastSeenMap.refresh();
        }

        _debug(
          '👤 $userId => ${isOnline ? "Online" : "Offline"} | lastSeen=$lastSeenRaw',
        );
      }
    } catch (e) {
      _debug('❌ _handleUserStatus error => $e');
    }
  }

  void _recalcTotal() {
    int total = 0;
    for (final count in unreadCounts.values) {
      total += count;
    }
    totalUnread.value = total;
    _debug('📊 Total unread => $total');
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Call from ChatListController after loading chats from API
  /// to seed initial unread counts
  void setInitialUnread(String chatId, int count) {
    unreadCounts[chatId] = count;
    unreadCounts.refresh();
    _recalcTotal();
    _debug('🟢 Initial unread set => $chatId : $count');
  }

  /// Call when user opens a chat (mark read locally)
  void clearUnread(String chatId) {
    unreadCounts[chatId] = 0;
    unreadCounts.refresh();
    _recalcTotal();
  }

  bool isUserOnline(String userId) => onlineUsers[userId] ?? false;

  DateTime? getLastSeen(String userId) => lastSeenMap[userId];

  int getUnread(String chatId) => unreadCounts[chatId] ?? 0;

  /// Check another user's online status via socket
  void checkUserStatus(
    String targetUserId,
    Function(bool isOnline, DateTime? lastSeen) onResult,
  ) {
    socket?.emitWithAck(
      'user:status:check',
      {'userId': targetUserId},
      ack: (response) {
        try {
          if (response is Map && response['success'] == true) {
            final data = response['data'] as Map?;
            final isOnline = data?['isOnline'] == true;
            final lastSeenRaw = data?['lastSeenAt']?.toString();
            final lastSeen = lastSeenRaw != null
                ? DateTime.tryParse(lastSeenRaw)
                : null;

            // Update local cache
            onlineUsers[targetUserId] = isOnline;
            onlineUsers.refresh();
            if (!isOnline) {
              lastSeenMap[targetUserId] = lastSeen;
              lastSeenMap.refresh();
            }

            onResult(isOnline, lastSeen);
          }
        } catch (e) {
          _debug('❌ checkUserStatus error => $e');
        }
      },
    );
  }

  void debugState() {
    _debug('------ SOCKET STATE ------');
    _debug('Connected    => ${isConnected.value}');
    _debug('Online Users => $onlineUsers');
    _debug('Last Seen    => $lastSeenMap');
    _debug('Unread Counts=> $unreadCounts');
    _debug('Total Unread => ${totalUnread.value}');
    _debug('--------------------------');
  }

  void _debug(String message) {
    debugPrint('[SocketService] $message');
  }

  @override
  void onClose() {
    socket?.dispose();
    super.onClose();
  }
}
