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
  List<bool> isSelected = [false, false, false];

  late List<QuizAnswer> _options = [];
  late List<AudioPlayer> _audioPlayers = []; // List to hold audio players

  @override
  void initState() {
    super.initState();

    _options = [widget.option1, widget.option2, widget.option3];

    _audioPlayers = [
      AudioPlayer(),
      AudioPlayer(),
      AudioPlayer(),
    ];

    _audioPlayers.asMap().forEach((i, player) {
      player.setSourceBytes(_options[i].audioBytes); // Set the audio source to the byte data
      player.setReleaseMode(ReleaseMode.stop); // Stop the audio when finished
      player.setVolume(1.0); // Set the volume to maximum
    });
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
          //spacing: 48, // Spacing between options
          mainAxisAlignment: MainAxisAlignment.center, // Ensures content is aligned to the left
          children: _options.asMap().entries.map((entry) {
            int i = entry.key;
            QuizAnswer option = entry.value;

            return Row(
              spacing: 12, // Spacing between option and checkbox
              children: [
                InkWell(
                  onTap: () {
                    _audioPlayers[i].resume(); // Play the audio when the card is tapped
                  },
                  child: Container(
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
                            option.answerText,
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFECF0F1),
                            ),
                          ),
                          SizedBox(width: 10),
                          //SOUND ICON
                          const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: 44,
                          ), // Spacing between text and icon
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 2.25, // Increase or decrease this value as needed
                  child: CustomCheckbox(
                    isChecked: isSelected[i],
                    isCorrect: option.isCorrect, //CHECKS IF THIS OPTION IS THE DESIGNATED CORRECT ONE
                    //CHANGE TO COLORED ICON WHEN TAPPED / CLICKED
                    onChanged: (newValue) {
                      setState(() {
                        isSelected[i] = newValue;
                      });
                    },
                  )
                ),
                SizedBox(width: 20),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the audio players when the widget is removed from the widget tree
    for (AudioPlayer player in _audioPlayers) {
      player.dispose();
    }

    super.dispose();
  }
}