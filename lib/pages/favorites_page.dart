import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/radio_provider.dart';
import '../providers/player_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.favorite,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioProvider>(
      builder: (context, radioProvider, child) {
        final favorites = radioProvider.favoriteStations;

        if (favorites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No favorites yet.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final station = favorites[index];
            return ListTile(
              onTap: () {
                context.read<PlayerProvider>().playStation(station, radioProvider.stations);
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: station.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: station.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildPlaceholder(context),
                        errorWidget: (context, url, error) => _buildPlaceholder(context),
                      )
                    : _buildPlaceholder(context),
              ),
              title: Text(station.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(station.streamUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => radioProvider.toggleFavorite(station),
              ),
            );
          },
        );
      },
    );
  }
}
