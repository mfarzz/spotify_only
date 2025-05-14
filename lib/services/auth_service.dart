import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../config/spotify_config.dart';
import '../models/auth_model.dart';

class AuthService extends ChangeNotifier {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Secure storage for tokens
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _authTokenKey = 'spotify_auth_token';
  
  // Stream controller for user auth state
  static final StreamController<SpotifyAuthModel?> _userStreamController = 
      StreamController<SpotifyAuthModel?>.broadcast();
  
  // Stream for listening to auth changes
  static Stream<SpotifyAuthModel?> get userStream => _userStreamController.stream;
  
  // Current user data
  SpotifyAuthModel? _currentUser;
  SpotifyAuthModel? get currentUser => _currentUser;

  // Initialize auth state
  Future<void> initialize() async {
    // Check for existing auth token
    final savedToken = await getSavedAuthToken();
    _currentUser = savedToken;
    _userStreamController.add(_currentUser);
  }

  // Login with Spotify OAuth
  Future<bool> loginWithSpotify() async {
    try {
      // Create authorization URL
      final authUri = Uri.parse(SpotifyConfig.authUrl).replace(
        queryParameters: {
          'client_id': SpotifyConfig.clientId,
          'response_type': 'code',
          'redirect_uri': SpotifyConfig.redirectUri,
          'scope': SpotifyConfig.scopesString,
          'show_dialog': 'true',
        },
      );

      // Launch browser for authentication
      final result = await FlutterWebAuth2.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: SpotifyConfig.redirectUri.split('://')[0],
      );

      // Extract code from callback URI
      final code = Uri.parse(result).queryParameters['code'];
      
      if (code != null) {
        // Exchange code for token
        final authModel = await _getTokenFromCode(code);
        if (authModel != null) {
          _currentUser = authModel;
          _userStreamController.add(_currentUser);
          notifyListeners();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  // Get token from authorization code
  Future<SpotifyAuthModel?> _getTokenFromCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse(SpotifyConfig.tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('${SpotifyConfig.clientId}:${SpotifyConfig.clientSecret}'))}',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': SpotifyConfig.redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final authModel = SpotifyAuthModel.fromJson(json.decode(response.body));
        await _saveAuthToken(authModel);
        return authModel;
      } else {
        print('Token request failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Token exchange error: $e');
      return null;
    }
  }

  // Refresh expired token
  Future<SpotifyAuthModel?> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(SpotifyConfig.tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('${SpotifyConfig.clientId}:${SpotifyConfig.clientSecret}'))}',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Add refresh token if not included in response
        if (!responseData.containsKey('refresh_token')) {
          responseData['refresh_token'] = refreshToken;
        }
        
        final authModel = SpotifyAuthModel.fromJson(responseData);
        await _saveAuthToken(authModel);
        
        // Update current user and notify listeners
        _currentUser = authModel;
        _userStreamController.add(_currentUser);
        notifyListeners();
        
        return authModel;
      } else {
        print('Token refresh failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Token refresh error: $e');
      return null;
    }
  }

  // Save token to secure storage
  Future<void> _saveAuthToken(SpotifyAuthModel authModel) async {
    await _secureStorage.write(
      key: _authTokenKey, 
      value: json.encode(authModel.toJson()),
    );
  }

  // Get saved token
  Future<SpotifyAuthModel?> getSavedAuthToken() async {
    final tokenJson = await _secureStorage.read(key: _authTokenKey);
    if (tokenJson != null) {
      final tokenMap = json.decode(tokenJson);
      final authModel = SpotifyAuthModel.fromJson(tokenMap);
      
      // Refresh token if expired
      if (authModel.isExpired) {
        return await refreshToken(authModel.refreshToken);
      }
      
      return authModel;
    }
    return null;
  }

  // Logout - clear stored tokens
  Future<void> logout() async {
    await _secureStorage.delete(key: _authTokenKey);
    _currentUser = null;
    _userStreamController.add(_currentUser);
    notifyListeners();
  }
  
  // Get access token for API requests
  String? getAccessToken() {
    // If no authenticated user
    if (_currentUser == null) return null;
    
    // If token expired, trigger refresh (but still return null)
    if (_currentUser!.isExpired) {
      refreshToken(_currentUser!.refreshToken);
      return null;
    }
    
    // Return valid token
    return _currentUser!.accessToken;
  }
  
  // Dispose resources properly
  void dispose() {
    _userStreamController.close();
  }
}