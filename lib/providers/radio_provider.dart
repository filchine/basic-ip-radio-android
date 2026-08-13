import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/radio_station.dart';

class RadioProvider with ChangeNotifier {
  List<RadioStation> _stations = [];
  final DbHelper _dbHelper = DbHelper();

  List<RadioStation> get stations => _stations;
  List<RadioStation> get favoriteStations => _stations.where((s) => s.isFavorite).toList();

  Future<void> loadStations() async {
    _stations = await _dbHelper.getStations();
    notifyListeners();
  }

  Future<void> addStation(RadioStation station) async {
    final nextPosition = _stations.isEmpty ? 0 : _stations.last.position + 1;
    await _dbHelper.insertStation(station.copyWith(position: nextPosition));
    await loadStations();
  }

  Future<void> updateStation(RadioStation station) async {
    await _dbHelper.updateStation(station);
    await loadStations();
  }

  Future<void> reorderStations(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final RadioStation station = _stations.removeAt(oldIndex);
    _stations.insert(newIndex, station);
    notifyListeners();

    for (int i = 0; i < _stations.length; i++) {
      _stations[i] = _stations[i].copyWith(position: i);
      await _dbHelper.updateStation(_stations[i]);
    }
  }

  Future<void> removeStation(int id) async {
    await _dbHelper.deleteStation(id);
    await loadStations();
  }

  Future<void> toggleFavorite(RadioStation station) async {
    final updatedStation = station.copyWith(isFavorite: !station.isFavorite);
    await _dbHelper.updateStation(updatedStation);
    await loadStations();
  }
}
