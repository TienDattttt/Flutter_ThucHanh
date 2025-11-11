class BookCategory {
  final String category;
  final List<Book> books;

  BookCategory({required this.category, required this.books});

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    var bookList = json['books'] as List;
    List<Book> books = bookList.map((i) => Book.fromJson(i)).toList();
    return BookCategory(
      category: json['category'],
      books: books,
    );
  }
}

class Book {
  final String title;
  final String author;
  final String thumbnail;
  final String epubPath;

  Book({
    required this.title,
    required this.author,
    required this.thumbnail,
    required this.epubPath,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      thumbnail: json['thumbnail'],
      epubPath: json['epubPath'],
    );
  }
}