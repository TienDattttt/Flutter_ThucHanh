import 'package:flutter/material.dart';

class PageViewer extends StatefulWidget {
  final List<String> pages;
  final int initialPage;
  final double fontSize;
  final Function(int) onPageChanged;

  const PageViewer({
    Key? key,
    required this.pages,
    required this.initialPage,
    required this.fontSize,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  State<PageViewer> createState() => _PageViewerState();
}

class _PageViewerState extends State<PageViewer> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void didUpdateWidget(PageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPage != widget.initialPage) {
      _pageController.jumpToPage(widget.initialPage);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) {
      return const Center(
        child: Text('Không có nội dung'),
      );
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: widget.onPageChanged,
      itemCount: widget.pages.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: widget.fontSize,
                height: 1.6,
                letterSpacing: 0.3,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              child: Text(widget.pages[index]),
            ),
          ),
        );
      },
    );
  }
}
