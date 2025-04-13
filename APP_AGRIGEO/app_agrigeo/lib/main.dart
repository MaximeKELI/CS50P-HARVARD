import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:app_agrigeo/utils/theme.dart';
import 'package:app_agrigeo/screens/about_us_screen.dart';
import 'package:app_agrigeo/screens/home_screen.dart';
import 'package:app_agrigeo/screens/map_screen.dart';
import 'package:app_agrigeo/screens/registration_screen.dart';
import 'package:app_agrigeo/screens/settings_screen.dart';
import 'package:app_agrigeo/screens/user_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialisé avec succès");
  } catch (e) {
    print("Erreur Firebase: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
      ],
      child: AgriGeoApp(),
    ),
  );
}

class AgriGeoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder(
          future: Provider.of<UserModel>(context, listen: false).loadUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final user = Provider.of<UserModel>(context);
              return user.name != null ? MainScreen() : RegistrationScreen();
            }
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        ),
        '/about': (context) => AboutUsScreen(),
        '/main': (context) => MainScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    MapScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
        ],
      ),
    );
  }
}