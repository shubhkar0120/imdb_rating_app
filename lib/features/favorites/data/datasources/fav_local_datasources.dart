import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../movies/data/models/movie_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<MovieModel>> getFavorites();
  Future<void> addToFavorites(MovieModel movie);
  Future<void> removeFromFavorites(String movieId);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;
  final String _favoritesKey = 'FAVORITES_MOVIES';

  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<MovieModel>> getFavorites() async {
    final jsonString = sharedPreferences.getStringList(_favoritesKey) ?? [];
    return jsonString
        .map((movieStr) => MovieModel.fromJson(json.decode(movieStr)))
        .toList();
  }

  @override
  Future<void> addToFavorites(MovieModel movie) async {
    final favorites = await getFavorites();
    
    // Check if movie already exists
    if (favorites.any((fav) => fav.id == movie.id)) {
      return;
    }
    
    favorites.add(movie);
    
    final jsonStringList = favorites
        .map((movie) => json.encode(movie.toJson()))
        .toList();
    
    await sharedPreferences.setStringList(_favoritesKey, jsonStringList);
  }

  @override
  Future<void> removeFromFavorites(String movieId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((movie) => movie.id == movieId);
    
    final jsonStringList = favorites
        .map((movie) => json.encode(movie.toJson()))
        .toList();
    
    await sharedPreferences.setStringList(_favoritesKey, jsonStringList);
  }
}
