import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/models/response/login_response_model.dart';
import 'package:gorepair_app/data/services/service_http_client.dart';
import '../bloc/admin_order_detail_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/repository/order_repository.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  const AdminOrderDetailScreen({super.key});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  String? _selectedStatus;
  int? _selectedTechnicianId;
  final TextEditingController _invoiceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail & Kelola Pesanan')),
      body: BlocConsumer<AdminOrderDetailBloc, AdminOrderDetailState>(
        listener: (context, state) {
          if (state is AdminOrderUpdateSuccess || state is PaymentValidationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data berhasil diperbarui!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
          if (state is AdminOrderUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal Update: ${state.error}'), backgroundColor: Colors.red),
            );
          }
           if (state is PaymentValidationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal Validasi: ${state.error}'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminOrderDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminOrderDetailLoaded) {
            final order = state.order;

            _selectedStatus ??= order.status;
            _selectedTechnicianId ??= order.technician?.id;

            // Set controller dengan nilai dari database setiap kali detail order dimuat
            if (order.invoiceAmount != null) {
              _invoiceController.text = order.invoiceAmount.toString();
            }

            // --- LOGIKA BARU: TENTUKAN APAKAH FORM BISA DIEDIT ---
            final bool isOrderEditable = order.status != 'completed' && order.status != 'cancelled';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${order.id}', style: Theme.of(context).textTheme.headlineSmall),
                  Text('Pelanggan: ${order.customer.name}'),
                  const Divider(height: 32),
                  // Form input harga invoice jika status completed & belum divalidasi
                  if (order.status == 'completed' && !order.isPaymentValidated) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _invoiceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Input Harga Invoice',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final amount = double.tryParse(_invoiceController.text);
                              if (amount == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Masukkan nominal yang valid!')),
                                );
                                return;
                              }
                              try {
                                await OrderRepository().setInvoiceAmount(orderId: order.id, invoiceAmount: amount);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Harga invoice berhasil disimpan!')),
                                );
                                // Refresh detail order
                                if (!mounted) return;
                                context.read<AdminOrderDetailBloc>().add(LoadAdminOrderDetail(orderId: order.id));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal simpan harga: $e')),
                                );
                              }
                            },
                            child: const Text('Simpan'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Text('Detail Pesanan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Kategori: ${order.category.name}'),
                  const SizedBox(height: 4),
                  Text('Deskripsi: ${order.description}'),
                  const SizedBox(height: 4),
                                      Text('Alamat: ${order.address}'),
                    
                    // --- TAMPILKAN CATATAN TEKNISI ---
                    if (order.technicianNotes != null && order.technicianNotes!.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text('Catatan Teknisi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    
                    // --- TAMPILKAN RATING ---
                    if (order.rating != null) ...[
                      const Divider(height: 32),
                      const Text('Rating Customer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    
                    const Divider(height: 32),
                  
                  if (order.paymentProofUrl != null && !order.isPaymentValidated) ...[
                    const Text('Bukti Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Builder(builder: (context) {
                      final baseUrl = ServiceHttpClient().baseUrl.replaceAll('/api/', '');
                      final imageUrl = '$baseUrl/storage/${order.paymentProofUrl}';
                      return Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                        child: Image.network(imageUrl, fit: BoxFit.cover),
                      );
                    }),
                    const SizedBox(height: 16),
                    state is PaymentValidationLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text('VALIDASI PEMBAYARAN'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                        onPressed: () {
                          context.read<AdminOrderDetailBloc>().add(ValidatePaymentButtonPressed(orderId: order.id));
                        },
                      ),
                    const Divider(height: 32),
                  ],

                  // --- TAMPILKAN FORM KELOLA HANYA JIKA BISA DIEDIT ---
                  if (isOrderEditable) ...[
                    const Text('Kelola Pesanan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(labelText: 'Ubah Status', border: OutlineInputBorder()),
                      items: ['processed', 'assigned', 'in_progress', 'completed', 'cancelled']
                          .map((label) => DropdownMenuItem(value: label, child: Text(label.toUpperCase())))
                          .toList(),
                      onChanged: (value) => setState(() {
                          _selectedStatus = value;
                          if (value != 'assigned') _selectedTechnicianId = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedTechnicianId,
                      hint: const Text('Pilih Teknisi'),
                      decoration: InputDecoration(
                        labelText: 'Tugaskan Teknisi',
                        border: const OutlineInputBorder(),
                        fillColor: _selectedStatus == 'assigned' ? Colors.white : Colors.grey.shade200,
                        filled: true,
                      ),
                      items: state.technicians
                          .map((tech) => DropdownMenuItem(value: tech.id, child: Text(tech.name)))
                          .toList(),
                      onChanged: _selectedStatus == 'assigned' ? (value) => setState(() => _selectedTechnicianId = value) : null,
                    ),
                    const SizedBox(height: 32),
                    state is AdminOrderUpdateLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () {
                          if (_selectedStatus != null) {
                            context.read<AdminOrderDetailBloc>().add(
                                  UpdateAdminOrder(
                                    orderId: state.order.id,
                                    status: _selectedStatus!,
                                    technicianId: _selectedTechnicianId,
                                  ),
                                );
                          }
                        },
                        child: const Text('SIMPAN PERUBAHAN'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      ),
                  ] else ...[
                    // Tampilkan pesan jika order sudah tidak bisa diedit
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: const Center(child: Text('Pesanan ini sudah selesai dan tidak dapat diubah lagi.', textAlign: TextAlign.center,)),
                    )
                  ],
                  // Tombol cetak PDF jika order completed & sudah divalidasi pembayaran
                  if (order.status == 'completed' && order.isPaymentValidated == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Cetak Transaksi (PDF)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: () async {
                          final url = OrderRepository().getOrderPdfUrl(order.id);
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
                            if (!mounted) return;
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
              ),
            );
          }
          if (state is AdminOrderDetailError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Memuat data...'));
        },
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
