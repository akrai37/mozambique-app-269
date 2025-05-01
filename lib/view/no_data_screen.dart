import 'package:flutter/material.dart';

class NoDataScreen extends StatelessWidget {
  const NoDataScreen({super.key});

  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
                  padding: EdgeInsets.symmetric(horizontal: 90.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, // aligns the children to the start (left) of the row
                    children: [
                      Text(
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
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
        ],
      ),
    );
  }
}