import 'package:dartz/dartz.dart';
import 'package:imdb_rating_app/core/error/failures.dart';
import 'package:imdb_rating_app/features/movies/domain/entities/movies.dart';
import 'package:imdb_rating_app/features/movies/domain/repositories/movie_repository.dart';

class SearchMoviesUseCase {
  final MovieRepository repository;

  SearchMoviesUseCase(this.repository);

  Future<Either<Failure, List<Movie>>> call(String query, int page) async {
    return await repository.searchMovies(query, page);
  }
}