import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../core/i18n/strings.dart';
import '../core/services/quran_audio_service.dart';
import 'surah_detail_screen.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('quran')),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/quran/surahs.json'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<dynamic> surahs = json.decode(snapshot.data!);
          return ListView.separated(
            itemCount: surahs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final surah = surahs[i];
              final isArabic = s.locale.languageCode == 'ar';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.primaryContainer,
                  child: Text('${surah['number']}'),
                ),
                title: Text(isArabic ? surah['arabicName'] : surah['englishName']),
                subtitle: Text('${surah['verses']} ${s.t('verses')} • ${surah['revelationType'] == 'Meccan' ? s.t('meccan') : s.t('medinan')}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Audio play button
                    IconButton(
                      icon: Icon(
                        Icons.play_circle_outline,
                        color: color.primary,
                        size: 28,
                      ),
                      onPressed: () {
                        // Navigate to surah detail to play ayah-by-ayah
                        final title = isArabic ? surah['arabicName'] as String : surah['englishName'] as String;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SurahDetailScreen(
                              surahNumber: surah['number'] as int,
                              title: title,
                            ),
                          ),
                        );
                      },
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  final title = isArabic ? surah['arabicName'] as String : surah['englishName'] as String;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(
                        surahNumber: surah['number'] as int,
                        title: title,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
