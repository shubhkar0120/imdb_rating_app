import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imdb_rating_app/features/movies/domain/entities/movies.dart';
import 'package:imdb_rating_app/features/movies/domain/usecases/search_movies.dart';

// Events
abstract class MoviesEvent {}

class SearchMovies extends MoviesEvent {
  final String query;
  final int page;
  final bool isLoadMore;

  SearchMovies({
    required this.query,
    required this.page,
    this.isLoadMore = false,
  });
}

class LoadPopularMovies extends MoviesEvent {
  final int page;
  final bool isLoadMore;

  LoadPopularMovies({
    required this.page,
    this.isLoadMore = false,
  });
}

// States
abstract class MoviesState {}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class MoviesLoaded extends MoviesState {
  final List<Movie> movies;
  final String currentQuery;
  final int currentPage;
  final bool hasReachedMax;

  MoviesLoaded({
    required this.movies, 
    required this.currentQuery, 
    required this.currentPage,
    this.hasReachedMax = false,
  });
}

class MoviesLoadingMore extends MoviesState {
  final List<Movie> currentMovies;
  final String currentQuery;
  final int currentPage;

  MoviesLoadingMore({
    required this.currentMovies,
    required this.currentQuery,
    required this.currentPage,
  });
}

class MoviesError extends MoviesState {
  final String message;

  MoviesError(this.message);
}

// BLoC
class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final SearchMoviesUseCase searchMoviesUseCase;

  MoviesBloc({required this.searchMoviesUseCase}) : super(MoviesInitial()) {
    on<SearchMovies>(_onSearchMovies);
    on<LoadPopularMovies>(_onLoadPopularMovies);
  }

  Future<void> _onSearchMovies(
      SearchMovies event, Emitter<MoviesState> emit) async {
    if (!event.isLoadMore) {
      emit(MoviesLoading());
    } else {
      final currentState = state as MoviesLoaded;
      emit(MoviesLoadingMore(
        currentMovies: currentState.movies,
        currentQuery: currentState.currentQuery,
        currentPage: currentState.currentPage,
      ));
    }

    try {
      final result = await searchMoviesUseCase(event.query, event.page);
      
      result.fold(
        (failure) => emit(MoviesError(failure.message)),
        (movies) {
          if (event.isLoadMore && state is MoviesLoadingMore) {
            final currentState = state as MoviesLoadingMore;
            final allMovies = [...currentState.currentMovies, ...movies];
            
            emit(MoviesLoaded(
              movies: allMovies,
              currentQuery: event.query,
              currentPage: event.page,
              hasReachedMax: movies.isEmpty,
            ));
          } else {
            emit(MoviesLoaded(
              movies: movies,
              currentQuery: event.query,
              currentPage: event.page,
              hasReachedMax: movies.isEmpty,
            ));
          }
        },
      );
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }

  Future<void> _onLoadPopularMovies(
      LoadPopularMovies event, Emitter<MoviesState> emit) async {
    if (!event.isLoadMore) {
      emit(MoviesLoading());
    } else {
      final currentState = state as MoviesLoaded;
      emit(MoviesLoadingMore(
        currentMovies: currentState.movies,
        currentQuery: 'popular',
        currentPage: currentState.currentPage,
      ));
    }

    try {
      final result = await searchMoviesUseCase('popular', event.page);
      
      result.fold(
        (failure) => emit(MoviesError(failure.message)),
        (movies) {
          if (event.isLoadMore && state is MoviesLoadingMore) {
            final currentState = state as MoviesLoadingMore;
            final allMovies = [...currentState.currentMovies, ...movies];
            
            emit(MoviesLoaded(
              movies: allMovies,
              currentQuery: 'popular',
              currentPage: event.page,
              hasReachedMax: movies.isEmpty,
            ));
          } else {
            emit(MoviesLoaded(
              movies: movies,
              currentQuery: 'popular',
              currentPage: event.page,
              hasReachedMax: movies.isEmpty,
            ));
          }
        },
      );
    } catch (e) {
      emit(MoviesError(e.toString()));
    }
  }
}