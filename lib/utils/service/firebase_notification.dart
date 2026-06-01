import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');

  // You can process the message here
  // Save to local DB, update state, etc.
}

class FCMNotificationService {
  static final FCMNotificationService _instance =
      FCMNotificationService._internal();
  factory FCMNotificationService() => _instance;
  FCMNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream controllers for real-time updates
  final StreamController<String> _tokenController =
      StreamController<String>.broadcast();
  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _notificationClickController =
      StreamController<String>.broadcast();

  Stream<String> get tokenStream => _tokenController.stream;
  Stream<RemoteMessage> get messageStream => _messageController.stream;
  Stream<String> get notificationClickStream =>
      _notificationClickController.stream;

  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  /// Initialize FCM with all necessary configurations
  Future<void> initialize() async {
    if (_isInitialized) {
      print('FCM already initialized');
      return;
    }

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await requestPermission();

      // Get FCM token
      // first check saved token
      String? savedToken = await getSavedToken();

      if (savedToken != null) {
        _fcmToken = savedToken;
        print("Saved token found: $savedToken");
      } else {
        // get token silently (without permission popup on Android)
        await getToken();
      }
      // Setup message handlers
      _setupMessageHandlers();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _tokenController.add(newToken);
        _saveTokenToPrefs(newToken);
        print('FCM Token refreshed: $newToken');
      });

      _isInitialized = true;
      print('FCM Notification Service initialized successfully');
    } catch (e) {
      print('Error initializing FCM: $e');
      rethrow;
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          _notificationClickController.add(response.payload!);
        }
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // name
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // For iOS, request local notification permissions
    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    return settings;
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      // For iOS simulator, token might be null
      _fcmToken = await _firebaseMessaging.getToken();

      if (_fcmToken != null) {
        print('FCM Token: $_fcmToken');
        _tokenController.add(_fcmToken!);
        await _saveTokenToPrefs(_fcmToken!);
      } else {
        print('Unable to get FCM token (iOS Simulator?)');
      }

      return _fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    // Handle messages when app is in FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }

      // Broadcast message to listeners
      _messageController.add(message);
    });

    // Handle when user taps notification - app in BACKGROUND (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      // Handle navigation based on notification data
      _handleNotificationClick(message);
    });

    // Handle when app is opened from TERMINATED state via notification
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state via notification');
        print('Message data: ${message.data}');

        // Handle navigation based on notification data
        _handleNotificationClick(message);
      }
    });
  }

  /// Show local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        id: notification.hashCode,

        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['route'] ?? message.data.toString(),
      );
    }
  }

  /// Handle notification click/tap
  void _handleNotificationClick(RemoteMessage message) {
    // Extract route or action from notification data
    String? route = message.data['route'];
    String? action = message.data['action'];

    // Broadcast to listeners
    _notificationClickController.add(route ?? action ?? 'default');

    // You can implement navigation logic here or in your widget
    print('Notification clicked - Route: $route, Action: $action');
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    _fcmToken = null;
    await _removeTokenFromPrefs();
    print('FCM Token deleted');
  }

  /// Save token to SharedPreferences
  Future<void> _saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    await prefs.setString(
      'fcm_token_timestamp',
      DateTime.now().toIso8601String(),
    );
  }

  /// Remove token from SharedPreferences
  Future<void> _removeTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token');
    await prefs.remove('fcm_token_timestamp');
  }

  /// Get saved token from SharedPreferences
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Dispose streams
  void dispose() {
    _tokenController.close();
    _messageController.close();
    _notificationClickController.close();
  }
}
