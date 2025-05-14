// home_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/track_model.dart';
import '../models/playlist_model.dart';
import '../models/album_model.dart'; // Add this import for the Album model
import '../services/auth_service.dart';

class HomeProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  List<Track> _tracks = [];
  List<Playlist> _playlists = [];
  List<Album> _albums = []; // Changed from _featured to _albums with Album type
  bool _isLoadingTracks = false;
  bool _isLoadingPlaylists = false;
  bool _isLoadingAlbums = false; // Changed from _isLoadingFeatured to _isLoadingAlbums
  String? _error;

  // Getters
  List<Track> get tracks => _tracks;
  List<Playlist> get playlists => _playlists;
  List<Album> get albums => _albums; // Changed from featured to albums
  bool get isLoadingTracks => _isLoadingTracks;
  bool get isLoadingPlaylists => _isLoadingPlaylists;
  bool get isLoadingAlbums => _isLoadingAlbums; // Changed from isLoadingFeatured to isLoadingAlbums
  String? get error => _error;

  Future<void> fetchAllData() async {
    await Future.wait([
      _fetchRecentlyPlayed(),
      _fetchUserPlaylists(),
      _fetchUserAlbums(),
    ]);
  }

  Future<void> _fetchRecentlyPlayed() async {
    _isLoadingTracks = true;
    notifyListeners();

    try {
      final token = _authService.getAccessToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/player/recently-played?limit=10'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List items = json.decode(response.body)['items'];
        _tracks = items.map((item) => Track.fromJson(item)).toList();
      } else {
        _error = 'Failed to fetch tracks: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingTracks = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserPlaylists() async {
    _isLoadingPlaylists = true;
    notifyListeners();

    try {
      final token = _authService.getAccessToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/playlists?limit=10'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List items = json.decode(response.body)['items'];
        _playlists = items.map((item) => Playlist.fromJson(item)).toList();
      } else {
        _error = 'Failed to fetch playlists: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPlaylists = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserAlbums() async {
    _isLoadingAlbums = true;
    notifyListeners();

    try {
      final token = _authService.getAccessToken();
      if (token == null) return;

      // Fetch user's saved albums
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/albums?limit=2'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List items = json.decode(response.body)['items'];
        _albums = items.map((item) {
          final album = item['album'];
          return Album(
            id: album['id'],
            name: album['name'],
            imageUrl: album['images'].isNotEmpty ? album['images'][0]['url'] : '',
            artist: album['artists'].isNotEmpty ? album['artists'][0]['name'] : 'Unknown Artist',
          );
        }).toList();
      } else if (response.statusCode == 401) {
        // Token expired, should trigger refresh token flow here
        _error = 'Authentication error. Please log in again.';
      } else {
        // As a fallback, we can try to get new releases if user doesn't have saved albums
        await _fetchNewReleases();
      }
    } catch (e) {
      _error = e.toString();
      // Try fallback to new releases
      await _fetchNewReleases();
    } finally {
      _isLoadingAlbums = false;
      notifyListeners();
    }
  }

  Future<void> _fetchNewReleases() async {
    try {
      final token = _authService.getAccessToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/browse/new-releases?limit=4'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('albums') && data['albums'].containsKey('items')) {
          final List albums = data['albums']['items'];
          _albums = albums.map((album) => Album(
            id: album['id'],
            name: album['name'],
            imageUrl: album['images'].isNotEmpty ? album['images'][0]['url'] : '',
            artist: album['artists'].isNotEmpty ? album['artists'][0]['name'] : 'Unknown Artist',
          )).toList();
        }
      } else {
        _error = 'Failed to fetch albums: ${response.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }
  }
}