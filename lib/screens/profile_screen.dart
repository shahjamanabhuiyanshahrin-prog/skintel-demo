import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart'; // TODO: class name LoginScreen na hole change koro

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: FutureBuilder<Map<String, String>>(
        future: ApiService().getProfile(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data!;
          return ListView(padding: const EdgeInsets.all(16), children: [
            const SizedBox(height: 8),
            CircleAvatar(
                radius: 40,
                backgroundColor: Colors.brown.shade300,
                child: Text(p['name']![0],
                    style: const TextStyle(fontSize: 28, color: Colors.white))),
            const SizedBox(height: 12),
            Center(
                child: Text(p['name']!,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700))),
            Center(child: Text(p['email']!)),
            const SizedBox(height: 24),
            _tile(Icons.face_retouching_natural, 'Skin type', p['skin']!),
            _tile(Icons.history, 'Scan history', ''),
            _tile(Icons.settings_outlined, 'Settings', ''),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24))),
              onPressed: () {
                // TODO: auth_service logout call
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false);
              },
              child: const Text('Log out'),
            ),
          ]);
        },
      ),
    );
  }

  Widget _tile(IconData i, String t, String v) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: const Color(0xFFF5EFEC),
            borderRadius: BorderRadius.circular(10)),
        child: ListTile(
            leading: Icon(i, color: Colors.black),
            title: Text(t, style: const TextStyle(fontSize: 13)),
            trailing: Text(v, style: const TextStyle(fontSize: 11))),
      );
}
