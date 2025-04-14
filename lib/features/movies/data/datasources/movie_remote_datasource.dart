import 'package:imdb_rating_app/core/api/api_client.dart';

class MovieRemoteDataSource {
  final ApiClient apiClient;

  MovieRemoteDataSource({required this.apiClient});

  Future<List<dynamic>> searchMovies(String query, int page) async {
    try {
      final response = await apiClient.get('/imdb/search', queryParameters: {
        'query': query,
        'page': page,
      });
      
      // Debug print to see the API response structure
      print('Search API Response structure: ${response.runtimeType}');
      
      // Handle different response structures
      if (response is Map<String, dynamic>) {
        
        if (response.containsKey('results') && response['results'] is List) {
          print('Found results at response["results"]');
          return response['results'];
        } else if (response.containsKey('data') && response['data'] is Map && 
                  response['data'].containsKey('results') && response['data']['results'] is List) {
          print('Found results at response["data"]["results"]');
          return response['data']['results'];
        } else if (response.containsKey('search') && response['search'] is List) {
          print('Found results at response["search"]');
          return response['search'];
        } else if (response.containsKey('searchResults') && response['searchResults'] is List) {
          print('Found results at response["searchResults"]');
          return response['searchResults'];
        } else if (response.containsKey('data') && response['data'] is List) {
          print('Found results at response["data"]');
          return response['data'];
        } else if (response.containsKey('d') && response['d'] is List) {
          // This format is used by some IMDb APIs
          print('Found results at response["d"]');
          return response['d'];
        } else {
          print('No standard results structure found, using full response');
          if (response.containsKey('titles') && response['titles'] is List) {
            return response['titles'];
          } else if (response.containsKey('movies') && response['movies'] is List) {
            return response['movies'];
          }
        }
      }
      
      print('Unable to extract results from response: $response');
      return [];
    } catch (e) {
      print('Error searching movies: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(String movieId) async {
    try {
      // Try the original endpoint first
      try {
        final response = await apiClient.get('/imdb/id/$movieId');
        
        if (response is Map<String, dynamic> && response.isNotEmpty) {
          return response;
        }
      } catch (e) {
        print('First attempt to get movie details failed: $e');
      }
      
      // Try alternative endpoints if the first one failed
      try {
        final response = await apiClient.get('/title/get-details', queryParameters: {
          'tconst': movieId,
        });
        
        if (response is Map<String, dynamic> && response.isNotEmpty) {
          return response;
        }
      } catch (e) {
        print('Second attempt to get movie details failed: $e');
      }
      
      // Try one more alternative
      try {
        final response = await apiClient.get('/title/get-full-details', queryParameters: {
          'tconst': movieId,
        });
        
        if (response is Map<String, dynamic> && response.isNotEmpty) {
          return response;
        }
      } catch (e) {
        print('Third attempt to get movie details failed: $e');
      }
      
      // If all attempts fail, return an empty map
      print('All attempts to get movie details failed');
      return {};
    } catch (e) {
      print('Error getting movie details: $e');
      return {};
    }
  }
}