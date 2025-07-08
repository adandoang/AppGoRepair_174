import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // Posisi default di Yogyakarta jika lokasi tidak ditemukan
  final LatLng _initialPosition = const LatLng(-7.7956, 110.3695);
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Cek dan minta izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Pengguna menolak izin, bisa tampilkan pesan
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin ditolak permanen
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Ambil lokasi saat ini
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
        // Pindahkan kamera ke lokasi pengguna
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 15),
        );
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition ?? _initialPosition,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true, // Tampilkan titik biru lokasi saya
              myLocationButtonEnabled: true, // Tampilkan tombol untuk ke lokasi saya
            ),
    );
  }
}