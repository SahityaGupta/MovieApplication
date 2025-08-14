import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:movieapplication/models/movie.dart';
import 'package:movieapplication/services/tmdb_service.dart';

class MovieRepository {
  final TmdbService _apiService = TmdbService();
  final Box<Movie> _movieBox = Hive.box<Movie>('movies');
  final Box<String> _bookmarkBox = Hive.box<String>('bookmarks');

  Future<bool> isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<Movie>> getTrendingMovies() async {
    if (await isOnline()) {
      try {
        final movies = await _apiService.getTrendingMovies();
        for (var movie in movies) {
          _movieBox.put(movie.id, movie);
        }
        return movies;
      } catch (e) {}
    }
    return _movieBox.values.toList();
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    if (await isOnline()) {
      try {
        final movies = await _apiService.getNowPlayingMovies();
        for (var movie in movies) {
          _movieBox.put(movie.id, movie);
        }
        return movies;
      } catch (e) {}
    }
    return _movieBox.values.toList();
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (await isOnline()) {
      try {
        final movies = await _apiService.searchMovies(query);
        for (var movie in movies) {
          _movieBox.put(movie.id, movie);
        }
        return movies;
      } catch (e) {}
    }
    return _movieBox.values
        .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<Movie> getMovieDetails(int id) async {
    if (await isOnline()) {
      try {
        final movie = await _apiService.getMovieDetails(id);
        _movieBox.put(id, movie);
        return movie;
      } catch (e) {}
    }
    return _movieBox.get(id) ??
        Movie(id: id, title: 'Unknown', overview: '');
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
    final ids = _bookmarkBox.values.map((idStr) => int.parse(idStr)).toList();
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