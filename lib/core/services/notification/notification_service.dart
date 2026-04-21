import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _kChannelId = 'unperch_reminders';
const _kChannelName = 'Unperch Reminders';

// ---------------------------------------------------------------------------
// NotificationService
// ---------------------------------------------------------------------------

/// Thin wrapper around [FlutterLocalNotificationsPlugin] for posting and
/// cancelling reminder notifications.
///
/// Call [initialize] once at app startup (or in the background service entry
/// point) before calling any other method.
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  // -------------------------------------------------------------------------
  // Initialisation
  // -------------------------------------------------------------------------

  /// Sets up Android and iOS notification channels / permissions.
  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);
  }

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Posts a high-priority reminder notification with the given [title],
  /// [body], and numeric [id].
  ///
  /// Replaces any existing notification with the same [id].
  Future<void> showReminder({
    required String title,
    required String body,
    required int id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  /// Cancels the notification with the given [id].
  Future<void> cancel(int id) => _plugin.cancel(id);
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

/// Provider for [NotificationService].
///
/// The instance is created lazily; [NotificationService.initialize] is
/// called automatically on first access.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
