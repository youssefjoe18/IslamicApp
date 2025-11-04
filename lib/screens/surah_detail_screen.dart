import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/services/quran_api_service.dart';
import '../core/services/quran_audio_service.dart';
import '../core/widgets/bottom_audio_player.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String title;

  const SurahDetailScreen({super.key, required this.surahNumber, required this.title});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranAudioService _audioService = QuranAudioService();
  bool _isPlaying = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
    _initializeAudio();
    _setupAudioListener();
  }

  void _setupAudioListener() {
    _audioService.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isPaused = state == PlayerState.paused;
        });
      }
    });
  }

  void _initializeAudio() async {
    // Get ayahs data and initialize audio
    final api = QuranApiService();
    try {
      final ayahs = await api.fetchSurahWithArabicAndEnglish(widget.surahNumber);
      await _audioService.initializeAyahPlayback(widget.surahNumber, ayahs);
    } catch (e) {
      print('Error initializing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final api = QuranApiService();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        actions: [
          // Play/Pause button
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline),
            onPressed: () async {
              if (_isPlaying) {
                await _audioService.pause();
              } else if (_isPaused) {
                await _audioService.resume();
              } else {
                await _audioService.playCurrentAyah();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content with padding at bottom for audio player
          Positioned.fill(
            child: SafeArea(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: api.fetchSurahWithArabicAndEnglish(widget.surahNumber),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    return const Center(child: CircularProgressIndicator());
                  }
                  final ayahs = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: 8.0,
                      bottom: 90.0, // Space for fixed audio player (80px + 10px margin)
                    ),
                    itemCount: ayahs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final a = ayahs[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title: Text(
                            a['arabic'] as String,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(fontSize: 18),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(a['english'] as String),
                          ),
                          leading: CircleAvatar(
                            child: Text('${a['numberInSurah']}'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          
          // Simple fixed bottom audio player - always visible
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Surah info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'السورة ${widget.surahNumber}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Audio controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.skip_previous, color: Colors.grey[600]),
                            onPressed: () async => await _audioService.playPreviousAyah(),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                if (_isPlaying) {
                                  await _audioService.pause();
                                } else if (_isPaused) {
                                  await _audioService.resume();
                                } else {
                                  await _audioService.playCurrentAyah();
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next, color: Colors.grey[600]),
                            onPressed: () async => await _audioService.playNextAyah(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


