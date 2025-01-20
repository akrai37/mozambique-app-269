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
      body: Center(
        child: Column(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap( // replaces Row so that the children wrap to the next line if they don't fit
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
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}