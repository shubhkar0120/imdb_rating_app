import 'package:imdb_rating_app/features/movies/domain/entities/movies.dart';



class MovieModel extends Movie {
  // Implement the abstract properties
  
  @override
  final String id;
  @override
  final String title;
  @override
  final String? posterUrl;
  @override
  final int? year;
  @override
  final String? genre;
  @override
  final double? rating;
  @override
  final String? plotSummary;
  @override
  final List<Review>? reviews;

  // Constructor
  const MovieModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.year,
    this.genre,
    this.rating,
    this.plotSummary,
    this.reviews,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    // Debug print to see exact structure
    print('Processing JSON: $json');
    
    // Better image URL handling
    String? imageUrl;
    
    // Try to extract image from different possible paths
    if (json['i'] != null && json['i'] is Map) {
      // Format used by some IMDb APIs where image is under 'i' key
      if (json['i']['imageUrl'] != null) {
        imageUrl = json['i']['imageUrl'];
      } else if (json['i']['url'] != null) {
        imageUrl = json['i']['url'];
      }
    } else if (json['image'] != null) {
      imageUrl = json['image'];
    } else if (json['poster'] != null) {
      imageUrl = json['poster'];
    } else if (json['posterUrl'] != null) {
      imageUrl = json['posterUrl'];
    } else if (json.containsKey('img') && json['img'] != null) {
      imageUrl = json['img'];
    }
    
    // Check if the URL needs a scheme
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      if (imageUrl.startsWith('//')) {
        imageUrl = 'https:' + imageUrl;
      } else {
        imageUrl = 'https://' + imageUrl;
      }
    }
    
    // Handle different title keys
    String movieTitle = 'No Title';
    if (json['title'] != null && json['title'].toString().isNotEmpty) {
      movieTitle = json['title'];
    } else if (json['l'] != null) {
      movieTitle = json['l'];
    } else if (json['name'] != null) {
      movieTitle = json['name'];
    } else if (json['originalTitle'] != null) {
      movieTitle = json['originalTitle'];
    }
    
    // Get year, handling different formats
    int? movieYear;
    if (json['year'] != null) {
      if (json['year'] is int) {
        movieYear = json['year'];
      } else if (json['year'] is String) {
        movieYear = int.tryParse(json['year']);
      }
    } else if (json['y'] != null) {
      if (json['y'] is int) {
        movieYear = json['y'];
      } else if (json['y'] is String) {
        movieYear = int.tryParse(json['y']);
      }
    }
    
    // Extract plot summary
    String? plotSummary;
    if (json['plot'] != null) {
      plotSummary = json['plot'];
    } else if (json['plotSummary'] != null) {
      plotSummary = json['plotSummary'];
    } else if (json['plotOutline'] != null && json['plotOutline'] is Map) {
      plotSummary = json['plotOutline']['text'];
    } else if (json['overview'] != null) {
      plotSummary = json['overview'];
    } else if (json['description'] != null) {
      plotSummary = json['description'];
    } else if (json['s'] != null) {
      plotSummary = json['s'];
    }
    
    // Extract reviews
    List<Review>? reviews;
    if (json['reviews'] != null && json['reviews'] is List) {
      reviews = (json['reviews'] as List)
          .map((review) => Review.fromJson(review))
          .toList();
    } else if (json['userReviews'] != null && json['userReviews'] is List) {
      reviews = (json['userReviews'] as List)
          .map((review) => Review.fromJson(review))
          .toList();
    }
    
    print('Image URL found: $imageUrl');
    print('Plot summary found: $plotSummary');
    
    return MovieModel(
      id: json['id']?.toString() ?? json['imdbID']?.toString() ?? 'N/A',
      title: movieTitle,
      posterUrl: imageUrl,
      year: movieYear,
      genre: (json['genres'] != null && json['genres'] is List)
          ? (json['genres'] as List).join(', ')
          : (json['genre'] != null ? json['genre'].toString() : null),
      rating: json['rating'] != null ? 
        double.tryParse(json['rating'].toString()) : 
        (json['imDbRating'] != null ? double.tryParse(json['imDbRating'].toString()) : null),
      plotSummary: plotSummary,
      reviews: reviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_url': posterUrl,
      'year': year,
      'genre': genre,
      'rating': rating,
      'plot_summary': plotSummary,
      'reviews': reviews?.map((review) => review.toJson()).toList(),
    };
  }
}

class Review {
  final String author;
  final String content;
  final double? rating;
  final String? date;

  Review({
    required this.author,
    required this.content,
    this.rating,
    this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      author: json['author'] ?? json['username'] ?? 'Anonymous',
      content: json['content'] ?? json['text'] ?? json['review'] ?? 'No content',
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      date: json['date'] ?? json['created_at'] ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'content': content,
      'rating': rating,
      'date': date,
    };
  }
}