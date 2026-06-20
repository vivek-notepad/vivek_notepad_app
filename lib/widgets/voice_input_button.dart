import 'package:flutter/material.dart';
import 'package:simple_notepad/l10n/app_localizations.dart';
import '../services/speech_service.dart';
import '../services/voice_usage_service.dart';

class VoiceInputButton extends StatefulWidget {
  final TextEditingController controller;

  const VoiceInputButton({
    super.key,
    required this.controller,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  bool _listening = false;

  @override
  void dispose() {
    if (SpeechService.instance.isListeningTo(widget.controller)) {
      SpeechService.instance.stopAny();
    }
    super.dispose();
  }

  Future<void> _toggle() async {
    final l10n = AppLocalizations.of(context)!;
    final started = await SpeechService.instance.toggleListening(
      widget.controller,
      onListeningChanged: (listening) {
        if (mounted) {
          setState(() => _listening = listening);
        }
      },
      onDailyLimitReached: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.voiceDailyLimitReached(VoiceUsageService.dailyWordLimit),
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    if (!started && !SpeechService.instance.isListeningTo(widget.controller)) {
      final reason = SpeechService.instance.lastFailure;
      if (reason != SpeechFailureReason.none) {
        final message = switch (reason) {
          SpeechFailureReason.permissionDenied => l10n.micPermissionRequired,
          SpeechFailureReason.permissionPermanentlyDenied =>
            l10n.micPermissionDeniedSettings,
          SpeechFailureReason.notAvailable => l10n.voiceInputNotAvailable,
          SpeechFailureReason.dailyLimitReached =>
            l10n.voiceDailyLimitReached(VoiceUsageService.dailyWordLimit),
          SpeechFailureReason.none => '',
        };
        if (message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: Icon(
        _listening ? Icons.mic : Icons.mic_none,
        color: _listening ? Colors.red : Colors.grey.shade700,
      ),
      tooltip: _listening ? l10n.stopVoiceInput : l10n.voiceInput,
      onPressed: _toggle,
    );
  }
}
