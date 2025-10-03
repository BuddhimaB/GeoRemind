import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import '../../presentation/providers/reminder_provider.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  
  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });
  
  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  String _locationName = '';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _latController.text = widget.initialLatitude!.toStringAsFixed(6);
      _lngController.text = widget.initialLongitude!.toStringAsFixed(6);
    }
  }
  
  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter Location Coordinates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                prefixIcon: Icon(Icons.location_on),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lngController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                prefixIcon: Icon(Icons.location_on),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _useCurrentLocation,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Use Current Location'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _getLocationName,
              icon: const Icon(Icons.search),
              label: const Text('Get Location Name'),
            ),
            if (_locationName.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_locationName),
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _confirmLocation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Confirm Location'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);
    
    final provider = context.read<ReminderProvider>();
    await provider.getCurrentLocation();
    
    if (provider.currentPosition != null) {
      final position = provider.currentPosition!;
      _latController.text = position.latitude.toStringAsFixed(6);
      _lngController.text = position.longitude.toStringAsFixed(6);
      await _getLocationName();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get current location')),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }
  
  Future<void> _getLocationName() async {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid coordinates')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _locationName = '${place.street ?? ''}, ${place.locality ?? ''}';
        });
      } else {
        setState(() {
          _locationName = 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      setState(() {
        _locationName = 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _confirmLocation() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid coordinates')),
      );
      return;
    }
    
    if (_locationName.isEmpty) {
      setState(() {
        _locationName = 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
      });
    }
    
    Navigator.pop(context, {
      'latitude': lat,
      'longitude': lng,
      'locationName': _locationName,
    });
  }
}
