import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imdb_rating_app/features/movies/domain/entities/movies.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/movie_details/presentation/bloc/movie_details_bloc.dart';
import '../../features/movies/data/models/movie_model.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailsScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MovieDetailsBloc>().add(
          LoadMovieDetailsEvent(widget.movieId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details'),
      ),
      body: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
        builder: (context, state) {
          if (state is MovieDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MovieDetailsLoaded) {
            return _buildMovieDetails(state.movie);
          } else if (state is MovieDetailsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No details available'));
          }
        },
      ),
    );
  }

  Widget _buildMovieDetails(Movie movie) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, favoritesState) {
        bool isFavorite = false;
        
        if (favoritesState is FavoritesLoaded) {
          isFavorite = favoritesState.favorites
              .any((favMovie) => favMovie.id == movie.id);
        }
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(tag: 'movie-${movie.id}',
                    child: movie.posterUrl != null
                        ? Image.network(
                            movie.posterUrl!,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(child: Text('No Image')),
                              );
                            },
                          )
                        : Container(
                            height: 300,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Center(child: Text('No Image')),
                          ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'favorite-button',
                      backgroundColor: isFavorite ? Colors.red : Colors.white,
                      onPressed: () {
                        if (isFavorite) {
                          context.read<FavoritesBloc>().add(
                                RemoveFromFavoritesEvent(movie.id),
                              );
                        } else {
                          // Convert to MovieModel for favorites
                          final movieModel = MovieModel(
                            id: movie.id,
                            title: movie.title,
                            posterUrl: movie.posterUrl,
                            year: movie.year,
                            genre: movie.genre,
                            rating: movie.rating,
                          );
                          
                          context.read<FavoritesBloc>().add(
                                AddToFavoritesEvent(movieModel),
                              );
                        }
                      },
                      child: Icon(
                        Icons.favorite,
                        color: isFavorite ? Colors.white : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (movie.rating != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              Text(
                                ' ${movie.rating}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (movie.year != null)
                          Text(
                            '${movie.year}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        if (movie.year != null && movie.genre != null)
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        if (movie.genre != null)
                          Expanded(
                            child: Text(
                              movie.genre!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Plot Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Plot summary would be displayed here if available in the API response.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'User reviews would be displayed here if available in the API response.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
