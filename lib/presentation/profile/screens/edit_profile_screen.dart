import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/request/update_profile_request_model.dart';
import '../../../data/repository/auth_repository.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        authRepository: AuthRepository(),
      )..add(LoadProfile()), // Langsung muat data profil saat dibuka
      child: const EditProfileScreen(),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    // Validasi password jika diisi
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi tidak cocok.')),
      );
      return;
    }

    context.read<ProfileBloc>().add(
          UpdateProfileButtonPressed(
            data: UpdateProfileRequestModel(
              name: _nameController.text,
              email: _emailController.text,
              phoneNumber: _phoneController.text,
              password: _passwordController.text,
              passwordConfirmation: _confirmPasswordController.text,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            // Isi form dengan data yang berhasil dimuat
            _nameController.text = state.user.name;
            _emailController.text = state.user.email;
            _phoneController.text = state.user.role; // Asumsi phone number ada di role (perbaiki jika perlu)
          }
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Profil berhasil diperbarui!'),
                  backgroundColor: Colors.green),
            );
          }
          if (state is ProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Gagal: ${state.error}'),
                  backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading && state is! ProfileLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileLoaded || state is ProfileUpdateFailure || state is ProfileUpdateSuccess) {
               return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap')),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Nomor Telepon')),
                    const SizedBox(height: 24),
                    const Text('Ubah Password (opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password Baru'),
                        obscureText: true),
                    const SizedBox(height: 16),
                    TextField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru'),
                        obscureText: true),
                    const SizedBox(height: 24),

                    // Jika sedang mengupdate, tampilkan loading di tombol
                    (state is ProfileLoading) 
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitUpdate,
                        child: const Text('SIMPAN PERUBAHAN'),
                      ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}