import 'package:flutter/material.dart';

import 'package:mozambique_app/services/database_service.dart';

class Navbar extends StatefulWidget {
  final Function(String) onSearchChanged;
  
  const Navbar({
    super.key,
    required this.onSearchChanged,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String _searchText = '';
  final DatabaseService _databaseService = DatabaseService();

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
                hintText: 'Search',
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
                  _searchText = value;
                });

                widget.onSearchChanged(_searchText);
              }
            ),
          ),
          TextButton( // Using as Update/Sync button (for now)
            onPressed: () async {
              await _databaseService.syncContent();
            },
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
              'Practice',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E50),
              ),
            ),
          )
        ],
      ),
    );
  }
}