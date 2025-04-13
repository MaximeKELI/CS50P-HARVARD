import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:app_agrigeo/screens/user_model.dart';
import 'package:app_agrigeo/screens/dashboard_screen.dart';
import 'package:app_agrigeo/screens/cartography_screen.dart';
import 'package:app_agrigeo/screens/weather_screen.dart';
import 'package:app_agrigeo/screens/chatbot_screen.dart';
import 'package:app_agrigeo/screens/community_screen.dart';
import 'package:app_agrigeo/screens/ai_analysis_screen.dart';
import 'package:app_agrigeo/screens/irrigation_screen.dart';
import 'package:app_agrigeo/screens/about_us_screen.dart';
import 'package:app_agrigeo/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
  final GlobalKey<CartographyScreenState> _cartographyKey = GlobalKey();

  // Écrans disponibles
  late final List<Widget> _screens;
  final List<String> _screenTitles = [
    'Tableau de bord',
    'Cartographie',
    'Météo',
    'Chatbot IA',
    'Communauté',
    'Analyse IA',
    'Irrigation',
    'À Propos'
  ];

  // Animations
  late AnimationController _cloudController;
  late Animation<double> _cloudAnimation;
  late AnimationController _sunController;
  late Animation<double> _sunAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initScreens();
    _setupAnimations();
  }

  void _initScreens() {
    _screens = [
      DashboardScreen(),
      CartographyScreen(key: _cartographyKey),
      WeatherScreen(),
      ChatbotScreen(),
      CommunityScreen(),
      AIAnalysisScreen(),
      IrrigationScreen(),
      AboutUsScreen(),
    ].animate(delay: 300.ms).fadeIn(duration: 500.ms);
  }

  void _setupAnimations() {
    // Animation des nuages (30 secondes pour traverser l'écran)
    _cloudController = AnimationController(
      duration: 30.seconds,
      vsync: this,
    )..repeat();

    _cloudAnimation =
        Tween(begin: -200.0, end: 500.0).animate(_cloudController);

    // Animation du soleil (pulsation douce)
    _sunController = AnimationController(
      duration: 15.seconds,
      vsync: this,
    )..repeat(reverse: true);

    _sunAnimation = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _sunController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _cloudController.stop();
      _sunController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _cloudController.repeat();
      _sunController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cloudController.dispose();
    _sunController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final isLoggedIn = user.name != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        backgroundColor: Colors.green[800],
        elevation: 0,
        actions: [
          if (isLoggedIn) _buildUserAvatar(user),
          ..._buildAppBarActions(),
        ],
      ),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _screens[_selectedIndex],
        ],
      ),
      drawer: _buildAppDrawer(user),
    );
  }

  Widget _buildUserAvatar(UserModel user) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.2),
        child: Text(
          user.name!.substring(0, 1).toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
      ).animate().scale(),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      if (_selectedIndex == 1)
        IconButton(
          icon: Icon(Icons.gps_fixed, color: Colors.white),
          onPressed: () => _cartographyKey.currentState?.centerToLocation(),
          tooltip: 'Centrer sur ma position',
        ).animate().fadeIn(delay: 200.ms),
    ];
  }

  Widget _buildAnimatedBackground() {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Soleil animé
            Positioned(
              top: 50,
              right: 50,
              child: ScaleTransition(
                scale: _sunAnimation,
                child: Icon(
                  Icons.wb_sunny,
                  color: Colors.yellow[700]?.withOpacity(0.2),
                  size: 150,
                ),
              ),
            ),

            // Nuages animés
            _buildAnimatedCloud(100, 120, 0.1),
            _buildAnimatedCloud(200, 150, 0.15, offset: -300),

            // Dégradé de fond
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green[800]!.withOpacity(0.1),
                      Colors.green[500]!.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCloud(double top, double size, double opacity,
      {double offset = 0}) {
    return AnimatedBuilder(
      animation: _cloudAnimation,
      builder: (_, __) {
        return Positioned(
          top: top,
          left: _cloudAnimation.value + offset,
          child: Icon(
            Icons.cloud,
            color: Colors.white.withOpacity(opacity),
            size: size,
          ),
        );
      },
    );
  }

  Widget _buildAppDrawer(UserModel user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(user),
          ..._buildDrawerItems(),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Paramètres'),
            onTap: () => _navigateToSettings(context),
          ),
          if (user.name != null)
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Déconnexion'),
              onTap: () => _logout(context),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(UserModel user) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.green[800],
        image: DecorationImage(
          image: AssetImage('assets/images/agriculture_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.green[800]!.withOpacity(0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (user.name != null)
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Text(
                user.name!.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.green[800],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          SizedBox(height: 12),
          Text(
            'INNOV GIS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            user.name != null
                ? 'Bienvenue, ${user.name!.split(' ')[0]}'
                : 'Agriculture Intelligente',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return List.generate(_screens.length, (index) {
      final icon = _getIconForIndex(index);
      return ListTile(
        leading: Icon(icon, color: _getIconColor(index)),
        title: Text(
          _screenTitles[index],
          style: TextStyle(
            color: _getTextColor(index),
            fontWeight: _getFontWeight(index),
          ),
        ),
        onTap: () => _onDrawerItemTap(index),
      );
    });
  }

  void _onDrawerItemTap(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context);
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  void _logout(BuildContext context) async {
    await Provider.of<UserModel>(context, listen: false).logout();
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  // Helpers
  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.map;
      case 2:
        return Icons.cloud;
      case 3:
        return Icons.chat;
      case 4:
        return Icons.people;
      case 5:
        return Icons.analytics;
      case 6:
        return Icons.water;
      case 7:
        return Icons.info;
      default:
        return Icons.error;
    }
  }

  Color _getIconColor(int index) {
    return _selectedIndex == index ? Colors.green[800]! : Colors.grey[700]!;
  }

  Color _getTextColor(int index) {
    return _selectedIndex == index ? Colors.green[800]! : Colors.black;
  }

  FontWeight _getFontWeight(int index) {
    return _selectedIndex == index ? FontWeight.bold : FontWeight.normal;
  }
}
