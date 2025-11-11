import 'dart:convert';
import 'package:ebook/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BookCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final String response = await rootBundle.loadString('assets/data/books.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _categories = data.map((json) => BookCategory.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Lỗi đọc file books.json: $e");
      setState(() => _isLoading = false);
    }
  }

  void _openBook(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReaderPage(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBookLibrary(),
    );
  }

  Widget _buildBookLibrary() {
    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Text(
                category.category,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: category.books.length,
                itemBuilder: (context, bookIndex) {
                  final book = category.books[bookIndex];
                  return _buildBookItem(book);
                },
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildBookItem(Book book) {
    return GestureDetector(
      onTap: () => _openBook(book),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  book.thumbnail,
                  width: 120,
                  height: 170,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 120,
                    height: 170,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, color: Colors.grey, size: 50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book.author,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ReaderPage extends StatefulWidget {
  final Book book;
  const ReaderPage({super.key, required this.book});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final epubController = EpubController();
  String? _lastCfi;

  String get _prefsKey => 'book_cfi_${widget.book.epubPath}';

  @override
  void initState() {
    super.initState();
    _loadLastCfi();
  }

  Future<void> _loadLastCfi() async {
    final prefs = await SharedPreferences.getInstance();
    _lastCfi = prefs.getString(_prefsKey);
    setState(() {});
  }

  Future<void> _saveLastCfi(String cfi) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, cfi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: EpubViewer(
          epubSource: EpubSource.fromAsset('assets/${widget.book.epubPath}'),
          epubController: epubController,
          displaySettings: EpubDisplaySettings(
            flow: EpubFlow.paginated,
            snap: true,
            useSnapAnimationAndroid: false,
          ),

          // Khi EPUB load xong → resume lại vị trí đọc cuối
          onEpubLoaded: () async {
            if (_lastCfi != null && _lastCfi!.isNotEmpty) {
              try {
                await epubController.display(cfi: _lastCfi!);
                debugPrint('📖 Khôi phục vị trí: $_lastCfi');
              } catch (e) {
                debugPrint('⚠️ Không thể khôi phục vị trí: $e');
              }
            } else {
              debugPrint('📖 Bắt đầu đọc từ đầu');
            }
          },

          // Khi lật trang → lưu vị trí mới
          onRelocated: (EpubLocation location) async {
            try {
              final currentLoc = await epubController.getCurrentLocation();
              final cfi = currentLoc.toJson()['cfi'] as String?;
              if (cfi != null && cfi.isNotEmpty) {
                await _saveLastCfi(cfi);
                debugPrint('💾 Lưu vị trí đọc: $cfi');
              }
            } catch (e) {
              debugPrint('⚠️ Lỗi khi lưu vị trí: $e');
            }
          },
        ),
      ),
    );
  }
}

