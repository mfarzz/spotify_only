import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../config/spotify_config.dart';
import '../models/auth_model.dart';

class SpotifyAuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _authTokenKey = 'spotify_auth_token';
  
  // Memulai proses autentikasi
  Future<SpotifyAuthModel?> authenticate() async {
    try {
      // Membuat URL untuk autentikasi
      final authUri = Uri.parse(SpotifyConfig.authUrl).replace(
        queryParameters: {
          'client_id': SpotifyConfig.clientId,
          'response_type': 'code',
          'redirect_uri': SpotifyConfig.redirectUri,
          'scope': SpotifyConfig.scopesString,
          'show_dialog': 'true',
        },
      );

      // Luncurkan browser untuk autentikasi
      final result = await FlutterWebAuth2.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: SpotifyConfig.redirectUri.split('://')[0],
      );

      // Ekstrak kode dari URI callback
      final code = Uri.parse(result).queryParameters['code'];
      
      if (code != null) {
        // Tukar kode dengan token
        return await _getTokenFromCode(code);
      }
      
      return null;
    } catch (e) {
      print('Authentication error: $e');
      return null;
    }
  }

  // Mendapatkan token dari kode yang diperoleh
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

  // Menyegarkan token yang sudah kedaluwarsa
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
        
        // Response from refresh token doesn't include refresh_token, so we add it
        if (!responseData.containsKey('refresh_token')) {
          responseData['refresh_token'] = refreshToken;
        }
        
        final authModel = SpotifyAuthModel.fromJson(responseData);
        await _saveAuthToken(authModel);
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

  // Simpan token ke secure storage
  Future<void> _saveAuthToken(SpotifyAuthModel authModel) async {
    await _secureStorage.write(
      key: _authTokenKey, 
      value: json.encode(authModel.toJson()),
    );
  }

  // Ambil token yang tersimpan
  Future<SpotifyAuthModel?> getSavedAuthToken() async {
    final tokenJson = await _secureStorage.read(key: _authTokenKey);
    if (tokenJson != null) {
      final tokenMap = json.decode(tokenJson);
      final authModel = SpotifyAuthModel.fromJson(tokenMap);
      
      // Jika token sudah kedaluwarsa, refresh token
      if (authModel.isExpired) {
        return await refreshToken(authModel.refreshToken);
      }
      
      return authModel;
    }
    return null;
  }

  // Logout: hapus token tersimpan
  Future<void> logout() async {
    await _secureStorage.delete(key: _authTokenKey);
  }
}