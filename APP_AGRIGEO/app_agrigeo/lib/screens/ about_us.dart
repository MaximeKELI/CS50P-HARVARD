import 'package:flutter/material.dart';
import 'package:app_agrigeo/screens/home_screen.dart'; // Import modifié

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec espace pour logo
            Container(
              height: 200,
              color: Colors.green[800],
              padding: EdgeInsets.all(20),
              child: Center(
                child: Image.asset('lib/assets/images/logo.jpeg', height: 100),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Bienvenue chez INNOV GIS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text('Accéder à l\'application'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/main');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}