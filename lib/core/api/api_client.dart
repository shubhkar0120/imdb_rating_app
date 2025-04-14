import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio = Dio();
  final String baseUrl = 'https://imdb236.p.rapidapi.com';
  final Map<String, dynamic> headers = {
    'X-rapidapi-key': '82ef8c08e3msh8757fcf6500b2f2p189ed7jsn131b7cdd840c', 
    'X-RapidAPI-Host': 'imdb236.p.rapidapi.com',
  };

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      // Log the request for debugging
      print('Making API request to: $baseUrl$endpoint');
      print('Query parameters: $queryParameters');
      
      final response = await _dio.get(
        '$baseUrl$endpoint',
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      
      // Check if response data is null
      if (response.data == null) {
        print('API returned null data for: $endpoint');
        return {}; // Return empty map instead of null
      }
      
      return response.data;
    } on DioException catch (e) {
      // Handle Dio-specific errors
      print('Dio error: ${e.message}');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      throw Exception('API request failed: ${e.message}');
    } catch (e) {
      // Handle other errors
      print('Error fetching data from $endpoint: $e');
      throw Exception('Failed to fetch data: $e');
    }
  }
}