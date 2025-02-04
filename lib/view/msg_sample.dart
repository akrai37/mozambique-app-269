import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MsgSample extends StatelessWidget {
  final String greeting;
  final String response;

//no idea what this is for
  const MsgSample({
    super.key,
    required this.greeting,
    required this.response,
  });

  final String volumeUpSvg = '''
  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
    <path d="M11.536 14.01A8.47 8.47 0 0 0 14.026 8a8.47 8.47 0 0 0-2.49-6.01l-.708.707A7.48 7.48 0 0 1 13.025 8c0 2.071-.84 3.946-2.197 5.303z"/>
    <path d="M10.121 12.596A6.48 6.48 0 0 0 12.025 8a6.48 6.48 0 0 0-1.904-4.596l-.707.707A5.48 5.48 0 0 1 11.025 8a5.48 5.48 0 0 1-1.61 3.89z"/>
    <path d="M10.025 8a4.5 4.5 0 0 1-1.318 3.182L8 10.475A3.5 3.5 0 0 0 9.025 8c0-.966-.392-1.841-1.025-2.475l.707-.707A4.5 4.5 0 0 1 10.025 8M7 4a.5.5 0 0 0-.812-.39L3.825 5.5H1.5A.5.5 0 0 0 1 6v4a.5.5 0 0 0 .5.5h2.325l2.363 1.89A.5.5 0 0 0 7 12zM4.312 6.39 6 5.04v5.92L4.312 9.61A.5.5 0 0 0 4 9.5H2v-3h2a.5.5 0 0 0 .312-.11"/>
  </svg>
  ''';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      width: 657.5,
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
                    Container(
                      padding: EdgeInsets.all(5), // Space around the icon
                      decoration: BoxDecoration(
                        color: Colors.white, // White circular background
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.string(
                        volumeUpSvg,
                        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn), // Change icon color if needed
                      ),
                    ),
                  ],
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
                    SizedBox(width: 10), // Spacing between text and icon
                    Container(
                      padding: EdgeInsets.all(5), // Space around the icon
                      decoration: BoxDecoration(
                        color: Colors.white, // White circular background
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.string(
                        volumeUpSvg,
                        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn), // Change icon color if needed
                      ),
                    ),
                  ],
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