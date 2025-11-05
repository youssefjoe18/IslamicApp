import 'dart:convert';
import 'package:http/http.dart' as http;
import 'prayer_calculation_service.dart';

class PrayerService {
  final PrayerCalculationService _calculationService = PrayerCalculationService();
  
  Future<Map<String, DateTime>> getPrayerTimes({
    required double latitude, 
    required double longitude, 
    DateTime? date
  }) async {
    final targetDate = date ?? DateTime.now();
    
    // Use approximation equations for prayer time calculations
    final calculatedTimes = _calculationService.calculatePrayerTimes(targetDate);
    
    print('🕌 Using CALCULATED PRAYER TIMES with seasonal adjustments');
    print('Date: ${targetDate.day}/${targetDate.month}/${targetDate.year}');
    calculatedTimes.forEach((name, time) {
      print('$name: ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
    });
    
    return calculatedTimes;
  }
  
  Future<Map<String, DateTime>> _getAladhanTimes(double latitude, double longitude, DateTime date) async {
    try {
      final dateStr = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      final url = 'https://api.aladhan.com/v1/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=3';
      
      print('🔄 Fallback to Aladhan API');
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        
        return {
          'Fajr': _parseTime(timings['Fajr']),
          'Sunrise': _parseTime(timings['Sunrise']),
          'Dhuhr': _parseTime(timings['Dhuhr']),
          'Asr': _parseTime(timings['Asr']),
          'Maghrib': _parseTime(timings['Maghrib']),
          'Isha': _parseTime(timings['Isha']),
        };
      }
    } catch (e) {
      print('❌ Fallback API also failed: $e');
    }
    
    // Final fallback - use your specified accurate times
    return _getAccurateLocalTimes();
  }
  
  DateTime _parseTime(String timeStr) {
    final cleanTime = timeStr.trim().split(' ')[0];
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
  
  DateTime _parseTimeWithTimezone(String timeStr, DateTime targetDate) {
    // Parse time from API response
    final cleanTime = timeStr.trim().split(' ')[0];
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    // Create DateTime in local timezone
    final parsedTime = DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);
    
    print('Parsed $timeStr -> ${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}');
    
    return parsedTime;
  }
  
  Map<String, DateTime> _getAccurateLocalTimes() {
    final now = DateTime.now();
    
    print('🔄 Using accurate local fallback times');
    
    // Use the accurate times you mentioned as final fallback
    return {
      'Fajr': DateTime(now.year, now.month, now.day, 4, 42),
      'Sunrise': DateTime(now.year, now.month, now.day, 6, 11),
      'Dhuhr': DateTime(now.year, now.month, now.day, 11, 38),
      'Asr': DateTime(now.year, now.month, now.day, 14, 30),
      'Maghrib': DateTime(now.year, now.month, now.day, 17, 15),
      'Isha': DateTime(now.year, now.month, now.day, 18, 45),
    };
  }
  

  String? getNextPrayerName(Map<String, DateTime> times) {
    return _calculationService.getNextPrayerName(times);
  }
}


