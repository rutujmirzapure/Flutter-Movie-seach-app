import 'package:flutter/material.dart';
import 'package:movie_app/model/model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_star_rating/smooth_star_rating.dart';

import 'dart:convert';

const key = '11fbce624b26a6399db07560f5bd5fed';

var rating = 0.0;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Movie Searcher",
      theme: ThemeData(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomePage> {
  List<Movie> movies = List();
  bool hasLoaded = true;

  final PublishSubject subject = PublishSubject<String>();

  @override
  void dispose() {
    subject.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    subject.stream.listen(searchMovies);
  }

  void searchMovies(query) {
    resetMovies();
    if (query.isEmpty) {
      setState(() {
        hasLoaded = true;
      });
      return; //Forgot to add in the tutorial <- leaves function if there is no query in the box.
    }
    setState(() => hasLoaded = false);
    http
        .get(
            'https://api.themoviedb.org/3/search/movie?api_key=$key&query=$query')
        .then((res) => (res.body))
        .then(json.decode)
        .then((map) => map["results"])
        .then((movies) => movies.forEach(addMovie))
        .catchError(onError)
        .then((e) {
      setState(() {
        hasLoaded = true;
      });
    });
  }

  void onError(dynamic d) {
    setState(() {
      hasLoaded = true;
    });
  }

  void addMovie(item) {
    setState(() {
      movies.add(Movie.fromJson(item));
    });
    print('${movies.map((m) => m.title)}');
  }

  void resetMovies() {
    setState(() => movies.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Searcher'),
      ),
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                filled: true,
                fillColor: Colors.white70,
                enabledBorder: OutlineInputBorder(
                  gapPadding: 30,
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                  borderSide: BorderSide(color: Colors.black, width: 2.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                  borderSide: BorderSide(color: Colors.black, width: 2.5),
                ),
              ),
              onChanged: (String string) => (subject.add(string)),
            ),
            hasLoaded ? Container() : CircularProgressIndicator(),
            Expanded(
                child: ListView.builder(
              padding: EdgeInsets.all(30.0),
              itemCount: movies.length,
              itemBuilder: (BuildContext context, int index) {
                return new MovieView(movies[index]);
              },
            ))
          ],
        ),
      ),
    );
  }
}

class MovieView extends StatefulWidget {
  MovieView(this.movie);
  final Movie movie;

  @override
  MovieViewState createState() => MovieViewState();
}

class MovieViewState extends State<MovieView> {
  Movie movieState;

  @override
  void initState() {
    super.initState();
    movieState = widget.movie;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            height: 200.0,
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
//                movieState.posterPath != null
////                    ? Align(
////                        alignment: Alignment.topRight,
////                        child: Hero(
////                          child: Image.network(
////                              "https://image.tmdb.org/t/p/w92${movieState.posterPath}"),
////                          tag: movieState.id,
////                        ),
//                      )
//                    : Container(),
                Expanded(
                    child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 10,
                      child: Hero(
                        child: Image.network(
                            "https://image.tmdb.org/t/p/w92${movieState.posterPath}"),
                        tag: movieState.id,
                      ),
                    ),
                    Positioned(
                      left: 150,
                      top: 40,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          movieState.title,
                          maxLines: 10,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 150,
                      top: 65,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          'genre:' + movieState.genre_ids,
                          maxLines: 10,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 150,
                      top: 80,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          movieState.vote_average,
                          maxLines: 10,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40.0,
                              color: Colors.blue.shade900),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 200,
                      top: 92,
                      child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: SmoothStarRating(
                            color: Colors.amber,
                            rating: rating,
                            size: 20,
                            filledIconData: Icons.star,
                            halfFilledIconData: Icons.star_half,
                            defaultIconData: Icons.star_border,
                            starCount: 5,
                            allowHalfRating: true,
                            spacing: 2.0,
                            onRated: (value) {
                              print("rating value -> $value");
                              // print("rating value dd -> ${value.truncate()}");
                            },
                          )),
                    ),
                  ],
                ))
              ],
            )));
  }
}
