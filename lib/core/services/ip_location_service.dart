import 'dart:convert';
import 'package:http/http.dart' as http;

class IpLocationService {
  Future<({String city, String country})> getCityCountry() async {
    final url = Uri.parse('https://ipapi.co/json/');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception('Failed to resolve IP location');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final city = (data['city'] as String?) ?? 'Cairo';
    final country = (data['country_name'] as String?) ?? 'Egypt';
    return (city: city, country: country);
  }
}


