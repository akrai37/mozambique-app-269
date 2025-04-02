import 'package:flutter/material.dart';

import 'package:mozambique_app/view/home_card.dart';
import 'package:mozambique_app/services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 90.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // aligns the children to the start (left) of the row
              children: [
                const Text(
                  'Olá!',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3E50),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 200, // height of the screen minus the height of the AppBar
            child: SingleChildScrollView(
              child: Wrap( // replaces Row so that the children wrap to the next line if they don't fit
                direction: Axis.horizontal,
                spacing: 10,
                runSpacing: 10,
                children: [
                  HomeCard(img: 'assets/images/learn/Numbers.png', title: 'Números', tag: 'numbers'),
                  HomeCard(img: 'assets/images/learn/Colors.png', title: 'Cores', tag: 'colors'),
                  HomeCard(img: 'assets/images/learn/Fruits.png', title: 'Frutas', tag: 'fruits'),
                  HomeCard(img: '', title: 'Produtos Hortícolas', tag: 'vegetables'),
                  HomeCard(img: 'assets/images/learn/Animals.png', title: 'Animais', tag: 'animals'),
                  HomeCard(img: 'assets/images/learn/Common Actions.png', title: 'Ações Comuns', tag: 'common_actions'),
                  HomeCard(img: 'assets/images/learn/Everyday Activities.png', title: 'Atividades Cotidianas', tag: 'everyday_activities'),
                  HomeCard(img: '', title: 'Profissões', tag: 'professions'),
                  HomeCard(img: 'assets/images/learn/Household Items.png', title: 'Coisas da Casa', tag: 'household_items'),
                  HomeCard(img: 'assets/images/learn/Kitchen Items.png', title: 'Coisas da Cozinha', tag: 'kitchen_items'),
                  HomeCard(img: 'assets/images/learn/Face.png', title: 'Rosto', tag: 'face'),
                  HomeCard(img: 'assets/images/learn/Body.png', title: 'Corpo', tag: 'body'),
                  HomeCard(img: 'assets/images/learn/Greetings.png', title: 'Saudações', tag: 'greetings'),
                  HomeCard(img: '', title: 'Pedidos', tag: 'requests'),
                ],
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}