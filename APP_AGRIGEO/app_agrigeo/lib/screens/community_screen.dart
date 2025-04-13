import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  final List<String> discussions = [
    "Comment optimiser l'irrigation ?",
    "Meilleurs engrais pour le maïs",
    "Problèmes de ravageurs, solutions ?",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Communauté Agricole")),
      body: ListView.builder(
        itemCount: discussions.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(discussions[index]),
              trailing: Icon(Icons.comment),
            ),
          );
        },
      ),
    );
  }
}
