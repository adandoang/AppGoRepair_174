import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/presentation/order/screens/create_order_page.dart';
import '../bloc/order_bloc.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  @override
  void initState() {
    // Memicu event untuk mengambil data saat halaman pertama kali dibuka
    // Kita bungkus dalam context.read agar bisa memanggil BLoC
    context.read<OrderBloc>().add(FetchCustomerOrders());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pelanggan'),
        // Tambahkan tombol logout atau profil jika perlu
      ),
      // Gunakan BlocBuilder untuk membangun UI berdasarkan state dari OrderBloc
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          // Jika state sedang loading, tampilkan progress indicator
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Jika state berhasil memuat data, tampilkan list-nya
          if (state is OrderLoaded) {
            // Jika tidak ada order
            if (state.orders.isEmpty) {
              return const Center(child: Text('Anda belum memiliki pesanan.'));
            }
            // Jika ada order, tampilkan dalam ListView
            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(order.category.name),
                    subtitle: Text('Status: ${order.status}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigasi ke halaman detail order
                    },
                  ),
                );
              },
            );
          }

          // Jika state gagal, tampilkan pesan error
          if (state is OrderError) {
            return Center(child: Text('Gagal memuat data: ${state.message}'));
          }

          // State awal atau lainnya
          return const Center(child: Text('Memuat data pesanan...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      // Arahkan ke CreateOrderPage
      MaterialPageRoute(builder: (context) => const CreateOrderPage()),
    );
  },
  child: const Icon(Icons.add),
),
    );
  }
}