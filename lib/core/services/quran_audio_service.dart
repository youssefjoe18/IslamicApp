import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class QuranAudioService {
  static final QuranAudioService _instance = QuranAudioService._internal();
  factory QuranAudioService() => _instance;
  QuranAudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isPlaying = false;
  bool _isPaused = false;
  int? _currentSurah;
  int? _currentAyah;
  List<Map<String, dynamic>> _currentAyahs = [];
  int _currentAyahIndex = 0;
  bool _autoPlayEnabled = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int? get currentSurah => _currentSurah;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  AudioPlayer get audioPlayer => _audioPlayer;

  // Initialize audio service
  Future<void> initialize() async {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.playing;
      _isPaused = state == PlayerState.paused;
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      _currentPosition = position;
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      _totalDuration = duration;
    });
  }

  // Initialize ayah playback for a surah
  Future<bool> initializeAyahPlayback(int surahNumber, List<Map<String, dynamic>> ayahs) async {
    try {
      _currentSurah = surahNumber;
      _currentAyahs = ayahs;
      _currentAyahIndex = 0;
      
      // Set up completion listener for auto-next ayah
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        if (state == PlayerState.completed && _autoPlayEnabled) {
          _playNextAyah();
        }
      });
      
      return true;
    } catch (e) {
      print('❌ Error initializing ayah playback: $e');
      return false;
    }
  }

  // Play specific ayah
  Future<bool> playAyah(int surahNumber, int ayahNumber) async {
    try {
      // Stop any current playback first
      await _audioPlayer.stop();
      
      // Use EveryAyah.com API for individual ayah audio
      final audioUrl = 'https://www.everyayah.com/data/Alafasy_128kbps/${surahNumber.toString().padLeft(3, '0')}${ayahNumber.toString().padLeft(3, '0')}.mp3';
      
      print('🎵 Playing Ayah $ayahNumber of Surah $surahNumber from: $audioUrl');
      
      await _audioPlayer.play(UrlSource(audioUrl));
      _currentSurah = surahNumber;
      _currentAyah = ayahNumber;
      
      print('✅ Successfully started playing ayah');
      return true;
    } catch (e) {
      print('❌ Error playing ayah $ayahNumber of surah $surahNumber: $e');
      
      // Fallback to alternative ayah audio source
      try {
        final fallbackUrl = 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$surahNumber/$ayahNumber.mp3';
        print('🎵 Trying fallback ayah URL: $fallbackUrl');
        await _audioPlayer.play(UrlSource(fallbackUrl));
        _currentSurah = surahNumber;
        _currentAyah = ayahNumber;
        return true;
      } catch (e2) {
        print('❌ Fallback ayah audio also failed: $e2');
        return false;
      }
    }
  }

  // Play current ayah from the list
  Future<bool> playCurrentAyah() async {
    if (_currentAyahs.isEmpty || _currentAyahIndex >= _currentAyahs.length) {
      return false;
    }
    
    final ayah = _currentAyahs[_currentAyahIndex];
    final ayahNumber = ayah['numberInSurah'] as int;
    
    return await playAyah(_currentSurah!, ayahNumber);
  }

  // Play next ayah automatically
  Future<void> _playNextAyah() async {
    if (_currentAyahIndex < _currentAyahs.length - 1) {
      _currentAyahIndex++;
      await playCurrentAyah();
    } else {
      // End of surah
      print('✅ Finished playing all ayahs of surah $_currentSurah');
      await stop();
    }
  }

  // Play previous ayah
  Future<bool> playPreviousAyah() async {
    if (_currentAyahIndex > 0) {
      _currentAyahIndex--;
      return await playCurrentAyah();
    }
    return false;
  }

  // Play next ayah manually (independent of auto-play)
  Future<bool> playNextAyahManually() async {
    if (_currentAyahIndex < _currentAyahs.length - 1) {
      _currentAyahIndex++;
      return await playCurrentAyah();
    }
    return false;
  }

  // Play next ayah manually (for button control)
  Future<bool> playNextAyah() async {
    return await playNextAyahManually();
  }

  // Toggle auto-play mode
  void setAutoPlay(bool enabled) {
    _autoPlayEnabled = enabled;
  }

  // Get current ayah info
  Map<String, dynamic>? getCurrentAyahInfo() {
    if (_currentAyahs.isEmpty || _currentAyahIndex >= _currentAyahs.length) {
      return null;
    }
    return {
      'ayah': _currentAyahs[_currentAyahIndex],
      'index': _currentAyahIndex,
      'total': _currentAyahs.length,
    };
  }

  // Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  // Resume playback
  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  // Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSurah = null;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // Check if audio is available (always true for API)
  Future<bool> hasAudioForSurah(int surahNumber) async {
    return true; // API has all surahs available
  }

  // Get formatted time string
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
