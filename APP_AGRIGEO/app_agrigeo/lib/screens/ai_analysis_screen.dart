import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:app_agrigeo/screens/user_model.dart';

class AIAnalysisScreen extends StatefulWidget {
  @override
  _AIAnalysisScreenState createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  bool _isScanning = false;
  File? _selectedImage;
  String? _analysisResult;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();
  final String _openAIKey =
      'YOUR_OPENAI_API_KEY'; // Remplacez par votre cl� API

  Future<void> _getImage(ImageSource source) async {
    setState(() {
      _isScanning = true;
      _analysisResult = null;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) {
        setState(() => _isScanning = false);
        return;
      }

      setState(() => _selectedImage = File(image.path));
      await _analyzeImageWithOpenAI(File(image.path));
    } catch (e) {
      setState(() {
        _isScanning = false;
        _errorMessage = "Erreur lors de l'analyse: ${e.toString()}";
      });
      _showErrorDialog(_errorMessage!);
    }
  }

  Future<void> _analyzeImageWithOpenAI(File imageFile) async {
    try {
      // Convertir l'image en base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Pr�parer la requ�te pour OpenAI
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIKey',
        },
        body: jsonEncode({
          "model": "gpt-4-vision-preview",
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text":
                      "Analyse cette image de culture agricole. D�tecte les "
                          "maladies, �value la sant� des plantes, et donne des "
                          "conseils d'entretien. Sois pr�cis et technique."
                },
                {
                  "type": "image_url",
                  "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
                }
              ]
            }
          ],
          "max_tokens": 1000
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final analysis = jsonResponse['choices'][0]['message']['content'];

        setState(() {
          _isScanning = false;
          _analysisResult = analysis;
        });
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('�chec de l\'analyse: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Erreur"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    if (_analysisResult == null) return SizedBox();

    return Column(
      children: [
        SizedBox(height: 20),
        Card(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "R�sultats d'analyse:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[800],
                  ),
                ),
                SizedBox(height: 10),
                Text(_analysisResult!),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _showDetailedAnalysis(context),
          child: Text("Voir l'analyse d�taill�e"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showDetailedAnalysis(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Analyse Compl�te",
            style: TextStyle(color: Colors.green[800])),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedImage != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                ),
              SizedBox(height: 15),
              if (user.isFarmer && user.farmName != null)
                Text("Ferme: ${user.farmName}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              Text(_analysisResult ?? "Aucun r�sultat disponible"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Fermer", style: TextStyle(color: Colors.green[800])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analyse IA des Cultures"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null && !_isScanning) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),
            ] else
              Lottie.asset(
                "assets/animations/ai_analysis.json",
                height: 200,
                fit: BoxFit.contain,
              ),
            SizedBox(height: 20),
            Text(
              _isScanning
                  ? "Analyse en cours avec OpenAI..."
                  : _analysisResult != null
                      ? "Analyse termin�e"
                      : "Choisissez une image � analyser",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            _buildAnalysisResult(),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      _isScanning ? null : () => _getImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text("Cam�ra"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _isScanning ? null : () => _getImage(ImageSource.gallery),
                  icon: Icon(Icons.photo_library),
                  label: Text("Galerie"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
