import 'package:audio_service/audio_service.dart';

import 'tts_service.dart';

/// Bridges chapter playback to the OS media session.
///
/// Without this the TTS engine stops as soon as the app is backgrounded and
/// there is nothing on the lock screen to control it. Registering a handler
/// gives us a playback foreground service on Android, an active audio session
/// on iOS, and hardware/headset media buttons on both.
class BibleAudioHandler extends BaseAudioHandler {
  final TtsService _tts = TtsService();

  List<String> _verses = const [];
  String _reference = '';
  String _version = '';
  int _index = 0;

  /// Fired when playback moves to a different verse, so the reader can
  /// highlight and scroll to it.
  void Function(int index)? onVerseChanged;

  /// Fired on every play/pause/stop transition.
  void Function(TtsState state)? onStateChanged;

  int get currentIndex => _index;

  /// Loads a chapter without starting playback.
  void setChapter({
    required List<String> verses,
    required String reference,
    required String version,
  }) {
    _verses = verses;
    _reference = reference;
    _version = version;
    _publishMediaItem();
  }

  Future<void> startFrom(int index) async {
    if (_verses.isEmpty) return;
    _index = index.clamp(0, _verses.length - 1);
    await _tts.speakVerses(
      versesText: _verses,
      startIndex: _index,
      onVerseChanged: (i) {
        _index = i;
        _publishMediaItem();
        _publishState();
        onVerseChanged?.call(i);
      },
      onStateChanged: (state) {
        _publishState();
        onStateChanged?.call(state);
      },
    );
    _publishState();
  }

  @override
  Future<void> play() async {
    if (_tts.isPaused) {
      await _tts.resume();
    } else if (!_tts.isPlaying) {
      await startFrom(_index);
    }
    _publishState();
  }

  @override
  Future<void> pause() async {
    await _tts.pause();
    _publishState();
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _index = 0;
    _publishState();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    if (_index + 1 >= _verses.length) return stop();
    await _tts.stop();
    await startFrom(_index + 1);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_index <= 0) return;
    await _tts.stop();
    await startFrom(_index - 1);
  }

  @override
  Future<void> seek(Duration position) async {
    // Verse-indexed rather than time-indexed: map the scrubber onto verses so
    // dragging still lands somewhere sensible.
    if (_verses.isEmpty) return;
    final target = position.inSeconds.clamp(0, _verses.length - 1);
    if (target == _index) return;
    await _tts.stop();
    await startFrom(target);
  }

  void _publishMediaItem() {
    if (_verses.isEmpty) return;
    mediaItem.add(MediaItem(
      id: '$_reference#$_index',
      title: _reference,
      artist: _version.toUpperCase(),
      album: 'Offline Bible',
      // One "second" per verse: audio_service needs a duration to render a
      // progress bar, and verse count is the only meaningful axis we have.
      duration: Duration(seconds: _verses.length),
    ));
  }

  void _publishState() {
    final playing = _tts.isPlaying;
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _tts.isStopped
          ? AudioProcessingState.idle
          : AudioProcessingState.ready,
      playing: playing,
      updatePosition: Duration(seconds: _index),
      queueIndex: _index,
    ));
  }
}
