import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:movieapplication/models/movie.dart';

part 'tmdb_service.g.dart';

@RestApi(baseUrl: "https://api.themoviedb.org/3")
abstract class TmdbService {
  factory TmdbService(Dio dio, {String baseUrl}) = _TmdbService;

  @GET("/trending/movie/week")
  Future<MoviesResponse> getTrendingMovies(@Query("api_key") String apiKey);

  @GET("/movie/now_playing")
  Future<MoviesResponse> getNowPlayingMovies(@Query("api_key") String apiKey);

  @GET("/search/movie")
  Future<MoviesResponse> searchMovies(
      @Query("api_key") String apiKey, @Query("query") String query);

  @GET("/movie/{id}")
  Future<Movie> getMovieDetails(@Path("id") int id, @Query("api_key") String apiKey);
}

/// Wraps the TMDB response which contains a list of movies
class MoviesResponse {
  final List<Movie> results;

  MoviesResponse({required this.results});

  factory MoviesResponse.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    final movies = list.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    return MoviesResponse(results: movies);
  }
}
