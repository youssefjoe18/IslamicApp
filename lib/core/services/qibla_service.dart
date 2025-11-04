import 'dart:math' as math;

class QiblaService {
  // Kaaba coordinates (Mecca)
  static const double kaabaLatitude = 21.4225241;
  static const double kaabaLongitude = 39.8261818;

  /// Calculate the bearing from user's location to Kaaba
  static double calculateBearing(double userLatitude, double userLongitude) {
    final lat1 = userLatitude * math.pi / 180;
    final lat2 = kaabaLatitude * math.pi / 180;
    final deltaLon = (kaabaLongitude - userLongitude) * math.pi / 180;

    final y = math.sin(deltaLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);

    final bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360; // Convert to degrees and normalize
  }
}

