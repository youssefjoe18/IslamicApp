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
      
      // Use calculated prayer times with seasonal adjustments
      final position = await locationService.getCurrentPosition();
      final times = await prayerService.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      final next = prayerService.getNextPrayerName(times);
      final nextTime = next != null ? times[next] : null;
      
      print('🕌 PRAYER CUBIT: Loading calculated times with seasonal adjustments');
      
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
