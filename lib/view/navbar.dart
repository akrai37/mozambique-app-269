import 'package:flutter/material.dart';

import 'package:mozambique_app/view/info_screen.dart';

class Navbar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback? onSync; // When the sync button is pressed
  final bool isHomeScreen; // To check if the user is on the HomeScreen
  final bool isInfoScreen;
  final bool isPractice; // To check if the user is on the InfoScreen
  
  const Navbar({
    super.key,
    required this.onSearchChanged,
    required this.isPractice,
    this.onSync,
    this.isHomeScreen = false,
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
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
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
              decoration: const InputDecoration(
                hintText: 'Procurar...',
                hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF95A5A5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF95A5A5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFFECF0F1),
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
            onPressed: () {},
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                    color: widget.isPractice ? Color(0xFF95A5A5) : Color(0xFF2D3E50),
                  ),
                ),
              ),
            ),
            child: Text(
              'Prática',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isPractice ? Color(0xFF95A5A5) : Color(0xFF2D3E50),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: widget.isInfoScreen ? Colors.grey : (widget.isPractice ? Color(0xFF95A5A5) : Color(0xFF2D3E50)),
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