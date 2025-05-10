import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Login'),
      ),
      body: Consumer<SpotifyAuthProvider>(
        builder: (ctx, authProvider, _) {
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (authProvider.isAuthenticated) {
            // Berhasil login, arahkan ke home screen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            });
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://developer.spotify.com/assets/branding-guidelines/icon3@2x.png',
                  height: 100,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: () => authProvider.login(),
                  child: const Text(
                    'Login with Spotify',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                if (authProvider.error != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    authProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}