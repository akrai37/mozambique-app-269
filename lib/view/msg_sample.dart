import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class MsgSample extends StatelessWidget {
  final String greeting;
  final String response;
  final Uint8List audio;

//no idea what this is for
  const MsgSample({
    super.key,
    required this.greeting,
    required this.response,
    required this.audio,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      width: MediaQuery.of(context).size.width / 2 - 15,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color(0xFFECF0F1),
        ),
        child: Column(
          children: [
            SizedBox(height: 40),
            Container(
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
                      Text(
                          greeting,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFECF0F1),
                          ),
                        ),
                      SizedBox(width: 10), // Spacing between text and icon
                      // Speaker Icon
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2D3E50),
                            ),
                            padding: const EdgeInsets.all(5),
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
            ),
            
            SizedBox(height: 15),
            Container(
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
                      Text(
                          response,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3E50),
                          ),
                        ),
                      SizedBox(width: 5), // Spacing between text and icon
                      // Speaker Icon
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF969FA7),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: const Icon(
                              Icons.volume_up,
                              color: Color(0xFF2D3E50),
                              size: 24,
                            ),
                          )
                        )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}