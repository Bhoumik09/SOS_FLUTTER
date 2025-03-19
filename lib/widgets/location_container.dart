import 'package:emergency_app/Provider/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class LocationContainer extends StatelessWidget {
  const LocationContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final Position? _position = locationProvider.currentPosition;
    final String _error = locationProvider.locationError;
    final bool _isLoading = locationProvider.isLoading;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Show loading spinner when fetching location
        if (_isLoading) const CircularProgressIndicator(),

        // If an error occurred, display the error message
        if (_error.isNotEmpty)
          Text(
            _error,
            style: const TextStyle(color: Colors.red),
          ),

        // If the location is available, display it
        if (!_isLoading && _position != null && _error=='')
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(
                child: Text(
                  "Location Fetched Successfully",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

        // Default state when waiting for location
        if (!_isLoading && _position == null && _error.isEmpty)
          const Text('Waiting for location...'),

        const SizedBox(height: 16),        
      ],
    );
  }
}
