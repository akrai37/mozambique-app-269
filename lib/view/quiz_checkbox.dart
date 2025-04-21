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
    return InkWell(
      onTap: () => onChanged(!isChecked),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: isChecked ? (isCorrect ? Colors.green : Colors.red) : Color(0xFF2D3E50), width: 3),
          color: isChecked ?  (isCorrect ? Colors.green : Colors.red) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: isChecked ? Center(child: Icon(isCorrect ? Icons.check : Icons.close, size: 16, color: Colors.white),) : null,
      )
    );
  }
}