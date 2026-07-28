import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_app/models/movie.dart';

class FavoritesService {
  static const String _boxName = 'favorites';
  late Box<String> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  List<Movie> getFavorites() {
    return _box.values
        .map((jsonString) => Movie.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  bool isFavorite(int movieId) {
    return _box.containsKey(movieId.toString());
  }

  Future<void> addFavorite(Movie movie) async {
    await _box.put(movie.id.toString(), jsonEncode(movie.toJson()));
  }

  Future<void> removeFavorite(int movieId) async {
    await _box.delete(movieId.toString());
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      await removeFavorite(movie.id);
    } else {
      await addFavorite(movie);
    }
  }
}
