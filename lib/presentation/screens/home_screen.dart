import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imdb_rating_app/features/movies/domain/entities/movies.dart';
import 'package:imdb_rating_app/presentation/screens/favorites_screens.dart';
import 'package:imdb_rating_app/presentation/screens/movie_details_screen.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart' as favorites;
import '../../features/movies/presentation/bloc/movies_bloc.dart' as movies;
import '../widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _currentQuery = 'popular';
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<movies.MoviesBloc>().state;
      if (state is movies.MoviesLoaded && !state.hasReachedMax) {
        context.read<movies.MoviesBloc>().add(
              movies.SearchMovies(
                query: state.currentQuery,
                page: state.currentPage + 1,
                isLoadMore: true,
              ),
            );
      }
    }
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _currentQuery = query;
      });
      context.read<movies.MoviesBloc>().add(
            movies.SearchMovies(query: query, page: 1),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMDb Movies'),
        actions: [
          BlocBuilder<favorites.FavoritesBloc, favorites.FavoritesState>(
            builder: (context, state) {
              int count = 0;
              if (state is favorites.FavoritesLoaded) {
                count = state.favorites.length;
              }
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search movies...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearch,
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<movies.MoviesBloc, movies.MoviesState>(
              builder: (context, state) {
                if (state is movies.MoviesInitial || state is movies.MoviesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is movies.MoviesLoaded) {
                  return _buildMovieGrid(state.movies);
                } else if (state is movies.MoviesLoadingMore) {
                  return _buildMovieGrid(state.currentMovies, isLoadingMore: true);
                } else if (state is movies.MoviesError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else {
                  return const Center(child: Text('No movies found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieGrid(List<Movie> movies, {bool isLoadingMore = false}) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: isLoadingMore ? movies.length + 1 : movies.length,
      itemBuilder: (context, index) {
        if (index >= movies.length) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final movie = movies[index];
        return MovieCard(
          movie: movie,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailsScreen(movieId: movie.id),
              ),
            );
          },
        );
      },
    );
  }
}