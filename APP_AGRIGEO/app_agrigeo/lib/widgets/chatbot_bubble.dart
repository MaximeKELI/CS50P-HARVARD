import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatbotBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatbotBubble({required this.text, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(text, speed: Duration(milliseconds: 50)),
          ],
          totalRepeatCount: 1,
        ),
      ),
    );
  }
}
