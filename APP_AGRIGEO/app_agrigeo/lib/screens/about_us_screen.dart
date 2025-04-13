import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            // Logo animé
            Hero(
              tag: 'logo',
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: SvgPicture.asset(
                  'lib/assets/images/logo_innov_gis.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 30),
            
            // Titre avec animation
            TweenAnimationBuilder(
              duration: Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: value,
                    child: child,
                  ),
                );
              },
              child: Text(
                'INNOV GIS - L\'Avenir de l\'Agriculture Intelligente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
            SizedBox(height: 30),
            
            // Section Mission avec icône animée
            _buildAnimatedCard(
              icon: Icons.rocket_launch,
              title: 'Notre Mission',
              content: '''
Transformer l'agriculture traditionnelle en agriculture de précision grâce à nos solutions innovantes. 

Nous combinons géomatique, intelligence artificielle et IoT pour optimiser chaque parcelle cultivable, réduire les intrants et maximiser les rendements tout en préservant l'environnement.
              ''',
              color: Colors.green,
            ),
            SizedBox(height: 20),
            
            // Section Valeurs
            _buildAnimatedCard(
              icon: Icons.star,
              title: 'Nos Valeurs',
              content: '''
• Innovation continue
• Durabilité environnementale
• Partenariat avec les agriculteurs
• Excellence technologique
• Adaptation aux besoins locaux
              ''',
              color: Colors.amber[700]!,
            ),
            SizedBox(height: 20),
            
            // Section Équipe interactive
            _buildTeamSection(),
            SizedBox(height: 20),
            
            // Section Partenaires
            _buildPartnersSection(),
            SizedBox(height: 20),
            
            // Formulaire de contact
            _buildContactForm(context),
            
            // Bouton réseaux sociaux
            _buildSocialMediaButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({required IconData icon, required String title, required String content, required Color color}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TweenAnimationBuilder(
              duration: Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.rotate(
                  angle: value * 6.28, // 2*PI radians
                  child: child,
                );
              },
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 10),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Text(
          'Notre Équipe d\'Experts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        leading: Icon(Icons.people_alt, color: Colors.blue[800]),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildTeamMember(
                  'Mr Maxime Dzidula KELI',
                  'Geomaticien:Developpeur d\'application geospatial',
                  'developpeur d\'application',
                  Icons.school,
                ),
                Divider(),
                _buildTeamMember(
                  'Ing. Jean Francois',
                  'Ingénieure en Géomatique',
                  'Expert SIG et télédétection',
                  Icons.map,
                ),
                Divider(),
                _buildTeamMember(
                  'Tech. Elie',
                  'Développeur Full-Stack',
                  'Spécialiste IoT et solutions mobiles',
                  Icons.code,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String title, String specialty, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Text(
            specialty,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Nos Partenaires Stratégiques',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
            SizedBox(height: 15),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildPartnerLogo('lib/assets/images/cnra_logo.png'),
                _buildPartnerLogo('lib/assets/images/ci_logo.png'),
                _buildPartnerLogo('lib/assets/images/fao_logo.png'),
                _buildPartnerLogo('lib/assets/images/afd_logo.png'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerLogo(String path) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Image.asset(path),
      ),
    );
  }

  Widget _buildContactForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _messageController = TextEditingController();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Contactez Notre Équipe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Votre Nom',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Votre Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Votre Message',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Envoyer le formulaire
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Message envoyé avec succès!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _nameController.clear();
                    _emailController.clear();
                    _messageController.clear();
                  }
                },
                icon: Icon(Icons.send),
                label: Text('Envoyer le Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: SvgPicture.asset(
              'lib/assets/images/facebook.svg',
              width: 30,
              height: 30,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 15),
          IconButton(
            icon: SvgPicture.asset(
              'lib/assets/images/twitter.svg',
              width: 30,
              height: 30,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 15),
          IconButton(
            icon: SvgPicture.asset(
              'lib/assets/images/linkedin.svg',
              width: 30,
              height: 30,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 15),
          IconButton(
            icon: SvgPicture.asset(
              'lib/assets/images/youtube.svg',
              width: 30,
              height: 30,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}