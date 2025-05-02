import 'package:flutter/material.dart';
import 'package:mozambique_app/view/logos.dart';

class NoDataScreen extends StatelessWidget {
  const NoDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 90.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // aligns the children to the start (left) of the row
              children: [
                const Text(
                  'Vamos Começar',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3E50),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 200, // height of the screen minus the height of the AppBar
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Welcome! It looks like you're not connected to the internet yet. This app needs an internet connection the first time you open it so we can load all the content, images, and features that make your experience complete. To get started, please connect your device to Wi-Fi or cellular data, then close and reopen the app.\n\n"
                      "Bem-vindo! Parece que você ainda não está conectado à internet. Este aplicativo precisa de uma conexão com a internet na primeira vez que você o abrir para que possamos carregar todo o conteúdo, images e recursos que tornam sua experiência completa. Para começar, conecte seu dispositivo ao Wi-Fi ou aos dados móveis e, em sequida, feche e abra o aplicativo novamente.",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Logos(),
        ],
      ),
    );
  }
}