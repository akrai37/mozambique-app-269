//DART FILE FOR RIGHT SIDE MESSAGE WIDGET
import 'package:flutter/material.dart';

class Msg2 extends StatelessWidget {
  final String msg2;
  const Msg2({required this.msg2, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: MediaQuery.of(context).size.width / 2 - 15,
      //MESSAGE BOX FORMATTING
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECF0F1),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF969FA7),
              border: Border.all(
                color: const Color(0xFF969FA7),
                width: 2,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8), // Tail effect
                bottomRight: Radius.circular(0),
              ),
            ),
            child: FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min, // Ensures the bubble wraps content
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //MESSAGE TEXT
                  Text(
                      msg2,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3E50),
                      ),
                    ),
                  SizedBox(width: 5), // Spacing between text and icon
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
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}