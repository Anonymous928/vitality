import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Schedules the follow-up check-ins after an episode (PRD §6.2):
/// +1h, +6h, +24h, then daily until day 7 or until "recovered".
///
/// Inexact alarms only, so no SCHEDULE_EXACT_ALARM permission is needed.
/// All text is generic and user-editable; nothing sensitive reaches the
/// lock screen.
class CheckInScheduler {
  CheckInScheduler._();
  static final instance = CheckInScheduler._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Set by the app to route a tapped notification. Payload: `checkin:<id>`.
  void Function(String payload)? onTap;

  static const _offsets = [
    Duration(hours: 1),
    Duration(hours: 6),
    Duration(hours: 24),
    Duration(days: 2),
    Duration(days: 3),
    Duration(days: 4),
    Duration(days: 5),
    Duration(days: 6),
    Duration(days: 7),
  ];

  static const _channel = AndroidNotificationDetails(
    'checkins',
    'Check-in reminders',
    channelDescription: 'Gentle reminders to rate how you feel',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    // On a secure lock screen Android shows only "Contents hidden".
    visibility: NotificationVisibility.private,
    category: AndroidNotificationCategory.reminder,
  );

  /// Lazy: called on first schedule or on launch from a notification, never
  /// on the startup critical path.
  Future<void> _ensureReady() async {
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_notify'),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.payload != null) onTap?.call(r.payload!);
      },
    );
    _ready = true;
  }

  /// If the app was cold-started by tapping a notification, its payload.
  Future<String?> launchPayload() async {
    await _ensureReady();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details!.notificationResponse?.payload;
    }
    return null;
  }

  Future<bool> requestPermission() async {
    await _ensureReady();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<void> scheduleFor({
    required int episodeId,
    required DateTime occurredAt,
    required String text,
  }) async {
    await _ensureReady();
    await cancelFor(episodeId);
    final now = DateTime.now();
    for (var i = 0; i < _offsets.length; i++) {
      final when = occurredAt.add(_offsets[i]);
      if (when.isBefore(now)) continue; // back-logged episodes
      await _plugin.zonedSchedule(
        id: _id(episodeId, i),
        title: text,
        body: 'Tap to rate how you feel',
        // Reminders are absolute instants (episode + offset), so UTC is
        // exact and needs no timezone database or device zone lookup.
        scheduledDate: tz.TZDateTime.from(when, tz.UTC),
        notificationDetails: const NotificationDetails(android: _channel),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'checkin:$episodeId',
      );
    }
  }

  Future<void> cancelFor(int episodeId) async {
    await _ensureReady();
    for (var i = 0; i < _offsets.length; i++) {
      await _plugin.cancel(id: _id(episodeId, i));
    }
  }

  static int _id(int episodeId, int slot) => episodeId * 16 + slot;
}
