//DART FILE FOR LEFT SIDE MESSAGES WIDGET
import 'package:flutter/material.dart';

class Msg1 extends StatelessWidget {
  final String msg1;
  final bool isLast;
  // final VoidCallback onTap;

  // const Msg1({required this.msg1, required this.onTap, Key? key}) : super(key: key);
  const Msg1({required this.msg1, required this.isLast, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: MediaQuery.of(context).size.width / 2 - 15,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECF0F1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: isLast ? Radius.circular(12) : Radius.circular(0),
            bottomRight: isLast ? Radius.circular(12) : Radius.circular(0),
          ),
        ),
        //MESSAGE BOX SETTINGS
        child: Container(
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
            child: FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min, // Ensures the bubble wraps content
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //MESSAGE TEXT
                  Text(
                    msg1,
                    style: TextStyle(
                      fontSize: 20,
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
        ),
      ),
    );
  }
}