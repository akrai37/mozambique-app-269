import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:mozambique_app/model/image_button.dart';

class LearnCard extends StatefulWidget {
  final ImageButton imageButton;

  const LearnCard({
    super.key,
    required this.imageButton,
  });

  @override
  State<LearnCard> createState() => _LearnCardState();
}

class _LearnCardState extends State<LearnCard> {
  late ImageButton _imageButton;
  late String _img;
  late String _title;
  late String _audio;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _imageButton = widget.imageButton;
    _img = _imageButton.img;
    _title = _imageButton.word;
    _audio = _imageButton.audio;

    if (_audioPlayer.audioCache.prefix != '') { // Clear prefix 
      _audioPlayer.audioCache.prefix = '';
    }

    _audioPlayer.setSource(AssetSource(_audio)); // Set the audio source
    _audioPlayer.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
    _audioPlayer.setVolume(1.0); // Set the volume to maximum
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: InkWell(
        onTap: () {
          _audioPlayer.resume(); // Play the audio when the card is tapped
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color(0xFFECF0F1),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage(_img),
                        width: 200,
                        height: 200,
                      ),
                    ),
                    Text(
                      _title,
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
                    color: Colors.black.withValues( alpha: 0.3),
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