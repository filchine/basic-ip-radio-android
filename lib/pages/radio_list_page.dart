import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/radio_provider.dart';
import '../providers/player_provider.dart';
import '../models/radio_station.dart';

class RadioListPage extends StatefulWidget {
  const RadioListPage({super.key});

  @override
  State<RadioListPage> createState() => _RadioListPageState();
}

class _RadioListPageState extends State<RadioListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RadioProvider>().loadStations();
    });
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.radio,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  void _showEditStationDialog(BuildContext context, RadioStation station) {
    final nameController = TextEditingController(text: station.name);
    final urlController = TextEditingController(text: station.streamUrl);
    final imageController = TextEditingController(text: station.imageUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Radio Station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Station Name'),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'Stream URL'),
            ),
            TextField(
              controller: imageController,
              decoration: const InputDecoration(labelText: 'Image URL (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              final imageUrl = imageController.text.trim();

              if (name.isEmpty || url.isEmpty || !Uri.parse(url).isAbsolute) {
                return;
              }

              final updatedStation = station.copyWith(
                name: name,
                streamUrl: url,
                imageUrl: imageUrl,
              );
              context.read<RadioProvider>().updateStation(updatedStation);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioProvider>(
      builder: (context, radioProvider, child) {
        final stations = radioProvider.stations;

        if (stations.isEmpty) {
          return const Center(
            child: Text('No radio stations added yet.\nTap the + button to add one.'),
          );
        }

        return ReorderableListView.builder(
          itemCount: stations.length,
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            radioProvider.reorderStations(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final station = stations[index];
            return ListTile(
              key: ValueKey(station.id ?? index),
              onLongPress: () => _showEditStationDialog(context, station),
              onTap: () {
                context.read<PlayerProvider>().playStation(station, stations);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      station.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: station.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => radioProvider.toggleFavorite(station),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      if (station.id != null) {
                        radioProvider.removeStation(station.id!);
                      }
                    },
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Icon(Icons.drag_handle, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

