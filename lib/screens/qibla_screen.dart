import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../core/i18n/strings.dart';
import '../core/services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  Position? _position;
  bool _loadingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _position = position;
          _loadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString().replaceAll('Exception: ', '');
          _loadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('qibla')),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getLocation,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: StreamBuilder<CompassEvent?>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (_loadingLocation) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_locationError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: color.error),
                    const SizedBox(height: 16),
                    Text(
                      _locationError!,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _getLocation,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_position == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(s.t('no_sensor')),
                ],
              ),
            );
          }

          final heading = snapshot.data?.heading;
          if (heading == null || heading.isNaN || !heading.isFinite) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.compass_calibration, size: 64, color: color.error),
                  const SizedBox(height: 16),
                  Text(s.t('no_sensor')),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Check Compass'),
                  ),
                ],
              ),
            );
          }

          // Calculate Qibla bearing from user location to Kaaba
          final qiblaBearing = QiblaService.calculateBearing(
            _position!.latitude,
            _position!.longitude,
          );

          // Convert to radians
          final headingRad = heading * math.pi / 180.0;
          final qiblaRad = qiblaBearing * math.pi / 180.0;

          // The relative angle from device heading to Qibla direction
          // When device points North (heading=0), arrow should point at qiblaBearing
          // When device rotates, arrow needs to adjust by the difference
          final relativeAngle = qiblaRad - headingRad;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Compass container
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 4,
                      color: color.outline,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Compass dial - rotates with device heading
                      // Rotate it opposite to heading so North always points to screen top
                      Transform.rotate(
                        angle: -headingRad,
                        child: _buildCompassDial(),
                      ),
                      // Qibla arrow - points in direction relative to device
                      Transform.rotate(
                        angle: relativeAngle,
                        child: Icon(
                          Icons.navigation,
                          size: 150,
                          color: color.primary,
                        ),
                      ),
                      // Center dot (doesn't rotate)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.primary,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Qibla direction info
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: color.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.explore, color: color.onPrimaryContainer, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            s.t('qibla_direction'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: color.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${qiblaBearing.toStringAsFixed(1)}°',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: color.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDirectionName(qiblaBearing),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: color.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompassDial() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // North
          Positioned(
            top: 15,
            child: Text(
              'N',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // East
          Positioned(
            right: 15,
            child: Text(
              'E',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // South
          Positioned(
            bottom: 15,
            child: Text(
              'S',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          // West
          Positioned(
            left: 15,
            child: Text(
              'W',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDirectionName(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return 'North';
    if (bearing >= 22.5 && bearing < 67.5) return 'Northeast';
    if (bearing >= 67.5 && bearing < 112.5) return 'East';
    if (bearing >= 112.5 && bearing < 157.5) return 'Southeast';
    if (bearing >= 157.5 && bearing < 202.5) return 'South';
    if (bearing >= 202.5 && bearing < 247.5) return 'Southwest';
    if (bearing >= 247.5 && bearing < 292.5) return 'West';
    return 'Northwest';
  }
}
