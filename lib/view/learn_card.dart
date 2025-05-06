import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:mozambique_app/model/vocab.dart';

class LearnCard extends StatefulWidget {
  final VocabWord imageButton;

  const LearnCard({
    super.key,
    required this.imageButton,
  });

  @override
  State<LearnCard> createState() => _LearnCardState();
}

class _LearnCardState extends State<LearnCard> {
  late VocabWord _imageButton;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _imageButton = widget.imageButton;

    if (_audioPlayer.audioCache.prefix != '') { // Clear prefix 
      _audioPlayer.audioCache.prefix = '';
    }

    _audioPlayer.setSourceBytes(_imageButton.audioBytes); // Set the audio source to the byte data
    _audioPlayer.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
    _audioPlayer.setVolume(1.0); // Set the volume to maximum
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: 400,
      child: Material(
        color: const Color(0xFFECF0F1),
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          onTap: () {
            _audioPlayer.resume(); // Play the audio when the card is tapped
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _imageButton.imageBytes.isNotEmpty
                        ? Image.memory(
                            _imageButton.imageBytes,
                            height: 267,
                            width: 267,
                          )
                        : const Icon(
                            Icons.error,
                            size: 267,
                          ),
                    ),
                    Text(
                      _imageButton.portuguese,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
                  
              // Speaker Icon
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2D3E50),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();

    super.dispose();
  }
}