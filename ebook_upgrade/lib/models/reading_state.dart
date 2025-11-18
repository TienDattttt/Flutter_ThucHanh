class ReadingState {
  final String bookId;
  final int currentPage;
  final int totalPages;
  final DateTime lastReadAt;

  ReadingState({
    required this.bookId,
    required this.currentPage,
    required this.totalPages,
    required this.lastReadAt,
  });

  factory ReadingState.fromMap(Map<String, dynamic> map) {
    return ReadingState(
      bookId: map['book_id'] as String,
      currentPage: map['current_page'] as int,
      totalPages: map['total_pages'] as int,
      lastReadAt: DateTime.parse(map['last_read_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'book_id': bookId,
      'current_page': currentPage,
      'total_pages': totalPages,
      'last_read_at': lastReadAt.toIso8601String(),
    };
  }
}
