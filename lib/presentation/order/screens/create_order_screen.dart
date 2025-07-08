import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/category_model.dart';
import '../../category/bloc/category_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'map_picker_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  // Variabel untuk menyimpan kategori yang dipilih
  CategoryModel? _selectedCategory;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    // Anda bisa ganti ImageSource.camera menjadi ImageSource.gallery
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk menampilkan pemilih kategori
  void _showCategoryPicker(BuildContext context) {
  // Memicu BLoC untuk mengambil data kategori saat tombol ditekan
    context.read<CategoryBloc>().add(FetchCategories());

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        // Kita gunakan BlocProvider.value untuk "mengoper" BLoC yang sudah ada
        return BlocProvider.value(
          // `value` mengambil BLoC dari context halaman utama (CreateOrderScreen)
          value: BlocProvider.of<CategoryBloc>(context),
          // Child-nya adalah BlocBuilder kita
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CategoryLoaded) {
                // Kita bungkus ListView dengan Column dan Expanded
                return Column(
                  mainAxisSize: MainAxisSize.min, // Membuat tinggi Column sesuai isi
                  children: [
                    // Opsional: Tambahkan judul untuk mempercantik
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Pilih Kategori',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const Divider(),

                    // Gunakan Expanded agar ListView bisa di-scroll di dalam Column
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
                  ],
                );
              }
              if (state is CategoryError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('Tekan tombol untuk memuat kategori.'));
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pesanan Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tombol Kategori yang sudah diperbarui
            ElevatedButton.icon(
              onPressed: () {
                _showCategoryPicker(context);
              },
              icon: const Icon(Icons.category),
              // Teks tombol akan berubah setelah kategori dipilih
              label: Text(_selectedCategory == null
                  ? 'Pilih Kategori Layanan'
                  : _selectedCategory!.name),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // ... (sisa form lainnya tetap sama) ...
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Kerusakan',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPickerScreen()),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Pilih Lokasi di Peta'),
            ),
            if (_selectedImage != null)
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
              OutlinedButton.icon(
                onPressed: _pickImage, // Panggil fungsi _pickImage
                icon: const Icon(Icons.camera_alt),
                label: Text(_selectedImage == null ? 'Unggah Foto Kerusakan' : 'Ganti Foto'),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Logika untuk mengirim data ke BLoC
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('KIRIM PESANAN'),
            ),
          ],
        ),
      ),
    );
  }
}