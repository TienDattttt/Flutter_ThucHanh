class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String? coverImageUrl;
  final String assetPath;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    this.coverImageUrl,
    required this.assetPath,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      assetPath: json['assetPath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'assetPath': assetPath,
    };
  }
}
