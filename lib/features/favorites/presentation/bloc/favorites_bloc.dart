import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imdb_rating_app/features/favorites/data/datasources/fav_local_datasources.dart';
import '../../../movies/data/models/movie_model.dart';

// Events
abstract class FavoritesEvent {}

class LoadFavoritesEvent extends FavoritesEvent {}

class AddToFavoritesEvent extends FavoritesEvent {
  final MovieModel movie;

  AddToFavoritesEvent(this.movie);
}

class RemoveFromFavoritesEvent extends FavoritesEvent {
  final String movieId;

  RemoveFromFavoritesEvent(this.movieId);
}

// States
abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<MovieModel> favorites;

  FavoritesLoaded(this.favorites);
}

class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError(this.message);
}

// BLoC
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesLocalDataSource localDataSource;

  FavoritesBloc({required this.localDataSource}) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
  }

  Future<void> _onLoadFavorites(
      LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final favorites = await localDataSource.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
      AddToFavoritesEvent event, Emitter<FavoritesState> emit) async {
    try {
      await localDataSource.addToFavorites(event.movie);
      final favorites = await localDataSource.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
      RemoveFromFavoritesEvent event, Emitter<FavoritesState> emit) async {
    try {
      await localDataSource.removeFromFavorites(event.movieId);
      final favorites = await localDataSource.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}