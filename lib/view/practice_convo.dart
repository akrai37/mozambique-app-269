//MAIN DART FILE FOR PRACTICE CONVO PAGE
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mozambique_app/model/conversation.dart';
import 'package:mozambique_app/view/navbar.dart';
import 'package:mozambique_app/view/p1_msg.dart';
import 'package:mozambique_app/view/p2_msg.dart';
import 'package:mozambique_app/view_model/fetch_cards.dart';

//may need to change depending on how routing works
class PracticeConvo extends StatefulWidget {
  final String title;
  final String tag;
  const PracticeConvo({
    super.key,
    required this.title,
    required this.tag
  });


  @override
  State<PracticeConvo> createState() => _PracticeConvoState();
}

class _PracticeConvoState extends State<PracticeConvo> {
  int _msgIndex = 1; // Start with only 1 message visible
  final ScrollController _scrollController = ScrollController();
  late Future<void> _loadingFuture;
  late List<Conversation> _convos =[];
  late List<ConvoLine> _lines = [];
  late Uint8List imageBytes = Uint8List(0);
  final List<Widget> _messages = [];
  final List<Widget> _visibleMessages = [];

  @override
  void initState() {
    super.initState();

    _loadingFuture = _loadContent();
  }

    void _makeMsgWidgets() {
    for (int i = 0; i < _lines.length; i++) {
      if (i % 2 == 0) {
        if (i == _lines.length - 1) {
          _messages.add(Msg1(line: _lines[i], isLast: true));
        } else {
          _messages.add(Msg1(line: _lines[i]));
        }
      } else {
        if(i == _lines.length-1) {
          _messages.add(Msg2(line: _lines[i], isLast: true));
        } else {
          _messages.add(Msg2(line: _lines[i]));
        }
      }
    }
  }

  Future<void> _loadContent() async {
    // This fetches from the local Hive database
    try {
      _convos = await fetchPracConvo(widget.tag);
      _lines = _convos[0].conversationText;

      //preload image
      for (Conversation a in _convos) {
        await precacheImage(MemoryImage(a.imageBytes), context);
        imageBytes = a.imageBytes;
      }

      _makeMsgWidgets();
    } catch (error) {
      log("Error loading data from Hive: $error");
    }
  }
  
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
      while (_msgIndex != 1) {
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // 5% of screen width
    return Scaffold(
      backgroundColor: Color.fromRGBO(53, 64, 79, 255),
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {

            // Show a loading indicator while waiting for images to load
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Color.fromRGBO(53, 64, 79, 1),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Navbar(isPractice: true, onSearchChanged: (test) {}),
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
                                      width: MediaQuery.of(context).size.width / 3.5 - 5,
                                      //margin: EdgeInsets.symmetric(vertical: 0),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          widget.title,
                                          style: TextStyle(
                                            fontSize: 80,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFECF0F1),
                                          ),
                                        ),
                                      )
                                    ),
                                    SizedBox(width: MediaQuery.of(context).size.width / 8 - 35),
                                    Container(
                                      width: MediaQuery.of(context).size.width / 8.5 - 15,
                                      child: ElevatedButton(
                                        onPressed: _msgIndex > 1 ? resetConversation : null,
                                        style: ButtonStyle(
                                          foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                                            if(states.contains(WidgetState.disabled)) {
                                              return Color(0xFF95A5A5);
                                            }
                                            return Colors.white;
                                          }),
                                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                                          side: WidgetStateProperty.all(_msgIndex > 1 ? BorderSide(color: Colors.white, width: 2.5) : BorderSide(color: Color(0xFF95A5A5), width: 1.25)),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)
                                            )
                                          ),
                                          elevation: WidgetStateProperty.all(0),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text('Reiniciar ⟲', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
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
                                        style: ButtonStyle(
                                          foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                                            if(states.contains(WidgetState.disabled)) {
                                              return Color(0xFF95A5A5);
                                            }
                                            return Colors.white;
                                          }),
                                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                                          side: WidgetStateProperty.all(_msgIndex > 1 ? BorderSide(color: Colors.white, width: 2.5) : BorderSide(color: Color(0xFF95A5A5), width: 1.25)),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)
                                            )
                                          ),
                                          elevation: WidgetStateProperty.all(0),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text('← Voltar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: MediaQuery.of(context).size.width / 10 - 15),
                                    //NEXT BUTTON TO SHOW MESSAGES
                                    Container(
                                      width: MediaQuery.of(context).size.width / 8 - 15,
                                      child: ElevatedButton(
                                        onPressed: _msgIndex < _messages.length ? _revealNextMessage : null,
                                        style: ButtonStyle(
                                          foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                                            if(states.contains(WidgetState.disabled)) {
                                              return Color(0xFF95A5A5);
                                            }
                                            return Colors.white;
                                          }),
                                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
                                          side: WidgetStateProperty.all(_msgIndex != _messages.length ? BorderSide(color: Colors.white, width: 2.5) : BorderSide(color: Color(0xFF95A5A5), width: 1.25)),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)
                                            )
                                          ),
                                          elevation: WidgetStateProperty.all(0),
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(_msgIndex == _messages.length ? 'Terminado' : 'Próximo →', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        ),
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
                              SizedBox(height: MediaQuery.of(context).size.height / 16),
                              Image(
                                image: MemoryImage(imageBytes),
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
              SizedBox(height: 20),
            ],
                    ),
          );
        }
      )
    );
  }
}