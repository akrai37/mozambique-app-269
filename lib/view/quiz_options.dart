//DART FILE TO FORMAT THE QUIZ OPTIONS
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mozambique_app/model/quiz.dart';
import 'package:mozambique_app/view/quiz_checkbox.dart';
import 'package:mozambique_app/services/audio_coordinator.dart';

class QuizOptions extends StatefulWidget {
  //DICTATES WHAT THE WIDGET TAKES IN TO MAKE OPTIONS
  // Takes the answers as a list rather than three fixed slots, so a question
  // authored with two or four options renders instead of crashing.
  final List<QuizAnswer> options;
  final bool isLast;

  /// Fires once, on the learner's first answer, with whether it was correct.
  ///
  /// Only the first answer is reported: changing your mind afterwards still
  /// updates the highlighting, but the score reflects what you actually knew.
  final ValueChanged<bool>? onFirstAnswer;

  const QuizOptions({
    super.key,
    required this.options,
    this.isLast = false,
    this.onFirstAnswer,
  });

  @override
  State<QuizOptions> createState() => _QuizOptionsState();
}

class _QuizOptionsState extends State<QuizOptions> {
  //SETS ALL OF CHECKBOXES TO DEFAULT: NOT SELECTED
  // Index of the chosen answer, or null before anything is picked.
  //
  // Was previously a List<bool>, which let a learner tick every box at once —
  // including all the wrong ones — and still see a green check. A quiz question
  // has one answer, so the state is one selection.
  int? _selectedIndex;

  // Guards onFirstAnswer so the score records the first attempt only.
  bool _hasReported = false;

  late List<QuizAnswer> _options = [];
  late List<AudioPlayer> _audioPlayers = []; // List to hold audio players

  void _select(int index) {
    setState(() => _selectedIndex = index);

    if (!_hasReported) {
      _hasReported = true;
      widget.onFirstAnswer?.call(_options[index].isCorrect);
    }
  }

  @override
  void initState() {
    super.initState();

    _options = widget.options;

    _audioPlayers = List<AudioPlayer>.generate(
      _options.length,
      (_) => AudioPlayer(),
    );

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
                    AudioCoordinator.play(_audioPlayers[i]); // Play the audio when the card is tapped
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
                    isChecked: _selectedIndex == i,
                    isCorrect: option.isCorrect, //CHECKS IF THIS OPTION IS THE DESIGNATED CORRECT ONE
                    //CHANGE TO COLORED ICON WHEN TAPPED / CLICKED
                    onChanged: (_) => _select(i),
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
      AudioCoordinator.forget(player);
      player.dispose();
    }

    super.dispose();
  }
}