//MAIN DART FILE FOR PRACTICE CONVO PAGE
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
  int _msgIndex = 1; // Start with only 1 message visible
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  //ORDER OF MESSAGES USING MSG1 AND MSG2 WIDGETS FOR FORMATTING
  final List<Widget> _messages = [
    Msg1(msg1: 'Olá.', isLast: false),
    Msg2(msg2: 'Olá.', isLast: false),
    Msg1(msg1: 'Bom dia.', isLast: false),
    Msg2(msg2: 'Bom dia.', isLast: false),
    Msg1(msg1: 'Como estás?', isLast: false),
    Msg2(msg2: 'Estou bem, obrigado!', isLast: true),
  ];

  List<Widget> _visibleMessages = [];

  //FUNCTION TO SHOW NEXT MESSAGE IN THE ARRAY ABOVE AS WELL AS SCROLLING ANIMATION
  void _revealNextMessage() {
    if (_msgIndex < _messages.length) {
      setState(() {
        _visibleMessages.add(_messages[_msgIndex]);
        _msgIndex++; // Show the next message
      });

      // Ensure scrolling happens *after* UI updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //_scrollToBottom();
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void resetConversation() {
    setState(() {
      while(_msgIndex != 1){
        _msgIndex--;
        _visibleMessages.removeLast();
      }
    });
  }

  void goBackOneMessage() {
    if (_msgIndex > 1) {
      setState(() {
        _msgIndex--;
        _visibleMessages.removeLast();
      });
    }
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(53, 64, 79, 255),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color.fromRGBO(53, 64, 79, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF95A5A5),
                    ),
                  ),
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
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Prática',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                    ),
                    iconSize: 50,
                    onPressed: null,
                  ),
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
                              //SECTION TITLE
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    //margin: EdgeInsets.symmetric(vertical: 0),
                                    child: const Text(
                                      'Pedidos',
                                      style: TextStyle(
                                        fontSize: 100,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFECF0F1),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width / 8 - 25),
                                  Container(
                                    width: MediaQuery.of(context).size.width / 8.5 - 15,
                                    child: ElevatedButton(
                                      onPressed: _msgIndex > 1 ? resetConversation : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent, 
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                        side: _msgIndex > 1 ? BorderSide(color: Colors.white, width: 2.5) : BorderSide(color: Color(0xFF969FA7), width: 1.25),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text('Reiniciar ⟲', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                              //CONVERSATION HEADER WITH PERSON ICONS
                              Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width / 2 - 15,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECF0F1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                      alignment: Alignment.centerLeft,
                                      child:Image(
                                      image: AssetImage('assets/images/NavyPerson.png'),
                                      width: 75,
                                      height: 75,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 20),
                                      alignment: Alignment.centerRight,
                                      child:Image(
                                      image: AssetImage('assets/images/GrayPerson.png'),
                                      width: 75,
                                      height: 75,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //CONVERSATION SECTION WHERE MESSAGES WILL POPULATE
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  scrollDirection: Axis.vertical, // Enables vertical scrolling
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // Ensures text is left-aligned
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (int i = 0; i < _msgIndex; i++) _messages[i],
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10, width: MediaQuery.of(context).size.width / 3 - 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(width: MediaQuery.of(context).size.width / 10 - 15),
                                  Container(
                                    width: MediaQuery.of(context).size.width / 8 - 15,
                                    child: ElevatedButton(
                                      onPressed: _msgIndex > 1 ? goBackOneMessage : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent, 
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        side: _msgIndex > 1 ? BorderSide(color: Colors.white, width: 2.5) : BorderSide(color: Color(0xFF969FA7), width: 1.25),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text('← Voltar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width / 10 - 15),
                                  //NEXT BUTTON TO SHOW MESSAGES
                                  Container(
                                    width: MediaQuery.of(context).size.width / 8 - 15,
                                    child: ElevatedButton(
                                      onPressed: _msgIndex < _messages.length ? _revealNextMessage : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        side: _msgIndex != _messages.length ? BorderSide(color: Colors.white, width: 2.5) : BorderSide(color: Color(0xFF969FA7), width: 1.25),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(_msgIndex == _messages.length ? 'Terminado' : 'Próximo →', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    )
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width / 20 - 15),
                        //SECTION IMAGE AND BUTTONS
                        Column(
                          children: [
                            SizedBox(height: 115),
                            Image(
                              image: AssetImage('assets/images/Practice/PersonalInteractions.png'),
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