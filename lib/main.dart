import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movieapplication/models/movie.dart';
import 'package:movieapplication/repositories/movie_repository.dart';
import 'package:movieapplication/views/home_page.dart';
import 'package:movieapplication/views/movie_details_page.dart';
import 'package:provider/provider.dart';
// import 'package:uni_links/uni_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());
  await Hive.openBox<Movie>('movies');
  await Hive.openBox<String>('bookmarks');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // initUniLinks();
  }

  // Future<void> initUniLinks() async {
  //   _sub = linkStream.listen((String? link) {
  //     if (link != null && link.startsWith('myapp://movie/')) {
  //       final movieId = int.tryParse(link.split('/').last) ?? 0;
  //       Navigator.of(context).push(MaterialPageRoute(
  //         builder: (_) => MovieDetailsPage(movieId: movieId),
  //       ));
  //     }
  //   }, onError: (err) {});
  //
  //   final initialLink = await getInitialLink();
  //   if (initialLink != null && initialLink.startsWith('myapp://movie/')) {
  //     final movieId = int.tryParse(initialLink.split('/').last) ?? 0;
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       Navigator.of(context).push(MaterialPageRoute(
  //         builder: (_) => MovieDetailsPage(movieId: movieId),
  //       ));
  //     });
  //   }
  // }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MovieRepository>(create: (_) => MovieRepository()),
      ],
      child: MaterialApp(
        title: 'Movies Database',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blueGrey,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black87),
          cardTheme: CardThemeData(color: Colors.grey[900], elevation: 4),
          textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
        ),
        home: HomePage(),
        routes: {
          '/details': (context) => MovieDetailsPage(
            movieId: ModalRoute.of(context)!.settings.arguments as int,
          ),
        },
      ),
    );
  }
}