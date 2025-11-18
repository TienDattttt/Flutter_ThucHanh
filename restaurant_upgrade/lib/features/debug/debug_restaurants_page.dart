import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

class DebugRestaurantsPage extends StatefulWidget {
  const DebugRestaurantsPage({super.key});

  @override
  State<DebugRestaurantsPage> createState() => _DebugRestaurantsPageState();
}

class _DebugRestaurantsPageState extends State<DebugRestaurantsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔍 Debug: Loading restaurants directly from Firestore...');
      
      final snapshot = await _firestore
          .collection(AppConstants.restaurantsCollection)
          .get();
      
      print('📄 Debug: Got ${snapshot.docs.length} documents');
      
      final restaurants = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      
      print('✅ Debug: Processed ${restaurants.length} restaurants');
      
      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Debug: Error loading restaurants: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Restaurants'),
        actions: [
          IconButton(
            onPressed: _loadRestaurants,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading restaurants...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Error: $_error'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRestaurants,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No restaurants found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(restaurant['name'] ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant['description'] ?? ''),
                SizedBox(height: 4),
                Text('Rating: ${restaurant['averageRating'] ?? 0}'),
                Text('Reviews: ${restaurant['totalReviews'] ?? 0}'),
                Text('Active: ${restaurant['isActive'] ?? false}'),
                if (restaurant['location'] != null)
                  Text('Location: ${restaurant['location']['latitude']}, ${restaurant['location']['longitude']}'),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}