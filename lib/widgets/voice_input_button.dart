import 'package:flutter/material.dart';
import '../services/speech_service.dart';

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
    final started = await SpeechService.instance.toggleListening(
      widget.controller,
      onListeningChanged: (listening) {
        if (mounted) {
          setState(() => _listening = listening);
        }
      },
    );

    if (!mounted) return;

    if (!started && !SpeechService.instance.isListeningTo(widget.controller)) {
      final reason = SpeechService.instance.lastFailure;
      if (reason != SpeechFailureReason.none) {
        final message = SpeechService.instance.failureMessage(reason);
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
    return IconButton(
      icon: Icon(
        _listening ? Icons.mic : Icons.mic_none,
        color: _listening ? Colors.red : Colors.grey.shade700,
      ),
      tooltip: _listening ? 'Stop voice input' : 'Voice input',
      onPressed: _toggle,
    );
  }
}
