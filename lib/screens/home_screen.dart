import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/spotify_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  String _userEmail = '';
  String _profileImage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final authProvider = Provider.of<SpotifyAuthProvider>(context, listen: false);
    final accessToken = authProvider.getAccessToken();
    
    if (accessToken == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    try {
      final response = await http.get(
        Uri.parse('${SpotifyConfig.apiBaseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        setState(() {
          _userName = userData['display_name'] ?? '';
          _userEmail = userData['email'] ?? '';
          if (userData['images'] != null && userData['images'].isNotEmpty) {
            _profileImage = userData['images'][0]['url'];
          }
          _isLoading = false;
        });
      } else {
        print('Failed to fetch user data: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<SpotifyAuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<SpotifyAuthProvider>(
        builder: (ctx, authProvider, _) {
          if (!authProvider.isAuthenticated) {
            // Jika tidak terotentikasi, kembali ke login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            });
          }
          
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_profileImage.isNotEmpty)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_profileImage),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    _userName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (_userEmail.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      _userEmail,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // Tambahkan navigasi ke layar lain atau tampilkan data Spotify lainnya
                    },
                    child: const Text('View My Playlists'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}