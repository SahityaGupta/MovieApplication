import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movieapplication/models/movie.dart';
import 'package:movieapplication/repositories/movie_repository.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  MovieDetailsPage({required this.movieId});

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<MovieRepository>(context, listen: false).isOnline().then((online) {
      if (!online) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Offline: Showing cached details')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<MovieRepository>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Movie Details'), elevation: 0),
      body: FutureBuilder<Movie>(
        future: repo.getMovieDetails(widget.movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading details', style: TextStyle(color: Colors.red)),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final movie = snapshot.data ?? Movie(id: widget.movieId, title: 'Unknown', overview: '');
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'poster_${movie.id}',
                  child: CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath ?? ''}',
                    height: 300,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[600]!,
                      child: Container(height: 300, color: Colors.grey[900]),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error, size: 100, color: Colors.red),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Rating: ', style: TextStyle(fontSize: 16)),
                          ...List.generate(5, (i) => Icon(
                            i < (movie.voteAverage ?? 0) / 2 ? Icons.star : Icons.star_border,
                            color: Colors.yellow,
                            size: 20,
                          )),
                          Text(' (${movie.voteAverage ?? 'N/A'})'),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('Overview:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(movie.overview, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(repo.isBookmarked(movie.id) ? Icons.bookmark_remove : Icons.bookmark_add),
                            label: Text(repo.isBookmarked(movie.id) ? 'Remove Bookmark' : 'Add Bookmark'),
                            onPressed: () async {
                              await repo.toggleBookmark(movie.id);
                              setState(() {});  // Refresh UI
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(repo.isBookmarked(movie.id) ? 'Bookmarked' : 'Removed from bookmarks'),
                              ));
                            },
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.share),
                            label: Text('Share'),
                            onPressed: () async {
                              final shareLink = 'https://www.themoviedb.org/movie/${movie.id}';
                              var shareResult = await SharePlus.instance.share(
                                 ShareParams(
                                  text: 'Check out this movie: ${movie.title}\n$shareLink',
                                  subject: 'Movie Details',
                                  sharePositionOrigin: Rect.fromLTWH(0, 0, 100, 100),
                                )
                              );
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Share link copied to clipboard'),
                              ));

                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}