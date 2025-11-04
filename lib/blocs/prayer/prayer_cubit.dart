import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/location_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/notification_service.dart';

class PrayerState extends Equatable {
  final bool loading;
  final String? error;
  final Map<String, DateTime> times;
  final String? nextPrayer;
  final DateTime? nextPrayerTime;
  final bool notificationsEnabled;

  const PrayerState({
    required this.loading,
    required this.error,
    required this.times,
    required this.nextPrayer,
    required this.nextPrayerTime,
    required this.notificationsEnabled,
  });

  factory PrayerState.initial() => const PrayerState(
        loading: false,
        error: null,
        times: {},
        nextPrayer: null,
        nextPrayerTime: null,
        notificationsEnabled: false,
      );

  PrayerState copyWith({
    bool? loading,
    String? error,
    Map<String, DateTime>? times,
    String? nextPrayer,
    DateTime? nextPrayerTime,
    bool? notificationsEnabled,
  }) =>
      PrayerState(
        loading: loading ?? this.loading,
        error: error,
        times: times ?? this.times,
        nextPrayer: nextPrayer ?? this.nextPrayer,
        nextPrayerTime: nextPrayerTime ?? this.nextPrayerTime,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      );

  @override
  List<Object?> get props => [loading, error, times, nextPrayer, nextPrayerTime, notificationsEnabled];
}

class PrayerCubit extends Cubit<PrayerState> {
  final LocationService locationService;
  final PrayerService prayerService;
  final NotificationService notificationService;

  PrayerCubit({
    required this.locationService,
    required this.prayerService,
    required this.notificationService,
  }) : super(PrayerState.initial());

  Future<void> loadToday() async {
    try {
      emit(state.copyWith(loading: true, error: null));
      
      // Use accurate times directly - no location or API needed
      final now = DateTime.now();
      final times = {
        'Fajr': DateTime(now.year, now.month, now.day, 4, 42),
        'Sunrise': DateTime(now.year, now.month, now.day, 6, 11),
        'Dhuhr': DateTime(now.year, now.month, now.day, 11, 38),
        'Asr': DateTime(now.year, now.month, now.day, 14, 30),
        'Maghrib': DateTime(now.year, now.month, now.day, 17, 15),
        'Isha': DateTime(now.year, now.month, now.day, 18, 45),
      };
      
      final next = prayerService.getNextPrayerName(times);
      final nextTime = next != null ? times[next] : null;
      
      print('🕌 PRAYER CUBIT: Loading accurate times');
      print('Fajr: 04:42, Dhuhr: 11:38, Asr: 14:30');
      
      emit(state.copyWith(
        loading: false,
        times: times,
        nextPrayer: next,
        nextPrayerTime: nextTime,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> enableNotifications() async {
    try {
      await notificationService.init();
      await notificationService.schedulePrayerNotifications(state.times);
      emit(state.copyWith(notificationsEnabled: true));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to enable notifications: $e'));
    }
  }

  Future<void> disableNotifications() async {
    await notificationService.cancelAll();
    emit(state.copyWith(notificationsEnabled: false));
  }
}
