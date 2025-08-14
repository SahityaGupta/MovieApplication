import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:movieapplication/models/movie.dart';
import 'package:movieapplication/services/tmdb_service.dart';
import 'dart:developer' as developer;

class MovieRepository {
  final TmdbService _apiService = TmdbService(Dio());
  final Box<Movie> _movieBox = Hive.box<Movie>('movies');
  final Box<String> _bookmarkBox = Hive.box<String>('bookmarks');
  final String apiKey = "865695e017b5153ef4ca263248c26d92";

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<Movie>> getTrendingMovies() async {
    if (await isOnline()) {
      try {
        final response = await _apiService.getTrendingMovies(apiKey);
        final movies = response.results;

        for (var movie in movies) {
          _movieBox.put(movie.id, movie);
        }
        return movies;
      } catch (e, s) {
        developer.log('Error fetching trending movies', error: e, stackTrace: s);
      }
    }
    return _movieBox.values.toList();
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    if (await isOnline()) {
      try {
        final response = await _apiService.getNowPlayingMovies(apiKey);
        final movies = response.results;

        for (var movie in movies) {
          _movieBox.put(movie.id, movie);
        }
        return movies;
      } catch (e, s) {
        developer.log('Error fetching now playing movies', error: e, stackTrace: s);
      }
    }
    return _movieBox.values.toList();
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (await isOnline()) {
      try {
        final response = await _apiService.searchMovies(apiKey, query);
        final movies = response.results;

        for (var movie in movies) {
          _movieBox.put(movie.id, movie);
        }
        return movies;
      } catch (e, s) {
        developer.log('Error searching movies', error: e, stackTrace: s);
      }
    }

    // Offline search
    return _movieBox.values
        .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<Movie> getMovieDetails(int id) async {
    if (await isOnline()) {
      try {
        final movie = await _apiService.getMovieDetails(id, apiKey);
        _movieBox.put(id, movie);
        return movie;
      } catch (e, s) {
        developer.log('Error fetching movie details', error: e, stackTrace: s);
      }
    }
    return _movieBox.get(id) ?? Movie(id: id, title: 'Unknown', overview: '');
  }

  Future<void> toggleBookmark(int movieId) async {
    if (_bookmarkBox.containsKey(movieId.toString())) {
      await _bookmarkBox.delete(movieId.toString());
    } else {
      await _bookmarkBox.put(movieId.toString(), movieId.toString());
    }
  }

  bool isBookmarked(int movieId) {
    return _bookmarkBox.containsKey(movieId.toString());
  }

  List<Movie> getBookmarkedMovies() {
    final ids = _bookmarkBox.values.map(int.parse).toList();
    return ids
        .map((id) => _movieBox.get(id))
        .whereType<Movie>()
        .toList();
  }

  Future<void> syncData() async {
    if (await isOnline()) {
      await getTrendingMovies();
      await getNowPlayingMovies();
    }
  }
}
