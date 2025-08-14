import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movieapplication/models/movie.dart';
import 'package:movieapplication/repositories/movie_repository.dart';
import 'package:movieapplication/views/movie_details_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Movie> _searchResults = [];
  Timer? _debounceTimer;
  bool _isLoading = false;

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    setState(() => _isLoading = true);
    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        final results = await Provider.of<MovieRepository>(context, listen: false).searchMovies(query);
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Movies'), elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for movies...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[800],
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? ListView.builder(
              itemCount: 5,  // Placeholder
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[600]!,
                child: ListTile(title: Container(height: 50, color: Colors.grey[900])),
              ),
            )
                : _searchResults.isEmpty
                ? Center(child: Text('No results found'))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final movie = _searchResults[index];
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MovieDetailsPage(movieId: movie.id)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}