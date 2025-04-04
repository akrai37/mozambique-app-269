import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:mozambique_app/view/home_screen.dart';
import 'package:mozambique_app/model/category.dart';
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
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(VocabWordAdapter());
  Hive.registerAdapter(HomeWordAdapter());
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(ResponseAdapter());
  Hive.registerAdapter(QuizQuestionAdapter());
  Hive.registerAdapter(QuizAnswerAdapter());
  Hive.registerAdapter(ConversationAdapter());

  // Open Hive Boxes (key-value store/container)
  await Hive.openBox<Category>('categories');
  // MAKE SURE TO OPEN AS List NOT AS List<VocabWord>
  await Hive.openBox<List>('vocab_words'); // storing vocab words as a list
  await Hive.openBox<List>('home_words');
  await Hive.openBox<Question>('questions');
  await Hive.openBox<Response>('responses');
  await Hive.openBox<QuizQuestion>('quiz_questions');
  await Hive.openBox<QuizAnswer>('quiz_answers');
  await Hive.openBox<Conversation>('conversations');

  // Load data from Hive or fetch from Firestore (if needed)
  final DatabaseService dbService = DatabaseService();
  await dbService.initializeDatabase();

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'AvenirLTStd', // set Avenir as the default font
      ),
      home: const MyHomePage(title: 'Mozambique App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return HomeScreen();
  }
}
