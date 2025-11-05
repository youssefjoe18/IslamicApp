import 'package:flutter_test/flutter_test.dart';
import 'package:practice_4/core/services/prayer_calculation_service.dart';

void main() {
  group('PrayerCalculationService Tests', () {
    late PrayerCalculationService service;

    setUp(() {
      service = PrayerCalculationService();
    });

    test('should calculate prayer times for today', () {
      final today = DateTime.now();
      final times = service.calculatePrayerTimes(today);

      // Verify all prayer times are present
      expect(times.containsKey('Fajr'), true);
      expect(times.containsKey('Sunrise'), true);
      expect(times.containsKey('Dhuhr'), true);
      expect(times.containsKey('Asr'), true);
      expect(times.containsKey('Maghrib'), true);
      expect(times.containsKey('Isha'), true);

      // Verify times are in chronological order
      expect(times['Fajr']!.isBefore(times['Sunrise']!), true);
      expect(times['Sunrise']!.isBefore(times['Dhuhr']!), true);
      expect(times['Dhuhr']!.isBefore(times['Asr']!), true);
      expect(times['Asr']!.isBefore(times['Maghrib']!), true);
      expect(times['Maghrib']!.isBefore(times['Isha']!), true);

      // Print calculated times for verification
      print('Calculated Prayer Times for ${today.day}/${today.month}/${today.year}:');
      times.forEach((name, time) {
        print('$name: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
      });
    });

    test('should calculate different times for different seasons', () {
      // Test winter date (December 21)
      final winter = DateTime(2024, 12, 21);
      final winterTimes = service.calculatePrayerTimes(winter);

      // Test summer date (June 21)
      final summer = DateTime(2024, 6, 21);
      final summerTimes = service.calculatePrayerTimes(summer);

      // Fajr should be later in summer than winter
      expect(summerTimes['Fajr']!.hour >= winterTimes['Fajr']!.hour, true);
      
      // Maghrib should be later in summer than winter
      expect(summerTimes['Maghrib']!.hour >= winterTimes['Maghrib']!.hour, true);

      print('Winter Prayer Times (Dec 21):');
      winterTimes.forEach((name, time) {
        print('$name: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
      });

      print('\nSummer Prayer Times (Jun 21):');
      summerTimes.forEach((name, time) {
        print('$name: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
      });
    });

    test('should find next prayer correctly', () {
      final today = DateTime.now();
      final times = service.calculatePrayerTimes(today);
      final nextPrayer = service.getNextPrayerName(times);

      expect(nextPrayer, isNotNull);
      expect(['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].contains(nextPrayer), true);

      print('Next prayer: $nextPrayer');
    });

    test('should format time correctly', () {
      final testTime = DateTime(2024, 11, 5, 14, 43);
      final formatted = service.formatPrayerTime(testTime);
      
      expect(formatted, '02:43 PM');
      print('Formatted time: $formatted');
    });

    test('should calculate prayer times for reference date correctly', () {
      // Test with the reference date (November 5, 2024)
      final referenceDate = DateTime(2024, 11, 5);
      final times = service.calculatePrayerTimes(referenceDate);

      print('Reference Date Prayer Times (Nov 5, 2024):');
      times.forEach((name, time) {
        print('$name: ${service.formatPrayerTime(time)}');
      });

      // The times should be close to the provided reference times
      // Fajr: 04:44, Sunrise: 06:11, Dhuhr: 11:39, Asr: 02:43, Maghrib: 05:06, Isha: 06:25
      expect(times['Fajr']!.hour, 4);
      expect(times['Fajr']!.minute, closeTo(44, 5)); // Allow 5 minutes tolerance
      
      expect(times['Dhuhr']!.hour, 11);
      expect(times['Dhuhr']!.minute, closeTo(39, 5));
    });
  });
}
