import 'package:flutter/material.dart';
import 'package:mozambique_app/view/logos.dart';
import 'package:mozambique_app/view/navbar.dart';

class NoConnectionScreen extends StatelessWidget {
  final bool hasContent;

  const NoConnectionScreen({
    super.key,
    this.hasContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final String noContentText = "Welcome! It looks like you're not connected to the internet yet. This app needs an internet connection the first time you open it so we can load all the content, images, and features that make your experience complete. To get started, please connect your device to Wi-Fi or cellular data, then close and reopen the app.\n\n"
                                "Bem-vindo! Parece que você ainda não está conectado à internet. Este aplicativo precisa de uma conexão com a internet na primeira vez que você o abrir para que possamos carregar todo o conteúdo, images e recursos que tornam sua experiência completa. Para começar, conecte seu dispositivo ao Wi-Fi ou aos dados móveis e, em sequida, feche e abra o aplicativo novamente.";
    final String hasContentText = "No momento, você está offline, então não foi possível baixar as atualizações mais recentes. Conecte-se à internet para obter novos conteúdos e melhorias.";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasContent)
            Navbar(onSearchChanged: (test) {}, isPractice: false),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: hasContent ? 4.0 : 40.0),
            child: Row(
              mainAxisAlignment: hasContent ? MainAxisAlignment.start : MainAxisAlignment.center, // center the text horizontally
              children: [
                Text(
                  hasContent ? 'Atualizações Disponíveis' : 'Vamos Começar',
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3E50),
                  ),
                ),
              ],
            ),
          ),

          // Text
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      hasContent ? hasContentText : noContentText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3E50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Logos
          Logos(),
        ],
      ),
    );
  }
}