import 'package:dartz/dartz.dart';
import 'package:imdb_rating_app/features/movies/domain/entities/movies.dart';
import '../../../../core/error/failures.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetails {
  final MovieRepository repository;

  GetMovieDetails(this.repository);

  Future<Either<Failure, Movie>> call(String movieId) async {
    return await repository.getMovieDetails(movieId);
  }
}
