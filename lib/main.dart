import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:mozambique_app/view/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mozambique_app/firebase_options.dart';

import 'package:mozambique_app/view/prac_convo.dart';
import 'package:mozambique_app/model/conversation.dart';
import 'package:mozambique_app/model/home_word.dart';
import 'package:mozambique_app/model/question.dart';
import 'package:mozambique_app/model/quiz.dart';
import 'package:mozambique_app/model/vocab.dart';
import 'package:mozambique_app/services/database_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the orientation of the app to landscape
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //INITIALIZE HIVE
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  // Register Hive Adapters
  Hive.registerAdapter(VocabWordAdapter());
  Hive.registerAdapter(HomeWordAdapter());
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(ResponseAdapter());
  Hive.registerAdapter(QuizQuestionAdapter());
  Hive.registerAdapter(QuizAnswerAdapter());
  Hive.registerAdapter(ConversationAdapter());
  Hive.registerAdapter(ConvoLineAdapter());

  // Open Hive Boxes (key-value store/container)
  // MAKE SURE TO OPEN AS List NOT AS List<VocabWord>
  await Hive.openBox<List>('vocab_words'); // storing vocab words as a list
  await Hive.openBox<List>('home_words');
  await Hive.openBox<List>('questions');
  await Hive.openBox<List>('quiz_questions');
  await Hive.openBox<List>('quiz_answers');
  await Hive.openBox<List>('conversations');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mozambique App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'AvenirLTStd', // default font
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseService dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load data from Hive or fetch from Firestore (if needed)
      await dbService.initializeDatabase(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    //return PracConvo(title: "Saudações", tag: "Greetings");
    //return PracConvo(title: "Pedidos", tag: "requests");
    return PracConvo(title: "Interações Pessoais", tag: "personalInteractions");
  }
}
