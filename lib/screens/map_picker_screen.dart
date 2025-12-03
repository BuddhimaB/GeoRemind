import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _selected;
  GoogleMapController? _mapController;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _selected = LatLng(widget.initialLat!, widget.initialLng!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CameraPosition get _initialCameraPosition {
    if (_selected != null) {
      return CameraPosition(target: _selected!, zoom: 15);
    }
    // Default: Colombo
    return const CameraPosition(
      target: LatLng(6.9271, 79.8612),
      zoom: 14,
    );
  }

  void _onTap(LatLng pos) {
    setState(() {
      _selected = pos;
    });
  }

  void _onSave() {
    if (_selected == null) return;
    Navigator.of(context).pop<LatLng>(_selected);
  }

  Future<void> _searchPlace() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final results = await geocoding.locationFromAddress(query);
      if (results.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No location found for that name')),
          );
        }
        return;
      }

      final loc = results.first;
      final target = LatLng(loc.latitude, loc.longitude);

      setState(() {
        _selected = target;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 15),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to search location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _selected != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            onPressed: canSave ? _onSave : null,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _mapController = controller,
            onTap: _onTap,
            markers: _selected == null
                ? {}
                : {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selected!,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          // Search bar overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchPlace(),
                      decoration: const InputDecoration(
                        hintText: 'Search place (e.g. Colombo Fort)',
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: _isSearching
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.search),
                    onPressed: _isSearching ? null : _searchPlace,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
