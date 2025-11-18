import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';

class ReviewImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final double maxHeight;
  final VoidCallback? onImageTap;

  const ReviewImageGallery({
    super.key,
    required this.imageUrls,
    this.maxHeight = 200,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    if (imageUrls.length == 1) {
      return _buildSingleImage(context, imageUrls.first);
    }

    return _buildMultipleImages(context);
  }

  Widget _buildSingleImage(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () => _showImageViewer(context, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: maxHeight,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: maxHeight,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: maxHeight,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: const Center(
              child: Icon(Icons.error_outline),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleImages(BuildContext context) {
    return SizedBox(
      height: maxHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        separatorBuilder: (context, index) => const SizedBox(
          width: AppConstants.smallPadding,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageViewer(context, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Center(
                      child: Icon(Icons.error_outline),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageViewerPage(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class ImageViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewerPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}