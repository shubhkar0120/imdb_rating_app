import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imdb_rating_app/features/movies/domain/entities/movies.dart';
import '../../../movies/domain/usecases/get_movie_details.dart';

// Events
abstract class MovieDetailsEvent {}

class LoadMovieDetailsEvent extends MovieDetailsEvent {
  final String movieId;

  LoadMovieDetailsEvent(this.movieId);
}

// States
abstract class MovieDetailsState {}

class MovieDetailsInitial extends MovieDetailsState {}

class MovieDetailsLoading extends MovieDetailsState {}

class MovieDetailsLoaded extends MovieDetailsState {
  final Movie movie;

  MovieDetailsLoaded(this.movie);
}

class MovieDetailsError extends MovieDetailsState {
  final String message;

  MovieDetailsError(this.message);
}

// BLoC
class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final GetMovieDetails getMovieDetailsUseCase;

  MovieDetailsBloc({required this.getMovieDetailsUseCase})
      : super(MovieDetailsInitial()) {
    on<LoadMovieDetailsEvent>(_onLoadMovieDetails);
  }

  Future<void> _onLoadMovieDetails(
      LoadMovieDetailsEvent event, Emitter<MovieDetailsState> emit) async {
    emit(MovieDetailsLoading());
    final result = await getMovieDetailsUseCase(event.movieId);

    result.fold(
      (failure) => emit(MovieDetailsError(failure.message)),
      (movie) => emit(MovieDetailsLoaded(movie)),
    );
  }
}
