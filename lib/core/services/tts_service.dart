import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused }

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  TtsState _ttsState = TtsState.stopped;
  double _speechRate = 0.5; // Default flutter_tts rate
  final double _pitch = 1.0;
  int _currentVerseIndex = 0;
  List<String> _currentVersesText = [];
  void Function(int index)? _onVerseChanged;
  void Function(TtsState state)? _onStateChanged;

  TtsState get state => _ttsState;
  bool get isPlaying => _ttsState == TtsState.playing;
  bool get isPaused => _ttsState == TtsState.paused;
  bool get isStopped => _ttsState == TtsState.stopped;
  double get speechRate => _speechRate;
  int get currentVerseIndex => _currentVerseIndex;

  Future<void> init() async {
    if (_flutterTts != null) return;
    _flutterTts = FlutterTts();

    if (Platform.isIOS) {
      // Without a shared session in the playback category, iOS silences TTS
      // the moment the app leaves the foreground or the screen locks.
      await _flutterTts!.setSharedInstance(true);
      await _flutterTts!.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.allowAirPlay,
        ],
        IosTextToSpeechAudioMode.spokenAudio,
      );
    }

    await _flutterTts!.setLanguage("en-US");
    await _flutterTts!.setSpeechRate(_speechRate);
    await _flutterTts!.setPitch(_pitch);

    _flutterTts!.setCompletionHandler(() {
      _onSpeechCompleted();
    });

    _flutterTts!.setErrorHandler((msg) {
      _updateState(TtsState.stopped);
    });
  }

  void _updateState(TtsState newState) {
    _ttsState = newState;
    _onStateChanged?.call(_ttsState);
  }

  void _onSpeechCompleted() {
    if (_ttsState == TtsState.playing && _currentVerseIndex + 1 < _currentVersesText.length) {
      _currentVerseIndex++;
      _onVerseChanged?.call(_currentVerseIndex);
      _speakCurrentVerse();
    } else {
      _updateState(TtsState.stopped);
      _currentVerseIndex = 0;
    }
  }

  Future<void> speakVerses({
    required List<String> versesText,
    int startIndex = 0,
    void Function(int index)? onVerseChanged,
    void Function(TtsState state)? onStateChanged,
  }) async {
    await init();
    if (versesText.isEmpty) return;

    _currentVersesText = versesText;
    _currentVerseIndex = (startIndex >= 0 && startIndex < versesText.length) ? startIndex : 0;
    _onVerseChanged = onVerseChanged;
    _onStateChanged = onStateChanged;

    _onVerseChanged?.call(_currentVerseIndex);
    _updateState(TtsState.playing);
    await _speakCurrentVerse();
  }

  Future<void> _speakCurrentVerse() async {
    if (_flutterTts == null || _currentVerseIndex >= _currentVersesText.length) return;
    final text = _currentVersesText[_currentVerseIndex];
    if (text.trim().isEmpty) {
      _onSpeechCompleted();
      return;
    }
    await _flutterTts!.speak(text);
  }

  Future<void> pause() async {
    if (_flutterTts != null && _ttsState == TtsState.playing) {
      await _flutterTts!.pause();
      _updateState(TtsState.paused);
    }
  }

  Future<void> resume() async {
    if (_flutterTts != null && _ttsState == TtsState.paused) {
      _updateState(TtsState.playing);
      await _speakCurrentVerse();
    }
  }

  Future<void> stop() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
      _updateState(TtsState.stopped);
      _currentVerseIndex = 0;
    }
  }

  Future<void> setRate(double rate) async {
    _speechRate = rate;
    if (_flutterTts != null) {
      await _flutterTts!.setSpeechRate(rate);
    }
  }

  void dispose() {
    stop();
  }
}
