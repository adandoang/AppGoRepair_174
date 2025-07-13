// File: lib/presentation/order/screens/order_detail_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/repository/order_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gorepair_app/presentation/order/order_detail/order_detail_bloc.dart';
import 'package:gorepair_app/data/models/order_model.dart';
import 'package:gorepair_app/data/services/service_http_client.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

// Halaman Wrapper
class OrderDetailPage extends StatelessWidget {
  final int orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderDetailBloc(
        orderRepository: OrderRepository(),
      )..add(FetchOrderDetail(orderId: orderId)),
      child: const OrderDetailScreen(),
    );
  }
}

// Halaman UI
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  Future<void> _showImageSourceDialog(BuildContext context) async {
    final currentState = context.read<OrderDetailBloc>().state;
    if (currentState is! OrderDetailLoaded) return;
    final orderId = currentState.order.id;

    await showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Pilih Sumber Gambar'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _getImage(context, ImageSource.camera, orderId);
            },
            child: const ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Kamera'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _getImage(context, ImageSource.gallery, orderId);
            },
            child: const ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galeri'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getImage(BuildContext context, ImageSource source, int orderId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile != null && context.mounted) {
      context.read<OrderDetailBloc>().add(
            UploadPaymentProof(
              orderId: orderId,
              imageFile: File(pickedFile.path),
            ),
          );
    }
  }

  void _showRatingDialog(BuildContext context, int orderId) {
    int selectedRating = 0;
    final TextEditingController commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<OrderDetailBloc>(context),
          child: StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Beri Rating'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Bagaimana pelayanan teknisi?'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                          child: Icon(
                            index < selectedRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tambahkan komentar (opsional)',
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
                    onPressed: selectedRating > 0 ? () {
                      context.read<OrderDetailBloc>().add(
                        AddRating(
                          orderId: orderId,
                          rating: selectedRating,
                          comment: commentController.text.trim().isNotEmpty 
                              ? commentController.text.trim() 
                              : null,
                        ),
                      );
                      Navigator.of(dialogContext).pop();
                    } : null,
                    child: const Text('Kirim Rating'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: BlocListener<OrderDetailBloc, OrderDetailState>(
        listener: (context, state) {
          if (state is OrderDetailUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bukti bayar berhasil diunggah!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is OrderDetailUploadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is OrderDetailRatingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rating berhasil ditambahkan!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is OrderDetailRatingFailure) {
            if (!state.error.contains("type 'Null' is not a subtype of type") &&
                !state.error.contains("type 'int' is not a subtype of type 'Map<String, dynamic>'")) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal menambah rating: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            if (state is OrderDetailInitial || state is OrderDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OrderDetailError) {
              return Center(child: Text(state.message));
            }

            if (state is OrderDetailLoaded || state is OrderDetailUploadLoading) {
              final order = (state as dynamic).order;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.id}', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Status: ${order.status.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700])),
                    const Divider(height: 32),
                    
                    const Text('Detail:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Kategori: ${order.category.name}'),
                    Text('Deskripsi: ${order.description}'),
                    Text('Alamat: ${order.address}'),
                    const SizedBox(height: 16),
                    
                    if (order.technician != null) ...[
                      const Text('Teknisi:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(order.technician!.name),
                    ],
                    
                    // --- TAMPILKAN CATATAN TEKNISI ---
                    if (order.technicianNotes != null && order.technicianNotes!.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text('Catatan dari Teknisi:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          order.technicianNotes!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                    
                    
                    const Divider(height: 32),
                    
                    const Text('Status Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(order.isPaymentValidated ? 'Sudah Divalidasi' : 'Belum Divalidasi'),
                    
                    if (order.paymentProofUrl != null) ...[
                      const SizedBox(height: 8),
                      const Text('Bukti Pembayaran Terunggah:', style: TextStyle(fontStyle: FontStyle.italic)),
                      const SizedBox(height: 8),
                      Builder(builder: (context) {
                        final baseUrl = ServiceHttpClient().baseUrl.replaceAll('/api/', '');
                        final imageUrl = '$baseUrl/storage/${order.paymentProofUrl}';
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          child: Image.network(imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(child: Text('Gagal memuat gambar bukti.')),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 24),
                    
                    // Tampilkan tombol/preview invoice jika sudah ada harga
                    if (order.invoiceAmount != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Lihat Invoice (PDF)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: () async {
                            final url = OrderRepository().getCustomerOrderPdfUrl(order.id);
                            final token = await const FlutterSecureStorage().read(key: 'authToken');
                            final dio = Dio();
                            final dir = await getTemporaryDirectory();
                            final filePath = '${dir.path}/invoice-order-${order.id}.pdf';
                            try {
                              final response = await dio.get(
                                url,
                                options: Options(
                                  responseType: ResponseType.bytes,
                                  headers: {'Authorization': 'Bearer $token'},
                                ),
                              );
                              final file = File(filePath);
                              await file.writeAsBytes(response.data);
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => _PdfPreviewPage(filePath: filePath),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal download/preview PDF: $e')),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                    // Tombol kontak darurat Email jika order belum selesai/belum dibatalkan
                    if (order.status != 'completed' && order.status != 'cancelled')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.email, color: Colors.white),
                          label: const Text('Kontak Darurat (Email Admin)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: () async {
                            final adminEmail = 'admin@gorepair.com'; // Ganti dengan email admin
                            final subject = Uri.encodeComponent('Kontak Darurat Order #${order.id}');
                            final body = Uri.encodeComponent('Halo admin, teknisi belum datang untuk order #${order.id}. Mohon bantuan dan tindak lanjutnya.');
                            final emailUri = Uri.parse('mailto:$adminEmail?subject=$subject&body=$body');
                            try {
                              await launchUrl(emailUri);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tidak bisa membuka aplikasi email!')),
                              );
                            }
                          },
                        ),
                      ),
                    // Logika untuk menampilkan tombol upload - hanya jika admin sudah set harga dan belum divalidasi
                    if (order.status == 'completed' && order.invoiceAmount != null && !order.isPaymentValidated)
                      state is OrderDetailUploadLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.upload_file),
                              label: Text(order.paymentProofUrl == null ? 'UNGGAH BUKTI PEMBAYARAN' : 'UNGGAH ULANG BUKTI'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[700],
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: () => _showImageSourceDialog(context),
                            ),
                    
                    // --- TAMPILKAN RATING YANG SUDAH ADA ---
                    if (order.rating != null) ...[
                      const SizedBox(height: 24),
                      const Text('Rating Anda:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < order.rating!.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          );
                        }),
                      ),
                      if (order.rating!.comment != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(order.rating!.comment!),
                        ),
                      ],
                    ],
                    
                    // --- TOMBOL RATING UNTUK ORDER YANG SUDAH SELESAI DAN DIVALIDASI ---
                    if (order.status == 'completed' && order.isPaymentValidated && order.rating == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.star),
                          label: const Text('BERI RATING'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[700],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () => _showRatingDialog(context, order.id),
                        ),
                      ),
                  ],
                ),
              );
            }

            // Jika state lain (misal rating success/failure/loading), jangan tampilkan error fallback
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// Tambahkan widget preview PDF di bawah kelas utama
class _PdfPreviewPage extends StatelessWidget {
  final String filePath;
  const _PdfPreviewPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Invoice PDF')),
      body: SfPdfViewer.file(File(filePath)),
    );
  }
}
