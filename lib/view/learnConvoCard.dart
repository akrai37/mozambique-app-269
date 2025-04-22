import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mozambique_app/model/question.dart';

class LearnConvoCard extends StatefulWidget {
  final String greeting;
  final String response;

  const LearnConvoCard({
    super.key,
    required this.greeting,
    required this.response
  });

  @override
  State<LearnConvoCard> createState() => _LearnConvoCardState();
}

class _LearnConvoCardState extends State<LearnConvoCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _audioPlayer.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
    _audioPlayer.setVolume(1.0); // Set the volume to maximum
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}