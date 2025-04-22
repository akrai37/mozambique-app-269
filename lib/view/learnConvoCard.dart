import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mozambique_app/model/question.dart';

class LearnConvoCard extends StatefulWidget {
  final String greeting;
  final String response;
  final Uint8List qaudio;
  final Uint8List raudio;

  const LearnConvoCard({
    super.key,
    required this.greeting,
    required this.response,
    required this.qaudio,
    required this.raudio
  });

  @override
  State<LearnConvoCard> createState() => _LearnConvoCardState();
}

class _LearnConvoCardState extends State<LearnConvoCard> {
  final AudioPlayer _qaudioPlayer = AudioPlayer();
  final AudioPlayer _raudioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _qaudioPlayer.setSourceBytes(widget.qaudio); // Set the audio source to the byte data
    _qaudioPlayer.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
    _qaudioPlayer.setVolume(1.0); // Set the volume to maximum
    _raudioPlayer.setSourceBytes(widget.raudio); // Set the audio source to the byte data
    _raudioPlayer.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
    _raudioPlayer.setVolume(1.0); // Set the volume to maximum
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      width: MediaQuery.of(context).size.width / 2 - 15,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color(0xFFECF0F1),
        ),
        child: Column(
          children: [
            SizedBox(height: 40),
            Container(
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
                    _qaudioPlayer.resume(); // Play the audio when the card is tapped
                  },
                  child: FittedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Ensures the bubble wraps content
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            widget.greeting,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFECF0F1),
                            ),
                          ),
                        SizedBox(width: 10), // Spacing between text and icon
                        // Speaker Icon
                        Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF2D3E50),
                              ),
                              padding: const EdgeInsets.all(5),
                              child: const Icon(
                                Icons.volume_up,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 15),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF969FA7),
                  border: Border.all(
                    color: const Color(0xFF969FA7),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8), // Tail effect
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    _raudioPlayer.resume(); // Play the audio when the card is tapped
                  },
                  child: FittedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Ensures the bubble wraps content
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            widget.response,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3E50),
                            ),
                          ),
                        SizedBox(width: 5), // Spacing between text and icon
                        // Speaker Icon
                          Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF969FA7),
                              ),
                              padding: const EdgeInsets.all(5),
                              child: const Icon(
                                Icons.volume_up,
                                color: Color(0xFF2D3E50),
                                size: 24,
                              ),
                            )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _qaudioPlayer.dispose();
    _raudioPlayer.dispose();

    super.dispose();
  }
}