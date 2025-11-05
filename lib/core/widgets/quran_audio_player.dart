import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/quran_audio_service.dart';

class QuranAudioPlayer extends StatefulWidget {
  final String surahName;
  final int surahNumber;

  const QuranAudioPlayer({
    super.key,
    required this.surahName,
    required this.surahNumber,
  });

  @override
  State<QuranAudioPlayer> createState() => _QuranAudioPlayerState();
}

class _QuranAudioPlayerState extends State<QuranAudioPlayer> {
  final QuranAudioService _audioService = QuranAudioService();
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAudioService();
  }

  void _initializeAudioService() {
    _audioService.audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isPaused = state == PlayerState.paused;
        });
      }
    });

    _audioService.audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _audioService.audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.primary, color.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Top row with surah info and controls
            Row(
              children: [
                // Surah info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.surahName,
                        style: TextStyle(
                          color: color.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Surah ${widget.surahNumber}',
                        style: TextStyle(
                          color: color.onPrimary.withOpacity(0.8),
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
                    // Previous button (placeholder)
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: color.onPrimary),
                      onPressed: () {
                        // TODO: Implement previous surah
                      },
                    ),

                    // Play/Pause button
                    IconButton(
                      icon: Icon(
                        _isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: color.onPrimary,
                        size: 32,
                      ),
                      onPressed: () async {
                        if (_isPlaying) {
                          await _audioService.pause();
                        } else if (_isPaused) {
                          await _audioService.resume();
                        } else {
                          await _audioService.playSurah(widget.surahNumber);
                        }
                      },
                    ),

                    // Next button (placeholder)
                    IconButton(
                      icon: Icon(Icons.skip_next, color: color.onPrimary),
                      onPressed: () {
                        // TODO: Implement next surah
                      },
                    ),

                    // Close button
                    IconButton(
                      icon: Icon(Icons.close, color: color.onPrimary),
                      onPressed: () async {
                        await _audioService.stop();
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            // Progress bar
            Expanded(
              child: Row(
                children: [
                  Text(
                    _audioService.formatDuration(_currentPosition),
                    style: TextStyle(
                      color: color.onPrimary.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value:
                          _totalDuration.inMilliseconds > 0
                              ? _currentPosition.inMilliseconds /
                                  _totalDuration.inMilliseconds
                              : 0.0,
                      onChanged: (value) {
                        final position = Duration(
                          milliseconds:
                              (value * _totalDuration.inMilliseconds).round(),
                        );
                        _audioService.seek(position);
                      },
                      activeColor: color.onPrimary,
                      inactiveColor: color.onPrimary.withOpacity(0.3),
                    ),
                  ),
                  Text(
                    _audioService.formatDuration(_totalDuration),
                    style: TextStyle(
                      color: color.onPrimary.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
