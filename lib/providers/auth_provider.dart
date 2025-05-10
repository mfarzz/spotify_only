import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

class SpotifyAuthProvider extends ChangeNotifier {
  final SpotifyAuthService _authService = SpotifyAuthService();
  
  SpotifyAuthModel? _authData;
  bool _isLoading = false;
  String? _error;
  
  SpotifyAuthModel? get authData => _authData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authData != null;
  
  // Inisialisasi provider dengan mencoba memuat token tersimpan
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _authData = await _authService.getSavedAuthToken();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Memulai proses login
  Future<bool> login() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _authData = await _authService.authenticate();
      final success = _authData != null;
      
      if (!success) {
        _error = 'Failed to authenticate with Spotify';
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
      _authData = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Dapatkan token untuk API calls
  String? getAccessToken() {
    if (_authData == null) return null;
    
    // Jika token kedaluwarsa, refresh otomatis
    if (_authData!.isExpired) {
      _refreshToken();
      return null; // Return null karena refresh sedang berjalan
    }
    
    return _authData!.accessToken;
  }
  
  // Refresh token secara internal
  Future<void> _refreshToken() async {
    if (_authData == null) return;
    
    try {
      _authData = await _authService.refreshToken(_authData!.refreshToken);
      if (_authData == null) {
        _error = 'Failed to refresh token';
      }
    } catch (e) {
      _error = e.toString();
    }
    
    notifyListeners();
  }
}