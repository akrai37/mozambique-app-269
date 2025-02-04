import 'package:flutter/material.dart';
import 'package:mozambique_app/view/msg_sample.dart';


//may need to change depending on how routing works
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
                //DIFF EDUCATION LOGO
                const Text(
                  'DIFF EDUCATION',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE84C3D),
                  ),
                ),
                Expanded( // ensures the TextField takes up the remaining space
                  //SEARCH BAR
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
                  //PRACTICE BUTTON
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
                //PAGE TITLE
                const Text(
                  'Saudações',
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3E50),
                  ),
                ),
              ],
            ),
          ),
          Wrap( // replaces Row so that the children wrap to the next line if they don't fit
            direction: Axis.horizontal,
            spacing: 10,
            runSpacing: 10,
            children: [
              MsgSample(greeting: 'Olá.', response: 'Olá! Que bom ver você!'),
              MsgSample(greeting: 'Olá.', response: 'Olá.'),
              MsgSample(greeting: 'Bom dia.', response: 'Como você vai?'),
              MsgSample(greeting: 'Bom dia.', response: 'Bom dia.'),
              MsgSample(greeting: 'Boa tarde.', response: 'Boa tarde! Como vai seu dia?'),
              MsgSample(greeting: 'Boa tarde.', response: 'Boa tarde.'),
              MsgSample(greeting: 'Boa noite.', response: 'Boa noite! Como foi seu dia?'),
              MsgSample(greeting: 'Boa noite.', response: 'Boa noite.'),
              MsgSample(greeting: 'E ai?', response: 'Só estou aqui passando tempo!'),
              MsgSample(greeting: 'E ai?', response: 'Tudo beleza.'),
              MsgSample(greeting: 'Como vai?', response: 'Hello'),
              MsgSample(greeting: 'Como vai?', response: 'Estou bem.'),
            ],
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}