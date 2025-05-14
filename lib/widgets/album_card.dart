// album_card.dart
import 'package:flutter/material.dart';

class AlbumCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String artist;
  final VoidCallback onTap;

  const AlbumCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.artist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen width to calculate the appropriate size for the card
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 44) / 2; // 16px padding on each side + 12px between cards
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Only take needed vertical space
          children: [
            // Album image
            AspectRatio(
              aspectRatio: 1.0, // Square image
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2), // Keep minimal spacing
            // Album title and artist
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1), // Even smaller gap between title and artist
            Text(
              artist,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}