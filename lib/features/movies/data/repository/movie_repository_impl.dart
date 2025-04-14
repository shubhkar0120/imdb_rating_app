import 'package:dartz/dartz.dart';
import 'package:imdb_rating_app/features/movies/domain/entities/movies.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_datasource.dart';
import '../models/movie_model.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query, int page) async {
    try {
      final movieList = await remoteDataSource.searchMovies(query, page);
      final movies = movieList
          .map((movie) => MovieModel.fromJson(movie))
          .toList();
      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetails(String movieId) async {
    try {
      final movieDetails = await remoteDataSource.getMovieDetails(movieId);
      return Right(MovieModel.fromJson(movieDetails));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}