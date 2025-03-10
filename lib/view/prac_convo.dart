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


          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Ensures content is aligned to the left
              children: [
                SizedBox(width: MediaQuery.of(context).size.width / 15 - 15), // Adds left spacing
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the top
                    children: [
                      Align(
                        alignment: Alignment.topLeft, // Ensures "Pedidos" stays at the top-left
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Aligns everything to the left
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 0),
                              child: const Text(
                                'Pedidos',
                                style: TextStyle(
                                  fontSize: 100,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3E50),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(width: MediaQuery.of(context).size.width / 35 - 15),
                                Image(
                                  image: AssetImage('assets/images/NavyPerson.png'),
                                  width: 75,
                                  height: 75,
                                ),
                                SizedBox(width: MediaQuery.of(context).size.width / 3 - 15),
                                Image(
                                  image: AssetImage('assets/images/GrayPerson.png'),
                                  width: 75,
                                  height: 75,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.vertical, // Enables vertical scrolling
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Ensures text is left-aligned
                                      children: [
                                        /// First Column (List of Messages)
                                        MsgSample(greeting: 'Olá.', response: 'Olá! Que bom ver você!'),
                                        MsgSample(greeting: 'Bom dia.', response: 'Como você vai?'),
                                        MsgSample(greeting: 'Olá.', response: 'Olá! Que bom ver você!'),
                                        MsgSample(greeting: 'Bom dia.', response: 'Como você vai?'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 20 - 15),
                      Column(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height / 6 - 15),
                          Image(
                            image: AssetImage('assets/images/shop-temp.png'),
                            width: 500,
                            height: 500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}