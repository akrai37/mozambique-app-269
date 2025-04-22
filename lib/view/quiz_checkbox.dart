//DART FILE TO MAKE CUSTOM CHECKBOX -> CHANGES DEPENDING ON CORRECT OR INCORRECT OPTION
import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget{
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final bool isCorrect;

  const CustomCheckbox({
    required this.isChecked,
    required this.onChanged,
    required this.isCorrect,
    super.key,
  });

  @override
  Widget build(BuildContext context){
    //MAKES EACH CALL INTERACTABLE
    return InkWell(
      onTap: () => onChanged(!isChecked),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          //GREEN IF CORRECT, RED IF INCORRECT, BLACK IF NOT SELECTED -> USED TO MATCH COLOR WHEN CHECKBOX IS SELECTED
          border: Border.all(color: isChecked ? (isCorrect ? Colors.green : Colors.red) : Color(0xFF2D3E50), width: 3),
          //GREEN IF CORRECT, RED IF INCORRECT, TRANSPARENT IF NOT SELECTED -> DICTATES INSIDE COLOR
          color: isChecked ?  (isCorrect ? Colors.green : Colors.red) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        //CHECKMARK IF CORRECT, X MARK IF INCORRECT, NOTHING IF NOT SELECTED
        child: isChecked ? Center(child: Icon(isCorrect ? Icons.check : Icons.close, size: 16, color: Colors.white),) : null,
      )
    );
  }
}