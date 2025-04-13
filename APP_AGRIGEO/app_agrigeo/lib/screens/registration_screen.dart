import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:app_agrigeo/screens/user_model.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedRole;
  bool _isFarmer = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _farmController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond animé
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/farm_bg.jpg',
              fit: BoxFit.cover,
            ).animate().fade(duration: 1.seconds),
          ),

          // Overlay semi-transparent
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 50),

                  // Titre animé
                  Text(
                    'Rejoindre INNOV GIS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.5),

                  SizedBox(height: 30),

                  // Carte de formulaire
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        children: [
                          // Sélection du rôle
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Vous êtes...',
                              prefixIcon: Icon(Icons.person_outline,
                                  color: Colors.green[800]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'farmer',
                                child: Text('Agriculteur/Fermier'),
                              ),
                              DropdownMenuItem(
                                value: 'visitor',
                                child: Text('Visiteur'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value;
                                _isFarmer = value == 'farmer';
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Veuillez sélectionner un rôle';
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 500.ms),

                          SizedBox(height: 20),

                          // Nom Complet
                          _buildTextField(
                            controller: _nameController,
                            label: 'Nom Complet',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est obligatoire';
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 700.ms),

                          SizedBox(height: 20),

                          // Email
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 900.ms),

                          SizedBox(height: 20),

                          // Téléphone
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Téléphone',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est obligatoire';
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 1.1.seconds),

                          // Champs spécifiques aux agriculteurs
                          if (_isFarmer) ...[
                            SizedBox(height: 20),

                            // Nom de la Ferme
                            _buildTextField(
                              controller: _farmController,
                              label: 'Nom de votre Ferme',
                              icon: Icons.agriculture,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champ est obligatoire pour les agriculteurs';
                                }
                                return null;
                              },
                            ).animate().fadeIn(delay: 1.3.seconds),

                            SizedBox(height: 20),

                            // Localisation
                            _buildTextField(
                              controller: _locationController,
                              label: 'Localisation de la ferme',
                              icon: Icons.location_on,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ce champ est obligatoire pour les agriculteurs';
                                }
                                return null;
                              },
                            ).animate().fadeIn(delay: 1.5.seconds),
                          ],

                          SizedBox(height: 30),

                          // Bouton d'inscription
                          ElevatedButton(
                            onPressed: () => _submitForm(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              padding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'S\'inscrire',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                              .animate()
                              .fadeIn(
                                  delay: _isFarmer ? 1.7.seconds : 1.3.seconds)
                              .scale(),
                        ],
                      ),
                    ),
                  ).animate().shake(delay: 2.seconds),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final userModel = Provider.of<UserModel>(context, listen: false);

      // Enregistrement des données utilisateur
      userModel.setUser(
        _nameController.text,
        role: _selectedRole!,
        email: _emailController.text,
        phone: _phoneController.text,
        farmName: _isFarmer ? _farmController.text : null,
        location: _isFarmer ? _locationController.text : null,
      );

      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
