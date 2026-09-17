import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../domain/services/voice_command_parser.dart';

/// Flutter-native replacement for the old app's in-browser
/// `webkitSpeechRecognition` voice entry — uses the OS speech service via
/// `speech_to_text` instead of a browser API, but the matching intent is the
/// same: fuzzy-match a spoken phrase to a sub-title row and fill its amount.
class VoiceEntryButton extends StatefulWidget {
  final List<VoiceMatchRow> rows;
  final void Function(VoiceEntryCommand command) onCommand;

  const VoiceEntryButton({super.key, required this.rows, required this.onCommand});

  @override
  State<VoiceEntryButton> createState() => _VoiceEntryButtonState();
}

class _VoiceEntryButtonState extends State<VoiceEntryButton> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _listening = false;

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && mounted) {
          setState(() => _listening = false);
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _listening = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voice entry error: ${error.errorMsg}')));
      },
    );
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Speech recognition is not available.')));
      }
      return;
    }

    setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        if (!result.finalResult) return;
        final command = VoiceCommandParser.parse(result.recognizedWords, widget.rows);
        if (command != null) {
          widget.onCommand(command);
        } else if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Could not match: "${result.recognizedWords}"')));
        }
        setState(() => _listening = false);
      },
      listenOptions: stt.SpeechListenOptions(listenFor: const Duration(seconds: 15), pauseFor: const Duration(seconds: 3)),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_listening ? Icons.mic : Icons.mic_none),
      color: _listening ? Theme.of(context).colorScheme.error : null,
      tooltip: 'Voice entry (e.g. "Deposit credit 100 <sub-title name>")',
      onPressed: _toggleListening,
    );
  }
}
