import 'dart:convert';
import 'package:http/http.dart' as http;

class QuranApiService {
  final String base = 'https://api.alquran.cloud/v1';

  Future<List<Map<String, dynamic>>> fetchSurahWithArabicAndEnglish(int surahNumber) async {
    final url = Uri.parse('$base/surah/$surahNumber/editions/quran-uthmani,en.asad');
    final resp = await http.get(url);
    if (resp.statusCode != 200) {
      throw Exception('Failed to load surah');
    }
    final jsonBody = json.decode(resp.body) as Map<String, dynamic>;
    final data = jsonBody['data'] as List<dynamic>;
    if (data.length < 2) throw Exception('Unexpected API response');
    final arabic = data[0]['ayahs'] as List<dynamic>;
    final english = data[1]['ayahs'] as List<dynamic>;
    final int len = arabic.length;
    final List<Map<String, dynamic>> merged = [];
    for (int i = 0; i < len; i++) {
      merged.add({
        'numberInSurah': arabic[i]['numberInSurah'],
        'arabic': arabic[i]['text'],
        'english': english[i]['text'],
      });
    }
    return merged;
  }
}


