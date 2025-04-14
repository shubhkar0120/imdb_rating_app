import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imdb_rating_app/core/themes/app_theme.dart';
import 'package:imdb_rating_app/features/favorites/data/datasources/fav_local_datasources.dart';
import 'package:imdb_rating_app/features/movies/data/repository/movie_repository_impl.dart';
import 'package:imdb_rating_app/presentation/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api/api_client.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';
import 'features/movies/data/datasources/movie_remote_datasource.dart';
import 'features/movies/domain/usecases/get_movie_details.dart';
import 'features/movies/domain/usecases/search_movies.dart';
import 'features/movies/presentation/bloc/movies_bloc.dart';
import 'features/movie_details/presentation/bloc/movie_details_bloc.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  
  const MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => ApiClient(),
        ),
        RepositoryProvider(
          create: (context) => MovieRemoteDataSource(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => MovieRepositoryImpl(
            remoteDataSource: context.read<MovieRemoteDataSource>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => SearchMoviesUseCase(
            context.read<MovieRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => GetMovieDetails(
            context.read<MovieRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => FavoritesLocalDataSourceImpl(
            sharedPreferences: sharedPreferences,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MoviesBloc(
              searchMoviesUseCase: context.read<SearchMoviesUseCase>(),
            )..add(SearchMovies(query: 'popular', page: 1)),
          ),
          BlocProvider(
            create: (context) => MovieDetailsBloc(
              getMovieDetailsUseCase: context.read<GetMovieDetails>(),
            ),
          ),
          BlocProvider(
            create: (context) => FavoritesBloc(
              localDataSource: context.read<FavoritesLocalDataSourceImpl>(),
            )..add(LoadFavoritesEvent()),
          ),
        ],
        child: MaterialApp(
              title: 'IMDb Movie Reviews',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system, // System, light, or dark
              home: const HomeScreen(),
          ),
      ),
    );
  }
}