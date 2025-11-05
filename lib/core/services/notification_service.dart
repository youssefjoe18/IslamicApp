import 'package:flutter/material.dart';
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
      const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
      const InitializationSettings settings = InitializationSettings(android: androidInit);
      await plugin.initialize(settings);
      
      // Request notification permissions
      await _requestPermissions();
      
      // Create notification channel for Android
      final androidImplementation = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        const androidChannel = AndroidNotificationChannel(
          'prayers_channel',
          'Prayer Notifications',
          description: 'Notifications for prayer times',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color(0xFF00A876),
          showBadge: true,
        );
        await androidImplementation.createNotificationChannel(androidChannel);
        print('✅ Notification channel created successfully');
      }
      
      _initialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      // If initialization fails, mark as initialized to avoid retry loops
      _initialized = true;
      print('❌ Notification initialization error: $e');
      rethrow;
    }
  }

  Future<void> _requestPermissions() async {
    final androidImplementation = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      // Check if notifications are enabled
      final areNotificationsEnabled = await androidImplementation.areNotificationsEnabled();
      print('📱 Notifications currently enabled: $areNotificationsEnabled');
      
      // Request notification permission (Android 13+)
      final granted = await androidImplementation.requestNotificationsPermission();
      print('📱 Notification permission granted: $granted');
      
      // Check exact alarm permission
      final canScheduleExactAlarms = await androidImplementation.canScheduleExactNotifications();
      print('⏰ Can schedule exact alarms: $canScheduleExactAlarms');
      
      // Request exact alarm permission if needed
      if (canScheduleExactAlarms == false) {
        final exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
        print('⏰ Exact alarm permission granted: $exactAlarmGranted');
      }
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
    try {
      await init();
      
      // Use default notification sound instead of custom adhan sound to avoid resource errors
      const androidDetails = AndroidNotificationDetails(
        'prayers_channel',
        'Prayer Notifications',
        channelDescription: 'Notifications for prayer times',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: const Color(0xFF00A876),
        ledOnMs: 1000,
        ledOffMs: 500,
        showWhen: true,
        when: null,
        usesChronometer: false,
        chronometerCountDown: false,
        channelShowBadge: true,
        onlyAlertOnce: false,
        ongoing: false,
        autoCancel: true,
        silent: false,
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      );
      const details = NotificationDetails(android: androidDetails);
      
      final scheduledTime = tz.TZDateTime.from(time, tz.local);
      if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
        print('⏰ Skipping past time: $time');
        return; // Don't schedule past times
      }
      
      print('⏰ Scheduling notification for $title at $scheduledTime');
      
      await plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      print('✅ Successfully scheduled notification: $title');
    } catch (e) {
      print('❌ Failed to schedule notification: $e');
      // Try fallback scheduling without exact timing
      try {
        await _scheduleFallback(id: id, title: title, body: body, time: time);
      } catch (fallbackError) {
        print('❌ Fallback scheduling also failed: $fallbackError');
      }
    }
  }

  Future<void> _scheduleFallback({required int id, required String title, required String body, required DateTime time}) async {
    const androidDetails = AndroidNotificationDetails(
      'prayers_channel',
      'Prayer Notifications',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
    );
    const details = NotificationDetails(android: androidDetails);
    
    final scheduledTime = tz.TZDateTime.from(time, tz.local);
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }
    
    await plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    print('✅ Fallback notification scheduled: $title');
  }

  /// Show immediate notification for testing
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    try {
      await init();
      
      const androidDetails = AndroidNotificationDetails(
        'prayers_channel',
        'Prayer Notifications',
        channelDescription: 'Notifications for prayer times',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFF00A876),
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        showWhen: true,
        autoCancel: true,
      );
      const details = NotificationDetails(android: androidDetails);
      
      await plugin.show(id, title, body, details);
      print('✅ Immediate notification shown: $title');
    } catch (e) {
      print('❌ Failed to show immediate notification: $e');
      rethrow;
    }
  }
}
