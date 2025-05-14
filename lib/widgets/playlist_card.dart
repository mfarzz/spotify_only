import 'package:flutter/material.dart';

class PlaylistCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.startsWith('http') 
                ? Image.network(
                    imageUrl,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 140,
                        height: 140,
                        color: Colors.grey,
                        child: const Icon(Icons.error, color: Colors.white),
                      );
                    },
                  )
                : Image.asset(
                    imageUrl,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
