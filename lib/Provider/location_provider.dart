import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String _locationError = '';
  bool _isLoading = false;

  Position? get currentPosition => _currentPosition;
  String get locationError => _locationError;
  bool get isLoading => _isLoading;

  // Method to fetch the location
  Future<void> fetchLocation() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.requestPermission();
        _locationError = 'Location services are disabled.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('HELLO');
        
        permission = await Geolocator.requestPermission();
        if (permission==LocationPermission.denied) {
        
          _locationError = 'Location permissions are denied, It is needed to proceed';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best)
      );
      print('Current Position: $_currentPosition.latitude, $_currentPosition.longitude');
      _locationError = '';
    } catch (e) {
      _locationError = 'Failed to get location: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
