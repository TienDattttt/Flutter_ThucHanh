import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/reading_state_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/page_viewer.dart';
import '../widgets/control_panel.dart';
import '../widgets/animated_settings_panel.dart';

class BookReaderScreen extends StatefulWidget {
  final Book book;

  const BookReaderScreen({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  bool _isControlPanelVisible = false;
  bool _hasLoadedBook = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedBook) {
      _hasLoadedBook = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadBook();
      });
    }
  }

  Future<void> _loadBook() async {
    final readingProvider = context.read<ReadingStateProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    
    final size = MediaQuery.of(context).size;
    await readingProvider.loadBook(
      widget.book,
      size.width,
      size.height,
      settingsProvider.fontSize,
    );
  }

  void _toggleControlPanel() {
    setState(() {
      _isControlPanelVisible = !_isControlPanelVisible;
    });
  }

  void _showSettingsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return AnimatedSettingsPanel(
            isDarkMode: settingsProvider.isDarkMode,
            fontSize: settingsProvider.fontSize,
            onThemeToggle: (value) {
              settingsProvider.toggleTheme();
            },
            onFontSizeChange: (size) {
              settingsProvider.setFontSize(size);
              // Repaginate with new font size
              final readingProvider = context.read<ReadingStateProvider>();
              final screenSize = MediaQuery.of(context).size;
              readingProvider.repaginate(
                screenSize.width,
                screenSize.height,
                size,
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer2<ReadingStateProvider, SettingsProvider>(
              builder: (context, readingProvider, settingsProvider, child) {
                if (readingProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (readingProvider.pages.isEmpty) {
                  return const Center(
                    child: Text('Không thể tải nội dung sách'),
                  );
                }

                return Stack(
                  children: [
                    // Page viewer
                    GestureDetector(
                      onTap: _toggleControlPanel,
                      child: PageViewer(
                        pages: readingProvider.pages,
                        initialPage: readingProvider.currentPage,
                        fontSize: settingsProvider.fontSize,
                        onPageChanged: (page) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            readingProvider.goToPage(page);
                          });
                        },
                      ),
                    ),
                    // Control panel
                    ControlPanel(
                      isVisible: _isControlPanelVisible,
                      currentPage: readingProvider.currentPage,
                      totalPages: readingProvider.totalPages,
                      onSettingsTap: _showSettingsPanel,
                    ),
                  ],
                );
              },
            ),
    );
  }
}
