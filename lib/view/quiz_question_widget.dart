//DART FILE THAT FORMATS ALL THE QUESTIONS
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mozambique_app/model/quiz.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class QuizQuestionWidget extends StatefulWidget {
  //DICTATES WHAT THE WIDGET TAKES OR WHAT IS REQUIRED TO MAKE THE QUIZ QUESTION
  final QuizQuestion question;
  final bool isFirst; // To determine if this is the first question in the list

  const QuizQuestionWidget({
    super.key,
    required this.question,
    this.isFirst = false,
  });

  @override
  State<QuizQuestionWidget> createState() => _QuizQuestionWidgetState();
}

class _QuizQuestionWidgetState extends State<QuizQuestionWidget> {
  late QuizQuestion _question;
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _displayWidth = 275;

  @override
  void initState() {
    super.initState();
    _question = widget.question;

    if (_audioPlayer.audioCache.prefix != '') { // Clear prefix 
      _audioPlayer.audioCache.prefix = '';
    }

    _audioPlayer.setSourceBytes(_question.audioBytes); // Set the audio source to the byte data
    _audioPlayer.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
    _audioPlayer.setVolume(1.0); // Set the volume to maximum
    _setImageSize(_question.imageBytes);
  }

  Future<void> _setImageSize(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    setState(() {
      _displayWidth = image.width > 600 ? 775 : 275; // adjust as needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: MediaQuery.of(context).size.width / 1.1 - 15,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECF0F1),
          borderRadius: BorderRadius.only(
            topLeft: widget.isFirst ? Radius.circular(12) : Radius.circular(0),
            topRight: widget.isFirst ? Radius.circular(12) : Radius.circular(0),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Column(
          //FORMAT OF OVERALL QUESTION
          children: [
            SizedBox(height: 30),
            Container(
              width: MediaQuery.of(context).size.width / 1.25 - 15,
              height: 75,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 170, 170, 175),
                border: Border.all(
                  color: const Color.fromARGB(255, 170, 170, 175),
                  width: 2,
                ),
                //ROUNDS THE TOP PART OF THE QUESTION ONLY
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: InkWell(
                onTap: () {
                  _audioPlayer.resume(); // Play the audio when the question bar is tapped
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //QUESTION PROMPT
                    Text(
                      _question.questionText, //CHANGE QUESTION TEXT HERE
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3E50),
                      ),
                    ),
                    SizedBox(width: 10), //SPACING BETWEEN QUESTION PROMPT AND SOUND ICON
                    //SOUND ICON
                    const Icon(
                      Icons.volume_up,
                      color: Color(0xFF2D3E50),
                      size: 44,
                    ),
                  ]
                ),
              ),
            ),

            //IMAGE PROMPT FOR THE QUESTION
            Container(
              width: MediaQuery.of(context).size.width / 1.25 - 15,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 135, 135, 140),
                border: Border.all(
                  color: const Color.fromARGB(255, 135, 135, 140),
                  width: 2,
                ),
                //ROUNDS THE BOTTOM PART OF THE QUESTION ONLY
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              margin: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: _question.imageBytes.isNotEmpty
                ? Image.memory(
                    _question.imageBytes,
                    height: 275,
                    width: _displayWidth,
                  )
                : const Icon(
                    Icons.error,
                    size: 275,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose of the audio player when the widget is removed from the tree
    
    super.dispose();
  }
}