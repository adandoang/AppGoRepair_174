import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/services/service_http_client.dart';
import '../bloc/technician_job_detail_bloc.dart';

class TechnicianJobDetailScreen extends StatelessWidget {
  const TechnicianJobDetailScreen({super.key});

  void _showAddNotesDialog(BuildContext context, int orderId) {
    final TextEditingController notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tambahkan catatan untuk pelanggan:'),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Masukkan catatan...',
                  border: OutlineInputBorder(),
                ),
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
                if (notesController.text.trim().isNotEmpty) {
                  context.read<TechnicianJobDetailBloc>().add(
                    AddTechnicianNotes(
                      orderId: orderId,
                      notes: notesController.text.trim(),
                    ),
                  );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pekerjaan')),
      body: BlocListener<TechnicianJobDetailBloc, TechnicianJobDetailState>(
        listener: (context, state) {
          if (state is TechnicianJobUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Status berhasil diperbarui!'),
                  backgroundColor: Colors.green),
            );
            // Kembali hanya jika pekerjaan selesai
            if (state.newStatus == 'completed') {
              Navigator.of(context).pop();
            }
          }
          if (state is TechnicianJobUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Gagal: ${state.error}'),
                  backgroundColor: Colors.red),
            );
          }
          if (state is TechnicianNotesSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Catatan berhasil ditambahkan!'),
                  backgroundColor: Colors.green),
            );
          }
          if (state is TechnicianNotesFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Gagal menambah catatan: ${state.error}'),
                  backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<TechnicianJobDetailBloc, TechnicianJobDetailState>(
          builder: (context, state) {
            if (state is TechnicianJobDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TechnicianJobDetailLoaded) {
              final job = state.job;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pekerjaan #${job.id}', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Status Saat Ini: ${(job.status ?? '-').toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),

                    const Divider(height: 32),

                    const Text('Detail Pelanggan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Nama: ${job.customer.name}'),
                    Text('Alamat: ${job.address}'),
                    const Divider(height: 32),

                    const Text('Detail Kerusakan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Kategori: ${job.category.name}'),
                    Text('Deskripsi: ${job.description}'),
                    const SizedBox(height: 16),

                    // --- PERBAIKAN: Tampilkan foto secara vertikal dan full-width ---
                    if (job.photos.isNotEmpty) ...[
                      const Text('Foto Kerusakan:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Column(
                        children: job.photos.map((photo) {
                          final baseUrl = ServiceHttpClient().baseUrl.replaceAll('/api/', '');
                          final imageUrl = '$baseUrl/storage/${photo.photoUrl}';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity, // Agar full ke kanan
                                height: 250, // Tinggi bisa disesuaikan
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 250,
                                    color: Colors.grey[200],
                                    child: const Center(child: CircularProgressIndicator()),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 250,
                                  color: Colors.grey[200],
                                  child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    
                    const Divider(height: 32),
                    
                    // --- TAMPILKAN CATATAN TEKNISI ---
                    const Text('Catatan Teknisi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (job.technicianNotes != null && job.technicianNotes!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          job.technicianNotes!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      )
                    else
                      const Text('Belum ada catatan', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                    const SizedBox(height: 16),
                    
                    // --- TOMBOL TAMBAH CATATAN ---
                    ElevatedButton.icon(
                      onPressed: () => _showAddNotesDialog(context, job.id),
                      icon: const Icon(Icons.note_add),
                      label: const Text('Tambah Catatan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    
                    const Divider(height: 32),
                    const Text('Ubah Status Pekerjaan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    
                    if (state is TechnicianJobUpdateLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (job.status == 'assigned')
                            ElevatedButton(
                              onPressed: () {
                                context.read<TechnicianJobDetailBloc>().add(
                                  UpdateJobStatusByTechnician(orderId: job.id, status: 'in_progress'),
                                );
                              },
                              child: const Text('MULAI KERJAKAN'),
                            ),
                          
                          if (job.status == 'in_progress')
                            ElevatedButton(
                              onPressed: () {
                                 context.read<TechnicianJobDetailBloc>().add(
                                  UpdateJobStatusByTechnician(orderId: job.id, status: 'completed'),
                                );
                              },
                              child: const Text('SELESAIKAN PEKERJAAN'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                        ],
                      )
                  ],
                ),
              );
            }
            if (state is TechnicianJobDetailError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Memuat data...'));
          },
        ),
      ),
    );
  }
}
