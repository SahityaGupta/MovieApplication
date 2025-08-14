import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movieapplication/models/movie.dart';
import 'package:movieapplication/repositories/movie_repository.dart';
import 'package:movieapplication/views/movie_details_page.dart';
import 'package:movieapplication/views/saved_movies_page.dart';
import 'package:movieapplication/views/search_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<MovieRepository>(context, listen: false).syncData().then((_) {
      if (!mounted) return;
      Provider.of<MovieRepository>(context, listen: false).isOnline().then((online) {
        if (!online) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Offline mode: Showing cached data')));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movies Database'), elevation: 0),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.black87,
              child: TabBar(tabs: [Tab(text: 'Trending'), Tab(text: 'Now Playing')]),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MovieListView(type: 'trending'),
                  MovieListView(type: 'now_playing'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
        ],
        onTap: (index) {
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => SavedMoviesPage()));
        },
      ),
    );
  }
}

class MovieListView extends StatelessWidget {
  final String type;

  MovieListView({required this.type});

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<MovieRepository>(context);
    return FutureBuilder<List<Movie>>(
      future: type == 'trending' ? repo.getTrendingMovies() : repo.getNowPlayingMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 10,  // Placeholder count
            itemBuilder: (_, __) => Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[600]!,
              child: Container(color: Colors.grey[900]),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading movies', style: TextStyle(color: Colors.red)),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => (context as Element).markNeedsBuild(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
        final movies = snapshot.data ?? [];
        if (movies.isEmpty) return Center(child: Text('No movies available'));
        return GridView.builder(
          padding: EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MovieDetailsPage(movieId: movie.id)),
              ),
              child: Hero(
                tag: 'poster_${movie.id}',
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                          child: CachedNetworkImage(
                            imageUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath ?? ''}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey[800]!,
                              highlightColor: Colors.grey[600]!,
                              child: Container(color: Colors.grey[900]),
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          movie.title,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}