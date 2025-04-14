import 'package:dartz/dartz.dart';
import 'package:imdb_rating_app/features/movies/domain/entities/movies.dart';
import '../../../../core/error/failures.dart';


abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> searchMovies(String query, int page);
  Future<Either<Failure, Movie>> getMovieDetails(String movieId);
}