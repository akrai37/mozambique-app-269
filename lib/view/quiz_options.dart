//DART FILE TO FORMAT THE QUIZ OPTIONS
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mozambique_app/model/quiz.dart';
import 'package:mozambique_app/view/quiz_checkbox.dart';

class QuizOptions extends StatefulWidget {
  //DICTATES WHAT THE WIDGET TAKES IN TO MAKE OPTIONS
  final QuizAnswer option1;
  final QuizAnswer option2;
  final QuizAnswer option3;
  final bool isLast;

  const QuizOptions({
    super.key,
    required this.option1,
    required this.option2,
    required this.option3,
    this.isLast = false,
  });

  @override
  State<QuizOptions> createState() => _QuizOptionsState();
}

class _QuizOptionsState extends State<QuizOptions> {
  //SETS ALL OF CHECKBOXES TO DEFAULT: NOT SELECTED
  bool isSelected1 = false;
  bool isSelected2 = false;
  bool isSelected3 = false;

  late QuizAnswer _option1;
  late QuizAnswer _option2;
  late QuizAnswer _option3;
  final AudioPlayer _audioPlayer1 = AudioPlayer();
  final AudioPlayer _audioPlayer2 = AudioPlayer();
  final AudioPlayer _audioPlayer3 = AudioPlayer();

  @override
  void initState() {
    super.initState();
    
    _option1 = widget.option1;
    _option2 = widget.option2;
    _option3 = widget.option3;

    _audioPlayer1.setSourceBytes(_option1.audioBytes); // Set the audio source to the byte data
    _audioPlayer1.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
    _audioPlayer1.setVolume(1.0); // Set the volume to maximum

    _audioPlayer2.setSourceBytes(_option2.audioBytes); // Set the audio source to the byte data
    _audioPlayer2.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
    _audioPlayer2.setVolume(1.0); // Set the volume to maximum
    
    _audioPlayer3.setSourceBytes(_option3.audioBytes); // Set the audio source to the byte data
    _audioPlayer3.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
    _audioPlayer3.setVolume(1.0); // Set the volume to maximum
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: MediaQuery.of(context).size.width / 1.1 - 15,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Ensures content is aligned to the left
          children: [ 
            //OPTION 1 FORMATTING
            Container(
              width: MediaQuery.of(context).size.width / 5 - 15,
              height: 55,
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
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Ensures the bubble wraps content
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //OPTION TEXT
                    Text(
                      _option1.answerText,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFECF0F1),
                      ),
                    ),
                    SizedBox(width: 10),
                    //SOUND ICON
                    Container(
                      padding: EdgeInsets.all(5), // Space around the icon
                      decoration: BoxDecoration(
                        color: Colors.white, // White circular background
                        shape: BoxShape.circle, 
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Color(0xFF2D3E50),
                          size: 24,
                        ),
                        onPressed: () {
                          _audioPlayer1.resume(); // Play the audio when the icon is tapped
                        },
                      ),
                    ), // Spacing between text and icon
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            Transform.scale(
              scale: 2.25, // Increase or decrease this value as needed
              child: CustomCheckbox(
                isChecked: isSelected1,
                isCorrect: _option1.isCorrect, //CHECKS IF THIS OPTION IS THE DESIGNATED CORRECT ONE
                //CHANGE TO COLORED ICON WHEN TAPPED / CLICKED
                onChanged: (newValue){
                  setState((){
                    isSelected1 = newValue;
                  });
                },
              )
            ),
            SizedBox(width: 12),

            //OPTION 2 FORMATTING
            Container(
              width: MediaQuery.of(context).size.width / 5 - 15,
              height: 55,
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
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Ensures the bubble wraps content
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //OPTION TEXT
                    Text(
                      _option2.answerText,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFECF0F1),
                      ),
                    ),
                    SizedBox(width: 10),
                    //SOUND ICON
                    Container(
                      padding: EdgeInsets.all(5), // Space around the icon
                      decoration: BoxDecoration(
                        color: Colors.white, // White circular background
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Color(0xFF2D3E50),
                          size: 24,
                        ),
                        onPressed: () {
                          _audioPlayer2.resume(); // Play the audio when the icon is tapped
                        },
                      ),
                    ), // Spacing between text and icon
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            Transform.scale(
              scale: 2.25, // Increase or decrease this value as needed
              child: CustomCheckbox(
                isChecked: isSelected2,
                isCorrect: _option2.isCorrect, //CHECKS IF THIS OPTION IS THE DESIGNATED CORRECT ONE
                //CHANGE TO COLORED ICON WHEN TAPPED / CLICKED
                onChanged: (newValue){
                  setState((){
                    isSelected2 = newValue;
                  });
                },
              )
            ),
            SizedBox(width: 12),

            //OPTION 3 FORMATTING
            Container(
              width: MediaQuery.of(context).size.width / 5 - 15,
              height: 55,
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
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Ensures the bubble wraps content
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //OPTION TEXT
                    Text(
                      _option3.answerText,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFECF0F1),
                      ),
                    ),
                    SizedBox(width: 10),
                    //SOUND ICON
                    Container(
                      padding: EdgeInsets.all(5), // Space around the icon
                      decoration: BoxDecoration(
                        color: Colors.white, // White circular background
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Color(0xFF2D3E50),
                          size: 24,
                        ),
                        onPressed: () {
                          _audioPlayer3.resume(); // Play the audio when the icon is tapped
                        },
                      ),
                    ), // Spacing between text and icon
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            Transform.scale(
              scale: 2.25, // Increase or decrease this value as needed
              child: CustomCheckbox(
                isChecked: isSelected3,
                isCorrect: _option3.isCorrect, //CHECKS IF THIS OPTION IS THE DESIGNATED CORRECT ONE
                //CHANGE TO COLORED ICON WHEN TAPPED / CLICKED
                onChanged: (newValue){
                  setState((){
                    isSelected3 = newValue;
                  });
                },
              )
            ),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}