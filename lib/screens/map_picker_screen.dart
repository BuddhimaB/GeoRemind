import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

const String kPlacesApiKey = "AIzaSyDR3mbeo_yg95p802TMhXohWjE6DXN6DiM";

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
  String? _selectedName;

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _selected = LatLng(widget.initialLat!, widget.initialLng!);
    }
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
      _selectedName = null;
    });
  }

  void _onSave() {
    if (_selected == null) return;

    Navigator.of(context).pop({
      "latLng": _selected,
      "name": _selectedName,
    });
  }

  Future<List<Map<String, String>>> fetchPlaceSuggestions(String input) async {
    if (input.trim().isEmpty) return [];

    final uri = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json"
          "?input=${Uri.encodeComponent(input)}"
          "&key=$kPlacesApiKey"
          "&components=country:lk",
    );

    final res = await http.get(uri);
    final data = json.decode(res.body);

    if (data["status"] != "OK") return [];
    final preds = (data["predictions"] as List);
    return preds.map<Map<String, String>>((p) {
      return {
        "description": p["description"],
        "place_id": p["place_id"],
      };
    }).toList();
  }

  Future<LatLng?> fetchPlaceLatLng(String placeId) async {
    final uri = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json"
          "?place_id=$placeId"
          "&fields=geometry"
          "&key=$kPlacesApiKey",
    );

    final res = await http.get(uri);
    final data = json.decode(res.body);

    if (data["status"] != "OK") return null;

    final loc = data["result"]["geometry"]["location"];
    return LatLng(
      (loc["lat"] as num).toDouble(),
      (loc["lng"] as num).toDouble(),
    );
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
                infoWindow: _selectedName == null
                    ? const InfoWindow(title: "Selected location")
                    : InfoWindow(title: _selectedName),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(24),
              child: TypeAheadField<Map<String, String>>(
                suggestionsCallback: fetchPlaceSuggestions,
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion["description"]!),
                  );
                },
                onSelected: (suggestion) async {
                  final latLng =
                  await fetchPlaceLatLng(suggestion["place_id"]!);
                  if (latLng == null) return;

                  setState(() {
                    _selected = latLng;
                    _selectedName = suggestion["description"];
                  });
                  FocusScope.of(context).unfocus();

                  await _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(latLng, 16),
                  );
                  Navigator.of(context).pop({
                    "latLng": latLng,
                    "name": suggestion["description"],
                  });
                },
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: "Search place (e.g. Colombo Fort)",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
