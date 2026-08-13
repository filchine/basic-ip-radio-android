import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/radio_station.dart';
import '../providers/radio_provider.dart';
import '../providers/player_provider.dart';
import 'radio_list_page.dart';
import 'favorites_page.dart';
import 'settings.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const RadioListPage(),
    const FavoritesPage(),
    const SettingsPage(),
  ];

  String get _appBarTitle {
    switch (_selectedIndex) {
      case 0: return 'IP Radios';
      case 1: return 'Favorites';
      case 2: return 'Settings';
      default: return 'IP Radio';
    }
  }

  void _showAddStationDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Radio Station'),
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

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a station name')),
                );
                return;
              }

              if (url.isEmpty || !Uri.parse(url).isAbsolute) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid stream URL')),
                );
                return;
              }

              final newStation = RadioStation(
                name: name,
                streamUrl: url,
                imageUrl: imageUrl,
              );
              context.read<RadioProvider>().addStation(newStation);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final currentStation = playerProvider.currentStation;
        if (currentStation == null) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: currentStation.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: currentStation.imageUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Icon(Icons.radio),
                        errorWidget: (context, url, error) => const Icon(Icons.radio),
                      )
                    : const Icon(Icons.radio),
              ),
              title: Text(
                currentStation.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Now Playing', style: TextStyle(fontSize: 12)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: playerProvider.hasPrevious ? () => playerProvider.previous() : null,
                  ),
                  IconButton(
                    icon: Icon(playerProvider.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled),
                    iconSize: 36,
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => playerProvider.togglePlay(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: playerProvider.hasNext ? () => playerProvider.next() : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => playerProvider.stop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().errorStream.listen((error) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
          _buildMiniPlayer(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Padding(
              padding: EdgeInsets.only(
                bottom: context.watch<PlayerProvider>().currentStation != null ? 80 : 0,
              ),
              child: FloatingActionButton(
                onPressed: () => _showAddStationDialog(context),
                child: const Icon(Icons.add),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radio_outlined),
            selectedIcon: Icon(Icons.radio),
            label: 'Radio',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
