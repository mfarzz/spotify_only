import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyConfig {
  static String get clientId => dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  static String get clientSecret => dotenv.env['SPOTIFY_CLIENT_SECRET'] ?? '';
  static String get redirectUri => dotenv.env['SPOTIFY_REDIRECT_URI'] ?? '';
  
  static const String authUrl = 'https://accounts.spotify.com/authorize';
  static const String tokenUrl = 'https://accounts.spotify.com/api/token';
  static const String apiBaseUrl = 'https://api.spotify.com/v1';
  
  static const List<String> scopes = [
    'user-read-private',
    'user-read-email',
    'user-library-read',
    // Tambahkan scope lain sesuai kebutuhan
  ];
  
  static String get scopesString => scopes.join(' ');
}