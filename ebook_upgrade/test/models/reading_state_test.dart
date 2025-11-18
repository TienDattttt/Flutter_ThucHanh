import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_upgrade/models/reading_state.dart';

void main() {
  group('ReadingState Model Tests', () {
    test('ReadingState fromMap should create valid object', () {
      final now = DateTime.now();
      final map = {
        'book_id': '1',
        'current_page': 5,
        'total_pages': 100,
        'last_read_at': now.toIso8601String(),
      };

      final state = ReadingState.fromMap(map);

      expect(state.bookId, '1');
      expect(state.currentPage, 5);
      expect(state.totalPages, 100);
      expect(state.lastReadAt.toIso8601String(), now.toIso8601String());
    });

    test('ReadingState toMap should create valid map', () {
      final now = DateTime.now();
      final state = ReadingState(
        bookId: '1',
        currentPage: 5,
        totalPages: 100,
        lastReadAt: now,
      );

      final map = state.toMap();

      expect(map['book_id'], '1');
      expect(map['current_page'], 5);
      expect(map['total_pages'], 100);
      expect(map['last_read_at'], now.toIso8601String());
    });
  });
}
