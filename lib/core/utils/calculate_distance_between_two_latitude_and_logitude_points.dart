import 'dart:math';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371;
  double dLat = (lat2 - lat1) * pi / 180.0;
  double dLon = (lon2 - lon1) * pi / 180.0;

  lat1 = lat1 * pi / 180.0;
  lat2 = lat2 * pi / 180.0;

  double a = sin(dLat / 2) * sin(dLat / 2) +
      sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}