import 'package:dio/dio.dart';
import 'package:movieapplication/models/movie.dart';

class TmdbService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.themoviedb.org/3'));
  final String apiKey = '865695e017b5153ef4ca263248c26d92';  // Replace with your TMDB API key

  Future<List<Movie>> getTrendingMovies() async {
    final response = await _dio.get('/trending/movie/week', queryParameters: {'api_key': apiKey});
    return (response.data['results'] as List).map((json) => Movie.fromJson(json)).toList();
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    final response = await _dio.get('/movie/now_playing', queryParameters: {'api_key': apiKey});
    return (response.data['results'] as List).map((json) => Movie.fromJson(json)).toList();
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await _dio.get('/search/movie', queryParameters: {'api_key': apiKey, 'query': query});
    return (response.data['results'] as List).map((json) => Movie.fromJson(json)).toList();
  }

  Future<Movie> getMovieDetails(int id) async {
    final response = await _dio.get('/movie/$id', queryParameters: {'api_key': apiKey});
    return Movie.fromJson(response.data);
  }
}