import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // Posisi default jika lokasi tidak ditemukan
  final LatLng _initialPosition = const LatLng(-7.7956, 110.3695); 
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  Marker? _pickedMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Mengambil lokasi pengguna saat ini untuk posisi awal peta
  Future<void> _getCurrentLocation() async {
    try {
      final position = await _getPermissions();
      setState(() {
        _pickedLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_pickedLocation!, 15),
      );
    } catch (e) {
      // Biarkan menggunakan posisi default jika gagal
    }
  }

  // Memeriksa dan meminta izin lokasi
  Future<Position> _getPermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Layanan lokasi belum aktif';
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw 'Izin lokasi ditolak';
      }
    }
    if (perm == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak permanen';
    }
    return Geolocator.getCurrentPosition();
  }

  // Fungsi yang berjalan saat pengguna mengetuk peta
  Future<void> _onTapMap(LatLng latLng) async {
    setState(() {
      _pickedLocation = latLng;
      _pickedMarker = Marker(
        markerId: const MarkerId('picked_location'),
        position: latLng,
      );
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi'),
        actions: [
          // Tombol Konfirmasi, hanya muncul jika lokasi sudah dipilih
          if (_pickedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // Kirim data LatLng kembali ke halaman form
                Navigator.of(context).pop(_pickedLocation);
              },
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pickedLocation ?? _initialPosition,
          zoom: 16,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onTap: _onTapMap,
        markers: _pickedMarker != null ? {_pickedMarker!} : {},
      ),
    );
  }
}