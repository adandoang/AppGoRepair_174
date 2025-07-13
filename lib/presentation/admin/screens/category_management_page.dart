import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/models/category_model.dart';
import 'package:gorepair_app/data/repository/category_repository.dart';
import 'package:gorepair_app/presentation/admin/category/category_management_bloc.dart';

// Halaman Wrapper untuk menyediakan BLoC
class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryManagementBloc(
        categoryRepository: CategoryRepository(),
      )..add(LoadAllCategories()), // Langsung muat data saat halaman dibuka
      child: const CategoryManagementScreen(),
    );
  }
}

// Halaman UI Utama
class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  // Fungsi untuk menampilkan dialog Tambah/Edit
  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final _nameController = TextEditingController(text: category?.name ?? '');
    final _descriptionController = TextEditingController(text: category?.description ?? '');
    final bool isEditing = category != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Kategori' : 'Tambah Kategori Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final description = _descriptionController.text;
                if (name.isNotEmpty) {
                  if (isEditing) {
                    // Kirim event Edit
                    context.read<CategoryManagementBloc>().add(EditCategory(
                          id: category.id,
                          name: name,
                          description: description,
                        ));
                  } else {
                    // Kirim event Tambah
                    context.read<CategoryManagementBloc>().add(AddCategory(
                          name: name,
                          description: description,
                        ));
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi hapus
  void _showDeleteConfirmation(BuildContext context, CategoryModel category) {
     showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<CategoryManagementBloc>().add(DeleteCategory(id: category.id));
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kategori'),
      ),
      body: BlocListener<CategoryManagementBloc, CategoryManagementState>(
        listener: (context, state) {
          if (state is CategoryManagementActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is CategoryManagementError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<CategoryManagementBloc, CategoryManagementState>(
          builder: (context, state) {
            if (state is CategoryManagementLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CategoryManagementLoaded) {
              return ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return ListTile(
                    title: Text(category.name),
                    subtitle: Text(category.description ?? 'Tidak ada deskripsi'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showCategoryDialog(context, category: category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(context, category),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Memuat data kategori...'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        tooltip: 'Tambah Kategori',
        child: const Icon(Icons.add),
      ),
    );
  }
}
