//DART FILE FOR LEFT SIDE MESSAGES WIDGET

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mozambique_app/model/conversation.dart';
import 'package:mozambique_app/services/audio_coordinator.dart';

class Msg1 extends StatefulWidget {
  final ConvoLine line;
  final bool isLast;

  const Msg1({
    super.key,
    required this.line,
    this.isLast = false, 
  });

  @override
  State<Msg1> createState() => _Msg1State();
}

class _Msg1State extends State<Msg1> {
  late ConvoLine _line;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player for question audio
  @override
  void initState() {
    super.initState();

    _line = widget.line;

    if (_audioPlayer.audioCache.prefix != '') { // Clear prefix 
      _audioPlayer.audioCache.prefix = '';
    }

    _audioPlayer.setSourceBytes(_line.audioBytes); // Set the audio source to the byte data
    _audioPlayer.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
    _audioPlayer.setVolume(1.0); // Set the volume to maximum
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: MediaQuery.of(context).size.width / 2 - 15,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECF0F1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: widget.isLast ? Radius.circular(12) : Radius.circular(0),
            bottomRight: widget.isLast ? Radius.circular(12) : Radius.circular(0),
          ),
        ),
        //MESSAGE BOX SETTINGS
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3E50),
              border: Border.all(
                color: const Color(0xFF2D3E50),
                width: 2,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(0), // Tail effect
                bottomRight: Radius.circular(8),
              ),
            ),
            child: InkWell(
              onTap: () {
                AudioCoordinator.play(_audioPlayer);
              },
              child: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Ensures the bubble wraps content
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //MESSAGE TEXT
                    Text(
                      _line.convoText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFECF0F1),
                      ),
                    ),
                    SizedBox(width: 10),
                    //SOUND ICON
                    const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 24,
                    ), // Spacing between text and icon
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    AudioCoordinator.forget(_audioPlayer);
    _audioPlayer.dispose();
    super.dispose();
  }
}