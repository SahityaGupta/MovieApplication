import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movieapplication/models/movie.dart';
import 'package:movieapplication/repositories/movie_repository.dart';
import 'package:movieapplication/views/movie_details_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SavedMoviesPage extends StatefulWidget {
  @override
  _SavedMoviesPageState createState() => _SavedMoviesPageState();
}

class _SavedMoviesPageState extends State<SavedMoviesPage> {
  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<MovieRepository>(context);
    final bookmarkedMovies = repo.getBookmarkedMovies();  // Loads from Hive, offline

    return Scaffold(
      appBar: AppBar(title: Text('Saved Movies'), elevation: 0),
      body: bookmarkedMovies.isEmpty
          ? Center(child: Text('No bookmarked movies yet. Add some from details!'))
          : ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: bookmarkedMovies.length,
        itemBuilder: (context, index) {
          final movie = bookmarkedMovies[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath ?? ''}',
                  width: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[800]!,
                    highlightColor: Colors.grey[600]!,
                    child: Container(width: 50, height: 75, color: Colors.grey[900]),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              title: Text(movie.title),
              subtitle: Text('Rating: ${movie.voteAverage ?? 'N/A'}'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await repo.toggleBookmark(movie.id);  // Updates Hive offline
                  setState(() {});  // Refresh list
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed from bookmarks')));
                },
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MovieDetailsPage(movieId: movie.id)),
              ),
            ),
          );
        },
      ),
    );
  }
}