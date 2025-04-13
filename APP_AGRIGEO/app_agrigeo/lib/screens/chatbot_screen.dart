import 'package:flutter/material.dart';
import 'package:app_agrigeo/widgets/chatbot_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<Map<String, dynamic>> messages = [
    {"text": "Bonjour ! Comment puis-je vous aider ?", "isUser": false},
  ];

  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    setState(() {
      messages.add({"text": _controller.text, "isUser": true});
    });

    _controller.clear();

    // Simuler une réponse de l'IA avec un délai
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        messages.add({"text": "Réponse IA en cours...", "isUser": false});
      });

      // Remplacer la réponse simulée par une véritable réponse
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          messages[messages.length - 1] = {"text": "Je suis là pour vous aider !", "isUser": false};
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatbot IA")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatbotBubble(
                  text: messages[index]["text"],
                  isUser: messages[index]["isUser"],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
