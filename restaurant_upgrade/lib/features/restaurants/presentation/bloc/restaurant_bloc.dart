import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_restaurants_usecase.dart';
import '../../domain/usecases/get_restaurant_by_id_usecase.dart';
import '../../domain/usecases/get_restaurants_near_location_usecase.dart';
import '../../domain/usecases/add_restaurant_usecase.dart';
import '../../domain/usecases/get_restaurant_categories_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import 'restaurant_event.dart';
import 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetRestaurantsUseCase getRestaurantsUseCase;
  final GetRestaurantByIdUseCase getRestaurantByIdUseCase;
  final GetRestaurantsNearLocationUseCase getRestaurantsNearLocationUseCase;
  final AddRestaurantUseCase addRestaurantUseCase;
  final GetRestaurantCategoriesUseCase getRestaurantCategoriesUseCase;

  StreamSubscription? _restaurantsSubscription;

  RestaurantBloc({
    required this.getRestaurantsUseCase,
    required this.getRestaurantByIdUseCase,
    required this.getRestaurantsNearLocationUseCase,
    required this.addRestaurantUseCase,
    required this.getRestaurantCategoriesUseCase,
  }) : super(const RestaurantInitial()) {
    on<RestaurantLoadRequested>(_onRestaurantLoadRequested);
    on<RestaurantByIdLoadRequested>(_onRestaurantByIdLoadRequested);
    on<RestaurantNearLocationLoadRequested>(_onRestaurantNearLocationLoadRequested);
    on<RestaurantSearchRequested>(_onRestaurantSearchRequested);
    on<RestaurantCategoriesLoadRequested>(_onRestaurantCategoriesLoadRequested);
    on<RestaurantFilterChanged>(_onRestaurantFilterChanged);
    on<RestaurantRefreshRequested>(_onRestaurantRefreshRequested);
    on<RestaurantAddRequested>(_onRestaurantAddRequested);
  }

  Future<void> _onRestaurantLoadRequested(
    RestaurantLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    print('🔄 RestaurantBloc: Loading restaurants...');
    emit(const RestaurantLoading());

    final result = await getRestaurantsUseCase(GetRestaurantsParams(
      category: event.category,
      minRating: event.minRating,
      searchQuery: event.searchQuery,
      limit: event.limit,
    ));
    
    print('📊 RestaurantBloc: UseCase result received');

    result.fold(
      (failure) {
        print('❌ RestaurantBloc: Error - ${failure.message}');
        emit(RestaurantError(
          message: failure.message,
          code: failure.code,
        ));
      },
      (restaurantsStream) {
        print('✅ RestaurantBloc: Stream received, setting up listener');
        _restaurantsSubscription?.cancel();
        _restaurantsSubscription = restaurantsStream.listen(
          (restaurants) {
            print('📋 RestaurantBloc: Received ${restaurants.length} restaurants');
            if (!emit.isDone) {
              if (restaurants.isEmpty) {
                print('📭 RestaurantBloc: No restaurants found');
                emit(const RestaurantEmpty());
              } else {
                print('🏪 RestaurantBloc: Emitting ${restaurants.length} restaurants');
                emit(RestaurantLoaded(
                  restaurants: restaurants,
                  currentCategory: event.category,
                  currentMinRating: event.minRating,
                  currentSearchQuery: event.searchQuery,
                ));
              }
            }
          },
          onError: (error) {
            print('❌ RestaurantBloc: Stream error - $error');
            if (!emit.isDone) {
              emit(RestaurantError(
                message: error.toString(),
                code: 'stream-error',
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onRestaurantByIdLoadRequested(
    RestaurantByIdLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());

    final result = await getRestaurantByIdUseCase(
      GetRestaurantByIdParams(restaurantId: event.restaurantId),
    );

    result.fold(
      (failure) => emit(RestaurantError(
        message: failure.message,
        code: failure.code,
      )),
      (restaurant) => emit(RestaurantDetailLoaded(restaurant: restaurant)),
    );
  }

  Future<void> _onRestaurantNearLocationLoadRequested(
    RestaurantNearLocationLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLocationLoading(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusInKm: event.radiusInKm,
    ));

    final result = await getRestaurantsNearLocationUseCase(
      GetRestaurantsNearLocationParams(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusInKm: event.radiusInKm,
        category: event.category,
        minRating: event.minRating,
        limit: event.limit,
      ),
    );

    result.fold(
      (failure) => emit(RestaurantError(
        message: failure.message,
        code: failure.code,
      )),
      (restaurantsStream) {
        _restaurantsSubscription?.cancel();
        _restaurantsSubscription = restaurantsStream.listen(
          (restaurants) {
            if (restaurants.isEmpty) {
              emit(const RestaurantEmpty(
                message: 'Không tìm thấy nhà hàng nào trong khu vực này',
              ));
            } else {
              emit(RestaurantLocationLoaded(
                restaurants: restaurants,
                latitude: event.latitude,
                longitude: event.longitude,
                radiusInKm: event.radiusInKm,
              ));
            }
          },
          onError: (error) {
            emit(RestaurantError(
              message: error.toString(),
              code: 'location-stream-error',
            ));
          },
        );
      },
    );
  }

  Future<void> _onRestaurantSearchRequested(
    RestaurantSearchRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantSearchLoading(query: event.query));

    final result = await getRestaurantsUseCase(GetRestaurantsParams(
      searchQuery: event.query,
      category: event.category,
      minRating: event.minRating,
      limit: event.limit,
    ));

    result.fold(
      (failure) => emit(RestaurantError(
        message: failure.message,
        code: failure.code,
      )),
      (restaurantsStream) {
        _restaurantsSubscription?.cancel();
        _restaurantsSubscription = restaurantsStream.listen(
          (restaurants) {
            if (restaurants.isEmpty) {
              emit(const RestaurantEmpty(
                message: 'Không tìm thấy nhà hàng nào phù hợp với từ khóa tìm kiếm',
              ));
            } else {
              emit(RestaurantSearchLoaded(
                restaurants: restaurants,
                query: event.query,
              ));
            }
          },
          onError: (error) {
            emit(RestaurantError(
              message: error.toString(),
              code: 'search-stream-error',
            ));
          },
        );
      },
    );
  }

  Future<void> _onRestaurantCategoriesLoadRequested(
    RestaurantCategoriesLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    final result = await getRestaurantCategoriesUseCase(const NoParams());

    result.fold(
      (failure) => emit(RestaurantError(
        message: failure.message,
        code: failure.code,
      )),
      (categories) => emit(RestaurantCategoriesLoaded(categories: categories)),
    );
  }

  Future<void> _onRestaurantFilterChanged(
    RestaurantFilterChanged event,
    Emitter<RestaurantState> emit,
  ) async {
    // Reload restaurants with new filters
    add(RestaurantLoadRequested(
      category: event.category,
      minRating: event.minRating,
    ));
  }

  Future<void> _onRestaurantRefreshRequested(
    RestaurantRefreshRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    // Get current state parameters and reload
    if (state is RestaurantLoaded) {
      final currentState = state as RestaurantLoaded;
      add(RestaurantLoadRequested(
        category: currentState.currentCategory,
        minRating: currentState.currentMinRating,
        searchQuery: currentState.currentSearchQuery,
      ));
    } else {
      add(const RestaurantLoadRequested());
    }
  }

  Future<void> _onRestaurantAddRequested(
    RestaurantAddRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());

    final result = await addRestaurantUseCase(AddRestaurantParams(
      name: event.name,
      description: event.description,
      address: event.address,
      phoneNumber: event.phoneNumber,
      website: event.website,
      imageUrls: event.imageUrls,
      latitude: event.latitude,
      longitude: event.longitude,
      categories: event.categories,
      ownerId: event.ownerId,
    ));

    result.fold(
      (failure) => emit(RestaurantError(
        message: failure.message,
        code: failure.code,
      )),
      (restaurant) => emit(RestaurantAddSuccess(restaurant: restaurant)),
    );
  }

  @override
  Future<void> close() {
    _restaurantsSubscription?.cancel();
    return super.close();
  }
}