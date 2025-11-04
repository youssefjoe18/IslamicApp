import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'location_service.dart';
import 'prayer_service.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings settings = InitializationSettings(android: androidInit);
      await plugin.initialize(settings);
      
      // Create notification channel for Android
      final androidImplementation = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        const androidChannel = AndroidNotificationChannel(
          'prayers_channel',
          'Prayer Notifications',
          description: 'Notifications for prayer times',
          importance: Importance.max,
        );
        await androidImplementation.createNotificationChannel(androidChannel);
      }
      
      _initialized = true;
    } catch (e) {
      // If initialization fails, mark as initialized to avoid retry loops
      _initialized = true;
      rethrow;
    }
  }

  Future<void> cancelAll() async {
    await plugin.cancelAll();
  }

  Future<void> schedulePrayerNotifications(Map<String, DateTime> prayerTimes) async {
    await init();
    await cancelAll();
    
    final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    int id = 100;
    
    for (final name in prayerNames) {
      final time = prayerTimes[name];
      if (time != null && time.isAfter(DateTime.now())) {
        await scheduleSingle(
          id: id++,
          title: 'Prayer Time',
          body: '$name prayer time',
          time: time,
        );
      }
    }
    
    // Schedule next day's Fajr if all prayers passed
    final now = DateTime.now();
    final ishaTime = prayerTimes['Isha'];
    if (ishaTime != null && now.isAfter(ishaTime)) {
      // All prayers for today have passed - would need to recalculate tomorrow's times
      // For now, this is handled by the app reloading times daily
    }
  }

  Future<void> scheduleForTodayUsing({required LocationService locationService, required PrayerService prayerService}) async {
    final pos = await locationService.getCurrentPosition();
    final times = await prayerService.getPrayerTimes(latitude: pos.latitude, longitude: pos.longitude);
    // exclude Sunrise
    times.remove('Sunrise');
    await schedulePrayerNotifications(times);
  }

  Future<void> scheduleSingle({required int id, required String title, required String body, required DateTime time}) async {
    await init();
    // Use default notification sound instead of custom adhan sound to avoid resource errors
    const androidDetails = AndroidNotificationDetails(
      'prayers_channel',
      'Prayer Notifications',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);
    
    final scheduledTime = tz.TZDateTime.from(time, tz.local);
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return; // Don't schedule past times
    }
    
    await plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
