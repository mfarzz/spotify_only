import 'package:flutter/material.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

class SpotifyAuthProvider extends ChangeNotifier {
  // Use the singleton AuthService instance
  final AuthService _authService = AuthService();
  
  // Internal state
  bool _isLoading = false;
  String? _error;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.currentUser != null;
  SpotifyAuthModel? get authData => _authService.currentUser;
  
  // Initialize provider and listen to auth changes
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Initialize the auth service
      await _authService.initialize();
      
      // Set up listener for auth changes
      AuthService.userStream.listen((user) {
        // Notify listeners when auth state changes
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Login method
  Future<bool> login() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Use the AuthService's loginWithSpotify method
      final success = await _authService.loginWithSpotify();
      
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
  
  // Logout method
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get access token for API calls
  String? getAccessToken() {
    return _authService.getAccessToken();
  }
}