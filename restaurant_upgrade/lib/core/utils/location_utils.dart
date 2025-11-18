import 'dart:math';

class LocationUtils {
  /// Calculate distance between two points using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert degrees to radians
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Format distance for display
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '${meters}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  /// Check if location is within radius
  static bool isWithinRadius(
    double centerLat,
    double centerLon,
    double pointLat,
    double pointLon,
    double radiusInKm,
  ) {
    final distance = calculateDistance(centerLat, centerLon, pointLat, pointLon);
    return distance <= radiusInKm;
  }

  /// Get bounding box for a given center point and radius
  /// Returns [minLat, minLon, maxLat, maxLon]
  static List<double> getBoundingBox(
    double centerLat,
    double centerLon,
    double radiusInKm,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Calculate the angular distance
    final double angularDistance = radiusInKm / earthRadius;

    // Convert to radians
    final double centerLatRad = _degreesToRadians(centerLat);
    final double centerLonRad = _degreesToRadians(centerLon);

    // Calculate min/max latitude
    final double minLatRad = centerLatRad - angularDistance;
    final double maxLatRad = centerLatRad + angularDistance;

    // Calculate min/max longitude
    final double deltaLon = asin(sin(angularDistance) / cos(centerLatRad));
    final double minLonRad = centerLonRad - deltaLon;
    final double maxLonRad = centerLonRad + deltaLon;

    // Convert back to degrees
    final double minLat = _radiansToDegrees(minLatRad);
    final double maxLat = _radiansToDegrees(maxLatRad);
    final double minLon = _radiansToDegrees(minLonRad);
    final double maxLon = _radiansToDegrees(maxLonRad);

    return [minLat, minLon, maxLat, maxLon];
  }

  /// Convert radians to degrees
  static double _radiansToDegrees(double radians) {
    return radians * (180 / pi);
  }

  /// Validate latitude
  static bool isValidLatitude(double latitude) {
    return latitude >= -90 && latitude <= 90;
  }

  /// Validate longitude
  static bool isValidLongitude(double longitude) {
    return longitude >= -180 && longitude <= 180;
  }

  /// Validate coordinates
  static bool isValidCoordinates(double latitude, double longitude) {
    return isValidLatitude(latitude) && isValidLongitude(longitude);
  }

  /// Format coordinates for display
  static String formatCoordinates(double latitude, double longitude) {
    final latDirection = latitude >= 0 ? 'N' : 'S';
    final lonDirection = longitude >= 0 ? 'E' : 'W';
    
    return '${latitude.abs().toStringAsFixed(6)}°$latDirection, ${longitude.abs().toStringAsFixed(6)}°$lonDirection';
  }

  /// Get bearing between two points
  /// Returns bearing in degrees (0-360)
  static double getBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double lat1Rad = _degreesToRadians(lat1);
    final double lat2Rad = _degreesToRadians(lat2);

    final double y = sin(dLon) * cos(lat2Rad);
    final double x = cos(lat1Rad) * sin(lat2Rad) - sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    double bearing = _radiansToDegrees(atan2(y, x));
    
    // Normalize to 0-360 degrees
    bearing = (bearing + 360) % 360;
    
    return bearing;
  }

  /// Get compass direction from bearing
  static String getCompassDirection(double bearing) {
    const directions = [
      'Bắc', 'Đông Bắc', 'Đông', 'Đông Nam',
      'Nam', 'Tây Nam', 'Tây', 'Tây Bắc'
    ];
    
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Check if point is inside polygon (for geofencing)
  static bool isPointInPolygon(
    double pointLat,
    double pointLon,
    List<List<double>> polygon,
  ) {
    int intersections = 0;
    
    for (int i = 0; i < polygon.length; i++) {
      final j = (i + 1) % polygon.length;
      
      final double lat1 = polygon[i][0];
      final double lon1 = polygon[i][1];
      final double lat2 = polygon[j][0];
      final double lon2 = polygon[j][1];
      
      if (((lat1 > pointLat) != (lat2 > pointLat)) &&
          (pointLon < (lon2 - lon1) * (pointLat - lat1) / (lat2 - lat1) + lon1)) {
        intersections++;
      }
    }
    
    return intersections % 2 == 1;
  }
}