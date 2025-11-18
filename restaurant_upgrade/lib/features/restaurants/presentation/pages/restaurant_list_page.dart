import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../bloc/restaurant_bloc.dart';
import '../bloc/restaurant_event.dart';
import '../bloc/restaurant_state.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/restaurant_filter_bar.dart';
import '../widgets/restaurant_search_bar.dart';
import 'restaurant_detail_page.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  State<RestaurantListPage> createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final _scrollController = ScrollController();
  String? _selectedCategory;
  double? _selectedMinRating;

  @override
  void initState() {
    super.initState();
    // Load restaurants when page initializes
    context.read<RestaurantBloc>().add(const RestaurantLoadRequested());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onRestaurantTap(String restaurantId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RestaurantDetailPage(restaurantId: restaurantId),
      ),
    );
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      context.read<RestaurantBloc>().add(RestaurantLoadRequested(
        category: _selectedCategory,
        minRating: _selectedMinRating,
      ));
    } else {
      context.read<RestaurantBloc>().add(RestaurantSearchRequested(
        query: query,
        category: _selectedCategory,
        minRating: _selectedMinRating,
      ));
    }
  }

  void _onFilterChanged({String? category, double? minRating}) {
    setState(() {
      _selectedCategory = category;
      _selectedMinRating = minRating;
    });

    context.read<RestaurantBloc>().add(RestaurantFilterChanged(
      category: category,
      minRating: minRating,
    ));
  }

  void _onRefresh() {
    context.read<RestaurantBloc>().add(const RestaurantRefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhà hàng'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: RestaurantSearchBar(
              onSearch: _onSearch,
              hintText: 'Tìm kiếm nhà hàng...',
            ),
          ),

          // Filter Bar
          RestaurantFilterBar(
            selectedCategory: _selectedCategory,
            selectedMinRating: _selectedMinRating,
            onFilterChanged: _onFilterChanged,
          ),

          // Restaurant List
          Expanded(
            child: BlocBuilder<RestaurantBloc, RestaurantState>(
              builder: (context, state) {
                print('🖥️ RestaurantListPage: Current state: ${state.runtimeType}');
                if (state is RestaurantLoading) {
                  return const LoadingWidget(message: 'Đang tải danh sách nhà hàng...');
                } else if (state is RestaurantError) {
                  return ErrorDisplayWidget(
                    message: state.message,
                    onRetry: _onRefresh,
                  );
                } else if (state is RestaurantEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.restaurant_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        ElevatedButton(
                          onPressed: _onRefresh,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                } else if (state is RestaurantLoaded) {
                  print('🏪 RestaurantListPage: Displaying ${state.restaurants.length} restaurants');
                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      itemCount: state.restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = state.restaurants[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.defaultPadding,
                          ),
                          child: RestaurantCard(
                            restaurant: restaurant,
                            onTap: () => _onRestaurantTap(restaurant.id),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is RestaurantSearchLoading) {
                  return const LoadingWidget(message: 'Đang tìm kiếm...');
                } else if (state is RestaurantSearchLoaded) {
                  return Column(
                    children: [
                      // Search Results Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Text(
                          'Kết quả tìm kiếm cho "${state.query}": ${state.restaurants.length} nhà hàng',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      // Search Results List
                      Expanded(
                        child: state.restaurants.isEmpty
                            ? const Center(
                                child: Text('Không tìm thấy nhà hàng nào'),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                                itemCount: state.restaurants.length,
                                itemBuilder: (context, index) {
                                  final restaurant = state.restaurants[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppConstants.defaultPadding,
                                    ),
                                    child: RestaurantCard(
                                      restaurant: restaurant,
                                      onTap: () => _onRestaurantTap(restaurant.id),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                } else if (state is RestaurantLocationLoading) {
                  return const LoadingWidget(message: 'Đang tìm nhà hàng gần bạn...');
                } else if (state is RestaurantLocationLoaded) {
                  return Column(
                    children: [
                      // Location Results Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppConstants.defaultPadding),
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Text(
                          'Nhà hàng trong bán kính ${state.radiusInKm}km: ${state.restaurants.length} nhà hàng',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      // Location Results List
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          itemCount: state.restaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = state.restaurants[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppConstants.defaultPadding,
                              ),
                              child: RestaurantCard(
                                restaurant: restaurant,
                                onTap: () => _onRestaurantTap(restaurant.id),
                                showDistance: true,
                                userLatitude: state.latitude,
                                userLongitude: state.longitude,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const Center(
                  child: Text('Chưa có dữ liệu'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}