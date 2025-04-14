abstract class Movie {
  // Abstract getters that need to be implemented
  String get id;
  String get title;
  String? get posterUrl;
  int? get year;
  String? get genre;
  double? get rating;

  // Constructor
  const Movie();
}