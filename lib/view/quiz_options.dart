import 'package:flutter/material.dart';
import 'package:mozambique_app/view/quiz_checkbox.dart';

class QuizOptions extends StatefulWidget {
  final String option1;
  final String option2;
  final String option3;
  final int correctOption;

  const QuizOptions({
    required this.option1,
    required this.option2,
    required this.option3,
    required this.correctOption,
    super.key,
  });

  @override
  State<QuizOptions> createState() => _QuizOptionsState();
}

class _QuizOptionsState extends State<QuizOptions> {
  bool isSelected1 = false;
  bool isSelected2 = false;
  bool isSelected3 = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: MediaQuery.of(context).size.width / 1.1 - 15,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECF0F1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Ensures content is aligned to the left
          children: [ 
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
                    Text(
                      widget.option1,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFECF0F1),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(5), // Space around the icon
                      decoration: BoxDecoration(
                        color: Colors.white, // White circular background
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up,
                        color: Color(0xFF2D3E50),
                        size: 24,
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
                isCorrect: widget.correctOption == 1,
                onChanged: (newValue){
                  setState((){
                    isSelected1 = newValue;
                  });
                },
              )
            ),
            SizedBox(width: 12),

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
                    Text(
                      widget.option2,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFECF0F1),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(5), // Space around the icon
                      decoration: BoxDecoration(
                        color: Colors.white, // White circular background
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up,
                        color: Color(0xFF2D3E50),
                        size: 24,
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
                isCorrect: widget.correctOption == 2,
                onChanged: (newValue){
                  setState((){
                    isSelected2 = newValue;
                  });
                },
              )
            ),
            SizedBox(width: 12),

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
                    Text(
                      widget.option3,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFECF0F1),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(5), // Space around the icon
                      decoration: BoxDecoration(
                        color: Colors.white, // White circular background
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volume_up,
                        color: Color(0xFF2D3E50),
                        size: 24,
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
                isCorrect: widget.correctOption == 3,
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