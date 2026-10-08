import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/sighting_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

/// Service providing real‑time dengue vector sighting streams from Firestore.
class SightingFeedService {
  static final SightingFeedService _instance = SightingFeedService._internal();
  factory SightingFeedService() => _instance;
  SightingFeedService._internal();

  final _db = FirebaseFirestore.instance;

  /// Returns a real-time stream of dengue vector sightings within [radiusM] meters of [center].
  /// Per documentation, sightings are shown within a fixed 100 m radius.
  /// Filters out sightings older than 7 days.
  Stream<List<Sighting>> sightingsNear(
    LatLng center, {
    double radiusM = AppConstants.communityRadiusMeters,
  }) {
    // 1. Compute bounding box deltas
    // ~111.32 km per degree of latitude
    final double latDelta = radiusM / 111320.0;
    // Longitude length varies with latitude
    final double lngDelta =
        radiusM / (111320.0 * math.cos(center.latitudeInRad));

    final double minLat = center.latitude - latDelta;
    final double maxLat = center.latitude + latDelta;
    final double minLng = center.longitude - lngDelta;
    final double maxLng = center.longitude + lngDelta;

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final distanceCalc = const Distance();

    // 2. Firestore bounding-box query on lat, and time filter
    return _db
        .collection('sightings')
        .where('lat', isGreaterThanOrEqualTo: minLat)
        .where('lat', isLessThanOrEqualTo: maxLat)
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo),
        )
        .orderBy('lat')
        .snapshots()
        .handleError((Object err) {
          // Surface index / permission errors so callers can show a UI message
          // instead of a permanently blank map.
          debugPrint('SightingFeedService stream error: $err');
        })
        .map((snapshot) {
          final List<Sighting> validSightings = [];

          for (var doc in snapshot.docs) {
            try {
              final data = doc.data();
              // Use (num).toDouble() to handle both int and double from Firestore
              final double lat = (data['lat'] as num).toDouble();
              final double lng = (data['lng'] as num).toDouble();

              // 3. Client-side longitude filter
              if (lng >= minLng && lng <= maxLng) {
                final latLng = LatLng(lat, lng);

                // 4. True Haversine distance filter (circle, not bounding box)
                final distance = distanceCalc.as(
                  LengthUnit.Meter,
                  center,
                  latLng,
                );
                if (distance <= radiusM) {
                  // Map species string to enum
                  Species species = Species.aegypti;
                  if (data['species'] == 'albopictus') {
                    species = Species.albopictus;
                  }

                  final bearing = _getBearingString(center, latLng);
                  final timestamp = (data['timestamp'] as Timestamp).toDate();
                  final isOwnSighting =
                      data['userId'] == FirebaseAuth.instance.currentUser?.uid;

                  validSightings.add(
                    Sighting(
                      id: doc.id,
                      species: species,
                      location: latLng,
                      timestamp: timestamp,
                      distance: distance,
                      bearing: bearing,
                      isOwnSighting: isOwnSighting,
                    ),
                  );
                }
              }
            } catch (docErr) {
              // Skip malformed documents rather than crashing the whole stream
              debugPrint('SightingFeedService: skipped malformed doc ${doc.id}: $docErr');
            }
          }
          return validSightings;
        });

  }

  String _getBearingString(LatLng center, LatLng target) {
    // A simplified bearing logic. For precise bearing, latlong2 has bearing features.
    final dy = target.latitude - center.latitude;
    final dx = target.longitude - center.longitude;
    final angle = math.atan2(dy, dx) * 180 / math.pi;

    if (angle >= -22.5 && angle < 22.5) return 'E';
    if (angle >= 22.5 && angle < 67.5) return 'NE';
    if (angle >= 67.5 && angle < 112.5) return 'N';
    if (angle >= 112.5 && angle < 157.5) return 'NW';
    if (angle >= 157.5 || angle < -157.5) return 'W';
    if (angle >= -157.5 && angle < -112.5) return 'SW';
    if (angle >= -112.5 && angle < -67.5) return 'S';
    if (angle >= -67.5 && angle < -22.5) return 'SE';
    return 'N';
  }
}
