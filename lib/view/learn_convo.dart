import 'package:flutter/material.dart';
import 'package:mozambique_app/view/msg_sample.dart';
import 'package:flutter_svg/flutter_svg.dart';


//may need to change depending on how routing works
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String person1Svg = '''
  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-person-fill" viewBox="0 0 16 16">
  <path d="M3 14s-1 0-1-1 1-4 6-4 6 3 6 4-1 1-1 1zm5-6a3 3 0 1 0 0-6 3 3 0 0 0 0 6"/>
  </svg>
  ''';

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
            child: Column(
              children: [
                //PAGE TITLE
                Container(
                      margin: EdgeInsets.symmetric(vertical: 0),
                      alignment: Alignment.topLeft,
                      child: const Text(
                          'Saudações',
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3E50),
                          ),
                        ),
                    ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          '😁 ',
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3E50),
                          ),
                        ),
                        const Text(
                          '   🙂',
                          style: TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3E50),
                          ),
                        ),
                      ]
                    ),
                    Row(
                      children: [
                        SvgPicture.string(
                          person1Svg,
                          colorFilter: ColorFilter.mode(const Color(0xFF2D3E50), BlendMode.srcIn),
                          width: 100,
                          height: 100, // Change icon color if needed
                        ),
                        SizedBox(width: 340),
                        SvgPicture.string(
                          person1Svg,
                          colorFilter: ColorFilter.mode(const Color(0xFF969FA7), BlendMode.srcIn),
                          width: 100,
                          height: 100, // Change icon color if needed
                        ),
                        SizedBox(width: 175),
                        SvgPicture.string(
                          person1Svg,
                          colorFilter: ColorFilter.mode(const Color(0xFF2D3E50), BlendMode.srcIn),
                          width: 100,
                          height: 100, // Change icon color if needed
                        ),
                        SizedBox(width: 340),
                        SvgPicture.string(
                          person1Svg,
                          colorFilter: ColorFilter.mode(const Color(0xFF969FA7), BlendMode.srcIn),
                          width: 100,
                          height: 100, // Change icon color if needed
                        ),
                        SizedBox(height: 15),
                      ]
                    ),
                  ]
                )
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Enables vertical scrolling
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// First Column (List of Messages)
                  Expanded(
                    child: Column(
                      children: [
                        MsgSample(greeting: 'Olá.', response: 'Olá! Que bom ver você!'),
                        SizedBox(height: 50),
                        MsgSample(greeting: 'Bom dia.', response: 'Como você vai?'),
                        SizedBox(height: 50),
                        MsgSample(greeting: 'Boa tarde.', response: 'Boa tarde! Como vai seu dia?'),
                        SizedBox(height: 50),
                        MsgSample(greeting: 'Boa noite.', response: 'Boa noite! Como foi seu dia?'),
                        SizedBox(height: 50),
                        MsgSample(greeting: 'E ai?', response: 'Só estou aqui passando tempo!'),
                        SizedBox(height: 50),
                        MsgSample(greeting: 'Como vai?', response: 'Estou ótimo!'),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                  /// Second Column (List of Messages)
                  Expanded(
                    child: Column(
                      children: [
                        MsgSample(greeting: 'Olá.', response: 'Olá.'),
                        SizedBox(height: 50),
                        MsgSample(greeting: 'Bom dia.', response: 'Bom dia.'),
                        SizedBox(height: 50),
                        MsgSample(greeting: 'Boa tarde.', response: 'Boa tarde.'),
                        SizedBox(height: 50),
                        MsgSample(greeting: 'Boa noite.', response: 'Boa noite.'),
                        SizedBox(height: 50),
                        MsgSample(greeting: 'E ai?', response: 'Tudo beleza.'),
                        SizedBox(height: 50),
                        MsgSample(greeting: 'Como vai?', response: 'Estou bem.'),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}