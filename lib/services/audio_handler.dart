import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.ip_radio_app.channel.audio',
      androidNotificationChannelName: 'IP Radio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationClickStartsActivity: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    // Listen to playback events and player state changes to broadcast the current state
    _player.playbackEventStream.listen((_) => _broadcastState(), onError: (Object e, StackTrace st) {
      _broadcastState(error: e.toString());
    });
    _player.playerStateStream.listen((_) => _broadcastState());
  }

  void _broadcastState({String? error}) {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.playPause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.stop,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: error != null 
          ? AudioProcessingState.error 
          : const {
              ProcessingState.idle: AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[_player.processingState] ?? AudioProcessingState.idle,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      errorMessage: error,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() async {
    final curr = mediaItem.value;
    final q = queue.value;
    if (curr == null || q.isEmpty) return;
    final index = q.indexOf(curr);
    if (index >= 0 && index < q.length - 1) {
      await playMediaItem(q[index + 1]);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final curr = mediaItem.value;
    final q = queue.value;
    if (curr == null || q.isEmpty) return;
    final index = q.indexOf(curr);
    if (index > 0) {
      await playMediaItem(q[index - 1]);
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    queue.add(newQueue);
  }

  @override
  Future<void> playMediaItem(MediaItem item) async {
    mediaItem.add(item);
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(item.id)));
      _player.play();
    } catch (e) {
      print("Error loading audio: $e");
      _broadcastState(error: e.toString());
    }
  }
}
