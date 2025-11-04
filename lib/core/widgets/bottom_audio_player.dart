import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/quran_audio_service.dart';

class BottomAudioPlayer extends StatefulWidget {
  final String surahName;
  final int surahNumber;
  final VoidCallback? onClose;
  
  const BottomAudioPlayer({
    super.key,
    required this.surahName,
    required this.surahNumber,
    this.onClose,
  });

  @override
  State<BottomAudioPlayer> createState() => _BottomAudioPlayerState();
}

class _BottomAudioPlayerState extends State<BottomAudioPlayer> {
  final QuranAudioService _audioService = QuranAudioService();
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackSpeed = 1.0;

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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Top row with surah info
            Row(
              children: [
                // Close button
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  onPressed: () async {
                    await _audioService.stop();
                    widget.onClose?.call();
                  },
                ),
                
                // Surah info
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        widget.surahName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      StreamBuilder<Map<String, dynamic>?>(
                        stream: Stream.periodic(const Duration(milliseconds: 500), (_) => _audioService.getCurrentAyahInfo()),
                        builder: (context, snapshot) {
                          final ayahInfo = snapshot.data;
                          if (ayahInfo != null) {
                            return Text(
                              'آية ${ayahInfo['index'] + 1} من ${ayahInfo['total']} - السورة ${widget.surahNumber}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }
                          return Text(
                            'السورة ${widget.surahNumber}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Manual next ayah button
                IconButton(
                  icon: Icon(
                    Icons.skip_next_outlined,
                    color: color.primary,
                    size: 18,
                  ),
                  onPressed: () async {
                    await _audioService.playNextAyahManually();
                  },
                  tooltip: 'Next Ayah',
                ),
                
                // Speed control - simplified
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 2),
            
            // Audio controls row - simplified like the image
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                    color: Colors.grey[600],
                    size: 28,
                  ),
                  onPressed: () async {
                    await _audioService.playPreviousAyah();
                  },
                ),
                
                const SizedBox(width: 12),
                
                // Play/Pause button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 26,
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
                
                const SizedBox(width: 12),
                
                // Next button
                IconButton(
                  icon: Icon(
                    Icons.skip_next,
                    color: Colors.grey[600],
                    size: 28,
                  ),
                  onPressed: () async {
                    await _audioService.playNextAyah();
                  },
                ),
              ],
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
