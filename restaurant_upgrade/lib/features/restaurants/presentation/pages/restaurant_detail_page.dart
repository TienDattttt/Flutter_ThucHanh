import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';

import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../bloc/restaurant_bloc.dart';
import '../bloc/restaurant_event.dart';
import '../bloc/restaurant_state.dart';
import '../widgets/restaurant_info_section.dart';
import '../widgets/restaurant_rating_section.dart';
import '../widgets/restaurant_image_gallery.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailPage({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load restaurant details when page initializes
    context.read<RestaurantBloc>().add(
      RestaurantByIdLoadRequested(restaurantId: widget.restaurantId),
    );
  }

  void _onRefresh() {
    context.read<RestaurantBloc>().add(
      RestaurantByIdLoadRequested(restaurantId: widget.restaurantId),
    );
  }

  void _showImageGallery(Restaurant restaurant, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RestaurantImageGallery(
          imageUrls: restaurant.imageUrls,
          initialIndex: initialIndex,
          restaurantName: restaurant.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
        builder: (context, state) {
          if (state is RestaurantLoading) {
            return const Scaffold(
              appBar: null,
              body: LoadingWidget(message: 'Đang tải thông tin nhà hàng...'),
            );
          } else if (state is RestaurantError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Chi tiết nhà hàng'),
              ),
              body: ErrorDisplayWidget(
                message: state.message,
                onRetry: _onRefresh,
              ),
            );
          } else if (state is RestaurantDetailLoaded) {
            final restaurant = state.restaurant;
            return _buildRestaurantDetail(restaurant);
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Chi tiết nhà hàng'),
            ),
            body: const Center(
              child: Text('Không tìm thấy thông tin nhà hàng'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantDetail(Restaurant restaurant) {
    return CustomScrollView(
      slivers: [
        // App Bar with Image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              restaurant.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            background: restaurant.imageUrls.isNotEmpty
                ? GestureDetector(
                    onTap: () => _showImageGallery(restaurant, 0),
                    child: CachedNetworkImage(
                      imageUrl: restaurant.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _onRefresh,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ],
        ),

        // Restaurant Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Section
              RestaurantRatingSection(restaurant: restaurant),

              const Divider(),

              // Info Section
              RestaurantInfoSection(restaurant: restaurant),

              const Divider(),

              // Images Section
              if (restaurant.imageUrls.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hình ảnh (${restaurant.imageUrls.length})',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: restaurant.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < restaurant.imageUrls.length - 1
                                    ? AppConstants.smallPadding
                                    : 0,
                              ),
                              child: GestureDetector(
                                onTap: () => _showImageGallery(restaurant, index),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.defaultBorderRadius,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: restaurant.imageUrls[index],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],

              // Categories Section
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danh mục',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                    Wrap(
                      spacing: AppConstants.smallPadding,
                      runSpacing: AppConstants.smallPadding,
                      children: restaurant.categories.map((category) {
                        return Chip(
                          label: Text(category),
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Reviews Section Placeholder
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đánh giá',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to reviews page
                          },
                          child: const Text('Xem tất cả'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius,
                        ),
                      ),
                      child: const Text(
                        'Chức năng đánh giá sẽ được triển khai trong Task 5',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom spacing
              const SizedBox(height: AppConstants.largePadding),
            ],
          ),
        ),
      ],
    );
  }
}