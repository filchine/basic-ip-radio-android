import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../models/radio_station.dart';
import '../services/audio_handler.dart';

class PlayerProvider extends ChangeNotifier {
  AudioHandler? _audioHandler;
  RadioStation? _currentStation;
  List<RadioStation> _playlist = [];
  bool _isPlaying = false;
  String? _errorMessage;

  PlayerProvider() {
    _init();
  }

  RadioStation? get currentStation => _currentStation;
  bool get isPlaying => _isPlaying;
  String? get errorMessage => _errorMessage;
  Stream<String?> get errorStream => _audioHandler?.playbackState.map((s) => s.errorMessage).distinct() ?? const Stream.empty();
  bool get hasNext => _playlist.isNotEmpty && _currentIndex < _playlist.length - 1;
  bool get hasPrevious => _playlist.isNotEmpty && _currentIndex > 0;

  int get _currentIndex => _currentStation != null ? _playlist.indexOf(_currentStation!) : -1;

  Future<void> _init() async {
    _audioHandler = await initAudioService();
    _audioHandler!.playbackState.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioHandler!.mediaItem.listen((item) {
      if (item != null && _playlist.isNotEmpty) {
        final station = _playlist.firstWhere(
          (s) => s.streamUrl == item.id,
          orElse: () => _currentStation ?? _playlist[0],
        );
        _currentStation = station;
        notifyListeners();
      }
    });
  }

  Future<void> playStation(RadioStation station, List<RadioStation> playlist) async {
    _currentStation = station;
    _playlist = playlist;
    notifyListeners();

    final mediaItems = playlist.map((s) => MediaItem(
      id: s.streamUrl,
      album: "IP Radio",
      title: s.name,
      artUri: s.imageUrl.isNotEmpty ? Uri.parse(s.imageUrl) : null,
    )).toList();

    await _audioHandler?.updateQueue(mediaItems);

    final mediaItem = MediaItem(
      id: station.streamUrl,
      album: "IP Radio",
      title: station.name,
      artUri: station.imageUrl.isNotEmpty ? Uri.parse(station.imageUrl) : null,
    );

    await _audioHandler?.playMediaItem(mediaItem);
  }

  Future<void> next() async {
    await _audioHandler?.skipToNext();
  }

  Future<void> previous() async {
    await _audioHandler?.skipToPrevious();
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _audioHandler?.pause();
    } else {
      await _audioHandler?.play();
    }
  }

  Future<void> stop() async {
    await _audioHandler?.stop();
    _currentStation = null;
    notifyListeners();
  }
}
