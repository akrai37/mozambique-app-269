import 'package:flutter/material.dart';

import 'package:mozambique_app/view/info_screen.dart';

class Navbar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback? onSync; // When the sync button is pressed
  
  const Navbar({
    super.key,
    required this.onSearchChanged,
    this.onSync,
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
          const Text(
            'DIFF EDUCATION',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE84C3D),
            ),
          ),
          Expanded( // ensures the TextField takes up the remaining space
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Procurar...',
                hintStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF95A5A5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF95A5A5),
                ),
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
                  side: const BorderSide(
                    color: Color(0xFF2D3E50),
                  ),
                ),
              ),
            ),
            child: const Text(
              'Prática',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E50),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            iconSize: 50,
            onPressed: () async {
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