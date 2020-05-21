import 'package:meta/meta.dart';

class Movie {
  Movie({
    @required this.title,
    @required this.posterPath,
    @required this.id,
    @required this.overview,
    @required this.genre_ids,
    @required this.vote_average,
    this.favored,
  });

  String title, posterPath, id, overview, vote_average, genre_ids;
  bool favored;

  Movie.fromJson(Map json)
      : title = json["title"],
        posterPath = json["poster_path"],
        id = json["id"].toString(),
        overview = json["overview"],
        genre_ids = json["genre_id"].toString(),
        vote_average = json["vote_average"].toString(),
        favored = false;
}
