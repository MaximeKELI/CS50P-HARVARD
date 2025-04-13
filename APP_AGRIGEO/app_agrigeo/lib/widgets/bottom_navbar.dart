import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Tableau de Bord"),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "Cartographie"),
        BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Météo"),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chatbot"),
      ],
    );
  }
}
