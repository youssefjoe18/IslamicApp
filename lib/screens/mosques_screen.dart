import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  Position? _pos;
  String? _error;
  List<_Place> _mosques = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final mosques = await _queryOverpass(p.latitude, p.longitude);
      setState(() { _pos = p; _mosques = mosques; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<List<_Place>> _queryOverpass(double lat, double lon) async {
    final bbox = '${lat-0.05},${lon-0.05},${lat+0.05},${lon+0.05}';
    final query = '[out:json];node[amenity=place_of_worship][religion=muslim]($bbox);out;';
    final url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');
    
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) throw Exception('Network error');
      
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final elements = (data['elements'] as List).cast<Map<String, dynamic>>();
      
      return elements.map((e) {
        final tags = (e['tags'] as Map<String, dynamic>?) ?? {};
        final name = tags['name'] as String? ?? 
                    tags['name:ar'] as String? ?? 
                    'مسجد';
        final plat = (e['lat'] as num).toDouble();
        final plon = (e['lon'] as num).toDouble();
        final dist = Geolocator.distanceBetween(lat, lon, plat, plon);
        final address = tags['addr:street'] as String? ?? '';
        
        return _Place(name, plat, plon, dist, address);
      }).toList()
        ..sort((a, b) => a.distance.compareTo(b.distance));
        
    } catch (e) {
      throw Exception('Failed to load mosques: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('المساجد القريبة'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري البحث عن المساجد القريبة...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: color.error),
                        const SizedBox(height: 16),
                        Text(
                          'خطأ في تحميل المساجد',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : _mosques.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mosque, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('لم يتم العثور على مساجد قريبة'),
                          SizedBox(height: 8),
                          Text('جرب توسيع نطاق البحث'),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: color.primaryContainer,
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: color.primary),
                              const SizedBox(width: 8),
                              Text(
                                'تم العثور على ${_mosques.length} مسجد',
                                style: TextStyle(
                                  color: color.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _mosques.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final m = _mosques[i];
                              return ListTile(
                                leading: const Icon(Icons.mosque),
                                title: Text(m.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${(m.distance/1000).toStringAsFixed(2)} كم'),
                                    if (m.address.isNotEmpty) Text(m.address, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        tooltip: 'تحديث',
        child: const Icon(Icons.refresh),
      ),
    );
  }

}

class _Place {
  final String name;
  final double lat;
  final double lon;
  final double distance;
  final String address;
  
  _Place(this.name, this.lat, this.lon, this.distance, this.address);
}


