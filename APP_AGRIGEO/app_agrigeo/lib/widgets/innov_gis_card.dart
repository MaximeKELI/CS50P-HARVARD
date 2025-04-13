import 'package:flutter/material.dart';

class InnovGisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'À propos de INNOV GIS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Spécialiste des technologies géospatiales et de l\'IA appliquées à l\'agriculture de précision depuis 2015.',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 15),
            Divider(),
            SizedBox(height: 10),
            _buildInfoRow(Icons.email, 'innovgis025@gmail.com'),
            _buildInfoRow(Icons.phone, '(+225) 056434333'),
            _buildInfoRow(Icons.web, 'www.innovgis.org'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green[700]),
          SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}