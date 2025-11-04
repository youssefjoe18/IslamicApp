import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../core/services/location_service.dart';
import '../core/services/prayer_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _location = LocationService();
  final _prayer = PrayerService();
  Map<String, DateTime> _times = {};
  String? _error;
  bool _loading = false;
  String? _hijriDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final pos = await _location.getCurrentPosition();
      final t = await _prayer.getPrayerTimes(latitude: pos.latitude, longitude: pos.longitude);
      
      // Use Aladhan API for accurate Hijri date (same as We Muslim app)
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final hijriUrl = 'http://api.aladhan.com/v1/gToH/$dateStr';
      
      final hijriResponse = await http.get(Uri.parse(hijriUrl)).timeout(const Duration(seconds: 10));
      if (hijriResponse.statusCode == 200) {
        final hijriData = json.decode(hijriResponse.body);
        final hijri = hijriData['data']['hijri'];
        _hijriDate = '${hijri['day']} ${hijri['month']['ar']} ${hijri['year']}';
      } else {
        _hijriDate = 'التاريخ الهجري غير متوفر';
      }
      
      setState(() { _times = t; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final gDate = DateFormat.yMMMMEEEEd().format(today);
    return Scaffold(
      appBar: AppBar(title: const Text('Islamic Calendar'), backgroundColor: color.primary, foregroundColor: color.onPrimary),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gDate, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      if (_hijriDate != null) Text('Hijri: $_hijriDate', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Prayer Times', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ..._times.entries.map((e) {
                        final t = TimeOfDay.fromDateTime(e.value);
                        return ListTile(
                          title: Text(e.key),
                          trailing: Text('${t.hourOfPeriod.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}'),
                        );
                      }),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(onPressed: _load, child: const Icon(Icons.refresh)),
    );
  }
}


