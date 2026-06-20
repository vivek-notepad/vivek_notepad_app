import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'voice_usage_service.dart';

typedef SpeechListeningCallback = void Function(bool isListening);
typedef SpeechLimitCallback = void Function();

enum SpeechFailureReason {
  none,
  permissionDenied,
  permissionPermanentlyDenied,
  notAvailable,
  dailyLimitReached,
}

class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  TextEditingController? _activeController;
  SpeechListeningCallback? _listeningCallback;
  String _textPrefix = '';
  SpeechFailureReason _lastFailure = SpeechFailureReason.none;
  SpeechLimitCallback? _limitCallback;

  bool get isAvailable => _initialized;
  SpeechFailureReason get lastFailure => _lastFailure;

  bool isListeningTo(TextEditingController controller) {
    return _speech.isListening && identical(_activeController, controller);
  }

  Future<bool> ensureInitialized() async {
    if (_initialized) return true;
    _lastFailure = SpeechFailureReason.none;

    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      _lastFailure = micStatus.isPermanentlyDenied
          ? SpeechFailureReason.permissionPermanentlyDenied
          : SpeechFailureReason.permissionDenied;
      return false;
    }

    try {
      _initialized = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        options: [SpeechToText.androidNoBluetooth],
      );
    } catch (e) {
      debugPrint('Speech init failed: $e');
      _initialized = false;
    }

    if (!_initialized) {
      _lastFailure = SpeechFailureReason.notAvailable;
    }
    return _initialized;
  }

  Future<bool> toggleListening(
    TextEditingController controller, {
    SpeechListeningCallback? onListeningChanged,
    SpeechLimitCallback? onDailyLimitReached,
  }) async {
    if (isListeningTo(controller)) {
      await stopAny();
      return false;
    }

    if (!await ensureInitialized()) {
      return false;
    }

    if (!await VoiceUsageService.instance.canStartVoiceInput()) {
      _lastFailure = SpeechFailureReason.dailyLimitReached;
      return false;
    }

    await stopAny();

    _activeController = controller;
    _listeningCallback = onListeningChanged;
    _limitCallback = onDailyLimitReached;
    _textPrefix = _prefixFor(controller.text);

    try {
      final locale = await _preferredLocale();
      await _speech.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          localeId: locale,
        ),
      );
      _notifyListening(true);
      return true;
    } catch (e) {
      debugPrint('Speech listen failed: $e');
      await stopAny();
      _lastFailure = SpeechFailureReason.notAvailable;
      return false;
    }
  }

  Future<void> stopAny() async {
    if (_speech.isListening) {
      try {
        await _speech.stop();
      } catch (e) {
        debugPrint('Speech stop failed: $e');
      }
    }
    _activeController = null;
    _listeningCallback = null;
    _limitCallback = null;
    _textPrefix = '';
    _notifyListening(false);
  }

  String failureMessage(SpeechFailureReason reason) {
    switch (reason) {
      case SpeechFailureReason.permissionDenied:
        return 'Microphone permission is required for voice input.';
      case SpeechFailureReason.permissionPermanentlyDenied:
        return 'Microphone permission denied. Enable it in app settings.';
      case SpeechFailureReason.notAvailable:
        return 'Voice input is not available on this device.';
      case SpeechFailureReason.dailyLimitReached:
        return 'Daily voice input limit reached.';
      case SpeechFailureReason.none:
        return '';
    }
  }

  String _prefixFor(String currentText) {
    if (currentText.isEmpty) return '';
    return currentText.endsWith(' ') ? currentText : '$currentText ';
  }

  Future<String?> _preferredLocale() async {
    final locales = await _speech.locales();
    if (locales.isEmpty) return null;

    for (final locale in locales) {
      if (locale.localeId.startsWith('en')) {
        return locale.localeId;
      }
    }
    return locales.first.localeId;
  }

  void _onResult(SpeechRecognitionResult result) {
    final controller = _activeController;
    if (controller == null) return;

    var words = result.recognizedWords.trim();
    if (words.isEmpty) return;

    if (result.finalResult) {
      _applyFinalResult(controller, words);
      return;
    }

    final combined = '$_textPrefix$words'.trimLeft();
    controller.value = TextEditingValue(
      text: combined,
      selection: TextSelection.collapsed(offset: combined.length),
    );
  }

  Future<void> _applyFinalResult(
    TextEditingController controller,
    String words,
  ) async {
    final remaining = await VoiceUsageService.instance.getRemainingWords();
    if (remaining <= 0) {
      await _stopForDailyLimit();
      return;
    }

    final utteranceCount = VoiceUsageService.countWords(words);
    if (utteranceCount > remaining) {
      words = VoiceUsageService.truncateToWordCount(words, remaining);
    }

    final recorded = VoiceUsageService.countWords(words);
    if (recorded <= 0) {
      await _stopForDailyLimit();
      return;
    }

    await VoiceUsageService.instance.recordWords(recorded);

    final combined = '$_textPrefix$words'.trimLeft();
    controller.value = TextEditingValue(
      text: combined,
      selection: TextSelection.collapsed(offset: combined.length),
    );
    _textPrefix = _prefixFor(combined);

    if (await VoiceUsageService.instance.getRemainingWords() <= 0) {
      await _stopForDailyLimit();
    }
  }

  Future<void> _stopForDailyLimit() async {
    _lastFailure = SpeechFailureReason.dailyLimitReached;
    final callback = _limitCallback;
    await stopAny();
    callback?.call();
  }

  void _onError(SpeechRecognitionError error) {
    if (error.errorMsg == 'error_no_match') {
      _notifyListening(false);
      return;
    }
    debugPrint('Speech error: ${error.errorMsg} permanent=${error.permanent}');
    if (error.permanent) {
      _initialized = false;
      _lastFailure = SpeechFailureReason.notAvailable;
    }
    stopAny();
  }

  void _onStatus(String status) {
    if (status == 'notListening' || status == 'done') {
      _notifyListening(false);
    }
  }

  void _notifyListening(bool listening) {
    _listeningCallback?.call(listening);
  }
}
