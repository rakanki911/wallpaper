import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper.dart';

class WallpaperGrid extends StatelessWidget {
  final List<Wallpaper> wallpapers;
  final ScrollController controller;
  final void Function(Wallpaper) onTap;
  final bool isLoading;

  const WallpaperGrid({
    Key? key,
    required this.wallpapers,
    required this.controller,
    required this.onTap,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (wallpapers.isEmpty && !isLoading) {
      return const Center(child: Text('لا توجد صور متاحة'));
    }
    return Stack(
      children: [
        GridView.builder(
          controller: controller,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: wallpapers.length,
          itemBuilder: (context, index) {
            final wallpaper = wallpapers[index];
            return GestureDetector(
              onTap: () => onTap(wallpaper),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: wallpaper.id,
                  child: CachedNetworkImage(
                    imageUrl: wallpaper.thumbUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            );
          },
        ),
        if (isLoading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}