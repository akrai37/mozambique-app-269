import 'package:flutter/material.dart';
import 'package:mozambique_app/view/p1_msg.dart';
import 'package:mozambique_app/view/p2_msg.dart';

//may need to change depending on how routing works
class PracConvo extends StatefulWidget {
  const PracConvo({super.key});

  @override
  State<PracConvo> createState() => _PracConvoState();
}

class _PracConvoState extends State<PracConvo> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(53, 64, 79, 255),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color.fromRGBO(53, 64, 79, 1),
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
                                    color: Color(0xFFECF0F1),
                                  ),
                                ),
                              ),
                              Container(
                                height: 175,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECF0F1),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: MediaQuery.of(context).size.width / 28 - 15),
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
                                    SizedBox(width: MediaQuery.of(context).size.width / 28 - 15),
                                  ],
                                ),
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
                                          Msg1(msg1: 'Olá.'),
                                          Msg2(msg2: 'Olá.'),
                                          Msg1(msg1: 'Bon dia.'),
                                          Msg2(msg2: 'Bon dia.'),
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
                              width: MediaQuery.of(context).size.width / 2.5 - 15,
                              height: MediaQuery.of(context).size.width / 2.5 - 15,
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
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}