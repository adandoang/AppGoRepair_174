import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../data/models/category_model.dart';
import '../../category/bloc/category_bloc.dart';
import '../create_order/create_order_bloc.dart';
import 'map_picker_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  CategoryModel? _selectedCategory;
  File? _selectedImage;
  LatLng? _selectedLocation;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
  await showDialog(
    context: context,
    // --- GANTI MENJADI SIMPLEDIALOG ---
    builder: (context) => SimpleDialog(
      title: const Text('Pilih Sumber Gambar'),
      children: <Widget>[
        // --- GUNAKAN SIMPLEDIALOGOPTION ---
        SimpleDialogOption(
          onPressed: () {
            _getImage(ImageSource.camera);
            Navigator.of(context).pop();
          },
          child: const Text('Kamera'),
        ),
        SimpleDialogOption(
          onPressed: () {
            _getImage(ImageSource.gallery);
            Navigator.of(context).pop();
          },
          child: const Text('Galeri'),
        ),
      ],
    ),
  );
}

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showCategoryPicker(BuildContext context) {
    context.read<CategoryBloc>().add(FetchCategories());
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return BlocProvider.value(
          value: BlocProvider.of<CategoryBloc>(context),
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CategoryLoaded) {
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Pilih Kategori',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        return ListTile(
                          title: Text(category.name),
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ]);
              }
              if (state is CategoryError) {
                return Center(child: Text(state.message));
              }
              return const Center(
                  child: Text('Tekan tombol untuk memuat kategori.'));
            },
          ),
        );
      },
    );
  }

  void _openMapPicker() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );
    if (pickedLocation != null) {
      setState(() {
        _selectedLocation = pickedLocation;
        _addressController.text = 'Mencari alamat...';
      });

      try {
        final url = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pickedLocation.latitude}&lon=${pickedLocation.longitude}');
        final response = await http
            .get(url, headers: {'User-Agent': 'com.example.gorepair_app'});
        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          final String address =
              responseBody['display_name'] ?? 'Alamat tidak ditemukan';
          setState(() {
            _addressController.text = address;
          });
        } else {
          setState(() {
            _addressController.text = 'Gagal mengambil alamat.';
          });
        }
      } catch (e) {
        setState(() {
          _addressController.text = 'Error: Gagal terhubung.';
        });
      }
    }
  }

  void _submitOrder() {
    // Validasi input
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih kategori terlebih dahulu.')));
      return;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deskripsi tidak boleh kosong.')));
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih lokasi terlebih dahulu.')));
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unggah foto kerusakan.')));
      return;
    }

    // Panggil event BLoC untuk submit data
    context.read<CreateOrderBloc>().add(
          SubmitOrderButtonPressed(
            categoryId: _selectedCategory!.id,
            description: _descriptionController.text,
            address: _addressController.text,
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
            imageFile: _selectedImage!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan Baru')),
      body: BlocListener<CreateOrderBloc, CreateOrderState>(
        listener: (context, state) {
          if (state is CreateOrderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Pesanan berhasil dibuat!'),
                  backgroundColor: Colors.green),
            );
            Navigator.of(context).pop();
          }
          if (state is CreateOrderFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Gagal membuat pesanan: ${state.error}'),
                  backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showCategoryPicker(context),
                icon: const Icon(Icons.category),
                label: Text(_selectedCategory == null
                    ? 'Pilih Kategori Layanan'
                    : _selectedCategory!.name),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi Kerusakan',
                    border: OutlineInputBorder()),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap',
                  hintText: 'Pilih lokasi dari peta untuk mengisi alamat',
                  border: const OutlineInputBorder(),
                  fillColor: Colors.grey[200],
                  filled: true,
                ),
                maxLines: 2,
                onTap: _openMapPicker,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _openMapPicker,
                icon: const Icon(Icons.map),
                label: Text(_selectedLocation == null
                    ? 'Pilih Lokasi di Peta'
                    : 'Ubah Lokasi di Peta'),
              ),
              if (_selectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Koordinat: Lat: ${_selectedLocation!.latitude.toStringAsFixed(5)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(5)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 16),
                  // Karena kita sudah fokus ke Android, kIsWeb tidak perlu lagi
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              OutlinedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.camera_alt),
                label: Text(_selectedImage == null
                    ? 'Unggah Foto Kerusakan'
                    : 'Ganti Foto'),
              ),
              const SizedBox(height: 24),
              BlocBuilder<CreateOrderBloc, CreateOrderState>(
                builder: (context, state) {
                  if (state is CreateOrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: _submitOrder,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('KIRIM PESANAN'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}