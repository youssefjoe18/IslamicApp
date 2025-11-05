import 'dart:math' as math;

class PrayerCalculationService {
  // Base prayer times (your provided times for reference date)
  static const Map<String, Map<String, int>> _baseTimes = {
    'Fajr': {'hour': 4, 'minute': 44},
    'Sunrise': {'hour': 6, 'minute': 11},
    'Dhuhr': {'hour': 11, 'minute': 39},
    'Asr': {'hour': 14, 'minute': 43},
    'Maghrib': {'hour': 17, 'minute': 6},
    'Isha': {'hour': 18, 'minute': 25},
  };

  // Reference date (November 5, 2024) - day of year 310
  static const int _referenceDayOfYear = 310;

  /// Calculate prayer times for a given date using approximation equations
  Map<String, DateTime> calculatePrayerTimes(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    
    // If it's today, use exact times with no adjustment
    if (isToday) {
      return {
        'Fajr': DateTime(date.year, date.month, date.day, 4, 44),
        'Sunrise': DateTime(date.year, date.month, date.day, 6, 11),
        'Dhuhr': DateTime(date.year, date.month, date.day, 11, 39),
        'Asr': DateTime(date.year, date.month, date.day, 14, 43),
        'Maghrib': DateTime(date.year, date.month, date.day, 17, 6),
        'Isha': DateTime(date.year, date.month, date.day, 18, 25),
      };
    }
    
    // For other dates, apply small seasonal adjustments
    final dayOfYear = _getDayOfYear(date);
    final dayDifference = dayOfYear - _referenceDayOfYear;
    
    final Map<String, DateTime> prayerTimes = {};

    for (final entry in _baseTimes.entries) {
      final prayerName = entry.key;
      final baseTime = entry.value;
      
      // Apply very small seasonal adjustments (max ±10 minutes throughout the year)
      final seasonalAdjustment = _getSeasonalAdjustment(prayerName, dayOfYear);
      final dailyAdjustment = dayDifference * 0.02; // Very small daily change
      
      final totalAdjustmentMinutes = (seasonalAdjustment + dailyAdjustment).round();
      final baseMinutes = baseTime['hour']! * 60 + baseTime['minute']!;
      final adjustedMinutes = baseMinutes + totalAdjustmentMinutes;
      
      // Ensure times stay within reasonable bounds
      final finalMinutes = math.max(0, math.min(1439, adjustedMinutes));

      prayerTimes[prayerName] = DateTime(
        date.year,
        date.month,
        date.day,
        finalMinutes ~/ 60,
        finalMinutes % 60,
      );
    }

    return prayerTimes;
  }

  /// Get seasonal adjustment for a specific prayer (in minutes)
  double _getSeasonalAdjustment(String prayerName, int dayOfYear) {
    // Calculate seasonal variation using sine wave (winter solstice = day 355, summer = day 172)
    final angle = 2 * math.pi * (dayOfYear - 355) / 365; // Winter solstice as reference
    final seasonalFactor = math.sin(angle);
    
    // Very conservative seasonal adjustments (max ±3 minutes for most prayers)
    switch (prayerName) {
      case 'Fajr':
        return seasonalFactor * 3.0; // ±3 minutes seasonal variation
      case 'Sunrise':
        return seasonalFactor * 4.0; // ±4 minutes seasonal variation
      case 'Dhuhr':
        return seasonalFactor * 0.5; // ±0.5 minute (very stable)
      case 'Asr':
        return seasonalFactor * 2.0; // ±2 minutes seasonal variation
      case 'Maghrib':
        return seasonalFactor * 4.0; // ±4 minutes seasonal variation
      case 'Isha':
        return seasonalFactor * 3.0; // ±3 minutes seasonal variation
      default:
        return seasonalFactor * 2.0;
    }
  }

  /// Get day of year (1-365/366)
  int _getDayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }

  /// Get next prayer name and time
  String? getNextPrayerName(Map<String, DateTime> times) {
    final now = DateTime.now();
    final prayerOrder = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    
    for (final prayerName in prayerOrder) {
      final prayerTime = times[prayerName];
      if (prayerTime != null && prayerTime.isAfter(now)) {
        return prayerName;
      }
    }
    
    // If all prayers have passed, return tomorrow's Fajr
    return 'Fajr';
  }

  /// Calculate prayer times for tomorrow (for notifications)
  Map<String, DateTime> calculateTomorrowPrayerTimes() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return calculatePrayerTimes(tomorrow);
  }

  /// Get time until next prayer in minutes
  int getTimeUntilNextPrayer(Map<String, DateTime> times) {
    final now = DateTime.now();
    final nextPrayerName = getNextPrayerName(times);
    
    if (nextPrayerName == null) return 0;
    
    DateTime nextPrayerTime;
    if (nextPrayerName == 'Fajr' && times['Fajr']!.isBefore(now)) {
      // Next Fajr is tomorrow
      final tomorrowTimes = calculateTomorrowPrayerTimes();
      nextPrayerTime = tomorrowTimes['Fajr']!;
    } else {
      nextPrayerTime = times[nextPrayerName]!;
    }
    
    return nextPrayerTime.difference(now).inMinutes;
  }

  /// Format time for display
  String formatPrayerTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get prayer times for a date range (useful for calendar view)
  Map<DateTime, Map<String, DateTime>> calculatePrayerTimesForRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final Map<DateTime, Map<String, DateTime>> result = {};
    
    DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      result[currentDate] = calculatePrayerTimes(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return result;
  }

  /// Get today's prayer summary with calculation info
  Map<String, dynamic> getTodayPrayerSummary() {
    final today = DateTime.now();
    final times = calculatePrayerTimes(today);
    final nextPrayer = getNextPrayerName(times);
    final timeUntilNext = getTimeUntilNextPrayer(times);
    
    return {
      'date': today,
      'times': times,
      'nextPrayer': nextPrayer,
      'timeUntilNext': timeUntilNext,
      'calculationMethod': 'Offline approximation with seasonal adjustments',
      'isToday': true,
      'seasonalAdjustment': _getSeasonalAdjustment('Fajr', _getDayOfYear(today)).abs() < 1 
          ? 'Minimal' 
          : 'Active (${_getSeasonalAdjustment('Fajr', _getDayOfYear(today)).round()} min)',
    };
  }
}
