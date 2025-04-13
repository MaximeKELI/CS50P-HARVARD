import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_agrigeo/screens/user_model.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Paramètres')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Mode Sombre'),
            value: false,
            onChanged: (value) {},
          ),
          ListTile(
            title: Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () {
              Provider.of<UserModel>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}