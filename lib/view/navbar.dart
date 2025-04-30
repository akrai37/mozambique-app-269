import 'package:flutter/material.dart';

import 'package:mozambique_app/view/info_screen.dart';
import 'package:mozambique_app/view/home_screen.dart';

class Navbar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback? onSync; // When the sync button is pressed
  final bool isHomeScreen; // To check if the user is on the HomeScreen
  final bool isLearnScreen; // To check if the user is on the LearnScreen
  final bool isInfoScreen; // To check if the user is on the InfoScreen
  final bool isPractice; // To check if the user is on a practice screen (dark mode)
  
  const Navbar({
    super.key,
    required this.onSearchChanged,
    required this.isPractice,
    this.onSync,
    this.isHomeScreen = false,
    this.isLearnScreen = true,
    this.isInfoScreen = false,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          Row(
            children: [
              if (!widget.isHomeScreen) // Only show the back button if not on HomeScreen
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: widget.isPractice ? Colors.white : Colors.black,
                  ),
                ),
              const Text(
                'DIFF EDUCATION',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE84C3D),
                ),
              ),
            ],
          ),
          Expanded( // ensures the TextField takes up the remaining space
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Procurar...',
                hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.isPractice ? Colors.white : Color(0xFF95A5A5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: widget.isPractice ? Colors.white : Color(0xFF95A5A5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: widget.isPractice ? Color(0xFF969FA7) : Color(0xFFECF0F1),
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E50),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim();
                });

                widget.onSearchChanged(_searchText);
              }
            ),
          ),
          TextButton( 
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(type: widget.isLearnScreen ? 'practice' : 'learn')),
              );
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                    color: widget.isPractice ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            child: Text(
              'Prática',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isPractice ? Colors.white : Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: widget.isInfoScreen ? Colors.grey : (widget.isPractice ? Colors.white : Colors.black),
            ),
            iconSize: 50,
            onPressed: widget.isInfoScreen
              ? null
              : () async {
                final didSync = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InfoScreen(),
                  ),
                );

                // Check if the sync function is provided and if the user did sync
                if (widget.onSync != null && didSync == true) {
                  widget.onSync!();
                }
              },
          )
        ],
      ),
    );
  }
}