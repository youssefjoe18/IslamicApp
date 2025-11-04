import 'dart:convert';
import 'package:http/http.dart' as http;

class AladhanApiService {
  Future<List<Map<String, dynamic>>> getCalendarByCity({
    required String city,
    required String country,
    required int year,
    required int month,
  }) async {
    final url = Uri.parse('https://api.aladhan.com/v1/calendarByCity/$year/$month?city=${Uri.encodeComponent(city)}&country=${Uri.encodeComponent(country)}&month=$month&year=$year');
    final resp = await http.get(url);
    if (resp.statusCode != 200) throw Exception('Failed to fetch calendar');
    final data = json.decode(resp.body) as Map<String, dynamic>;
    if (data['code'] != 200) throw Exception('Calendar API error');
    return (data['data'] as List).cast<Map<String, dynamic>>();
  }
}


