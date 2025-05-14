import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotify_only/constants.dart';
import 'package:spotify_only/providers/home_provider.dart';
import 'package:spotify_only/widgets/music_card.dart';
import 'package:spotify_only/widgets/playlist_card.dart';
import 'package:spotify_only/widgets/album_card.dart'; // You'll need to create this

class HomeScreen extends StatefulWidget {
  final Widget child;

  const HomeScreen({
    super.key,
    required this.child,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGrey,
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/library');
              break;
            case 3:
              context.go('/account');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: darkGrey,
        selectedItemColor: Colors.white,
        unselectedItemColor: textGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Your Library'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).fetchAllData();
    });
  }

  Widget _buildCategoryCard(BuildContext context, String title, String artist, String imageUrl, String id) {
    return GestureDetector(
      onTap: () => context.push('/album/$id/detail'),
      child: Container(
        decoration: BoxDecoration(
          color: mediumGrey,
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  artist,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    return Container(
      color: darkGrey,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: darkGrey,
            pinned: true,
            title: const Text(
              'Good afternoon',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
              IconButton(icon: const Icon(Icons.history), onPressed: () {}),
              IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Your Playlists
                const Text(
                  'Your Playlists',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                homeProvider.isLoadingPlaylists
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: homeProvider.playlists.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final playlist = homeProvider.playlists[index];
                            return PlaylistCard(
                              imageUrl: playlist.imageUrl,
                              title: playlist.name,
                              onTap: () => context.push('/playlist/${playlist.id}'),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 24),

                // Your Albums
                const Text(
                  'Your Albums',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4), // Reduced significantly from 16 to 4
                homeProvider.isLoadingAlbums
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8, // Slight adjustment for better proportions
                          crossAxisSpacing: 12, // Reduced from 16
                          mainAxisSpacing: 12, // Reduced from 16
                        ),
                        padding: EdgeInsets.zero, // Remove default padding
                        itemCount: homeProvider.albums.length,
                        itemBuilder: (context, index) {
                          final album = homeProvider.albums[index];
                          return AlbumCard(
                            imageUrl: album.imageUrl,
                            title: album.name,
                            artist: album.artist,
                            onTap: () => context.push('/album/${album.id}'),
                          );
                        },
                      ),
                const SizedBox(height: 24),

                // Recently Played Tracks
                const Text(
                  'Recently played tracks',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                homeProvider.isLoadingTracks
                    ? const Center(child: CircularProgressIndicator())
                    : homeProvider.tracks.isEmpty
                        ? const Text('No recent tracks found', style: TextStyle(color: Colors.white))
                        : Column(
                            children: homeProvider.tracks.map((track) {
                              return MusicCard(
                                imageUrl: track.imageUrl,
                                title: track.name,
                                artist: track.artist,
                                onTap: () {
                                  context.push('/track/${Uri.encodeComponent(track.name)}');
                                },
                              );
                            }).toList(),
                          ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// SearchContent and LibraryContent remain the same...