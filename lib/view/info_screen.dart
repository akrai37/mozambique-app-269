import 'package:flutter/material.dart';
import 'package:mozambique_app/services/database_service.dart';
import 'package:mozambique_app/view/navbar.dart';
import 'package:mozambique_app/view/logos.dart';
import 'package:mozambique_app/view/sync_progress_dialog.dart';


class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final List<String> _infoList = [ // List of information paragraphs
    'This app was created to help Mozambican mothers in the DIFF EDUCATION program learn Portuguese. It was developed by undergraduate students at Santa Clara University between May 2024 and June 2025. The project was a partnership with the DIFF EDUCATION non-profit in Mozambique and the Frugal Innovation Hub at SCU.',
    'The goal was to design a simple, accessible language learning tool for mothers with little or no experience with reading or using technology. The app uses visuals and audio instead of text to support learning. It was made to work offline so it can be used in areas with poor or no internet access.',
    'This app is meant to be used in group settings with a moderator. It does not require individual logins or personal devices. Exercises give immediate feedback to help learners stay engaged and understand quickly.',
    'The vocabulary focuses on words used in daily life, especially in the context of parenting and caregiving. The design and content reflect the local culture to make it more relatable and effective.',
    'By focusing on low literacy, limited tech experience, and unreliable internet, this app offers a practical way for mothers in rural Mozambique to begin learning Portuguese. It supports group learning, encourages participation, and helps build confidence in everyday communication.',
    'Este aplicativo foi criado para ajudar mães moçambicanas no programa DIFF EDUCATION a aprender português. Foi desenvolvido na Universidade de Santa Clara entre maio de 2024 e junho de 2025. O projeto foi uma parceria com a organização sem fins lucrativos DIFF EDUCATION em Moçambique e o Frugal Innovation Hub da SCU.',
    'O objetivo era criar uma ferramenta de aprendizado de idiomas simples e acessível para mães com pouca ou nenhuma experiência em leitura ou uso de tecnologia. O aplicativo usa recursos visuais e áudio em vez de texto para apoiar o aprendizado do idioma. Ele foi feito para funcionar offline, para que possa ser usado em áreas com acesso à internet precário ou inexistente.',
    'Este aplicativo destina-se ao uso em grupo com um moderador. Não requer logins individuais ou dispositivos pessoais. Os exercícios fornecem feedback imediato para ajudar os alunos a se manterem engajados e a compreenderem rapidamente.',
    'O vocabulário concentra-se em palavras usadas no dia a dia, especialmente no contexto da parentalidade e dos cuidados com os filhos. O design e o conteúdo refletem a cultura local para torná-lo mais acessível e eficaz.',
    'Com foco em baixa alfabetização, experiência tecnológica limitada e internet instável, este aplicativo oferece uma maneira prática para mães em áreas rurais de Moçambique começarem a aprender português. Ele apoia o aprendizado em grupo, incentiva a participação e ajuda a construir confiança na comunicação diária.',
  ];
  final DatabaseService _databaseService = DatabaseService();
  bool _didSync = false; // Flag to check if sync has been done

  void _onSyncButtonPressed() async {
    // Check internet connection before syncing
    bool hasInternet = await _databaseService.checkInternetConnection();

    if (!hasInternet) { // Handle inside syncContent
      _didSync = await _databaseService.syncContent(context: context);
      return;
    }

    late void Function(double) updateProgress; // Function to update progress in the dialog

    // Show loading dialog while syncing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double progress = 0.0; // Initialize progress variable

        return PopScope( // Disable back button while syncing
          canPop: false, // Prevent default behavior of back button
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor aguarde...'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              updateProgress = (double value) { // Update progress function definition
                setState(() {
                  progress = value; // Update progress variable
                });
              };

              return SyncProgressDialog(progress: progress);
            }
          ),
        );
      },
    );

    _didSync = await _databaseService.syncContent(
      context: context,
      onProgress: (double value) {
        updateProgress(value); // Update progress in the dialog
      },
    );

    // Wait for a second to show the progress bar has completed
    await Future.delayed(const Duration(seconds: 1));

    // Close the dialog after syncing
    if (context.mounted) Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar( // Show success or error message based on sync result
        content: _didSync
          ? const Text('Dados atualizados com sucesso!')
          : const Text('Erro ao atualizar os dados!'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default behavior of back button
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _didSync); // Pass the sync status back to the previous screen
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Navbar(
              isPractice: false,
              onSearchChanged: (temp) {},
              isInfoScreen: true, // Pass the isInfoScreen flag to Navbar,
              onBack: () {
                Navigator.pop(context, _didSync); // Pass the sync status back to the previous screen
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [  
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start, // aligns the children to the start (left) of the row
                        children: [
                          const Text(
                            'Information',
                            style: TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3E50),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Paragraphs
                    ..._infoList.map((paragraph) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RichText(
                          text: TextSpan(
                            text: paragraph,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2D3E50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),

                    // Logos
                    Logos(),
  
                    // For Moderators: [Sync Button]
                    Row(
                      children: [
                        Text(
                          'Para moderadores:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3E50),
                          ),
                        ),
                        SizedBox(width: 10),
                        TextButton( // border radius 5px
                          onPressed: _onSyncButtonPressed,
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // border radius 5px
                              side: BorderSide(color: Color(0xFF2D3E50), width: 2),
                            ),
                            backgroundColor: Color(0xFFECF0F1),
                          ),
                          child: Text(
                            'Atualizar aplicativo',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3E50),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        )
      ),
    );
  }
}