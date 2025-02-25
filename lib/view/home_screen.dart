import 'package:flutter/material.dart';
import 'package:mozambique_app/view/home_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF95A5A5),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF95A5A5),
                      ),
                    ),
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
                  HomeCard(icon: '🔢', title: 'Números'),
                  HomeCard(icon: '🎨', title: 'Cores'),
                  HomeCard(icon: '🍎', title: 'Frutas'),
                  HomeCard(icon: '🥬', title: 'Produtos Hortícolas',),
                  HomeCard(icon: '🐾', title: 'Animais'),
                  HomeCard(icon: '🏃🏾', title: 'Ações Comuns'),
                  HomeCard(icon: '🗓️', title: 'Atividades Cotidianas'),
                  HomeCard(icon: '💼', title: 'Profissões'),
                  HomeCard(icon: '🏠', title: 'Coisas da Casa'),
                  HomeCard(icon: '🍽️', title: 'Coisas da Cozinha'),
                  HomeCard(icon: '🧑🏾', title: 'Rosto'),
                  HomeCard(icon: '🧍🏾', title: 'Corpo'),
                  HomeCard(icon: '👋🏾', title: 'Saudações'),
                  HomeCard(icon: '❓', title: 'Pedidos'),
                ],
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}