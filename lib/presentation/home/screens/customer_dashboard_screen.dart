import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/models/order_model.dart';
import 'package:gorepair_app/presentation/order/screens/create_order_page.dart';
import 'package:gorepair_app/presentation/order/screens/order_detail_screen.dart';
import 'package:gorepair_app/presentation/profile/screens/edit_profile_screen.dart';
import '../order/order_bloc.dart';
import '../../auth/screens/login_screen.dart';
import '../../../data/repository/auth_repository.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderBloc>().add(FetchCustomerOrders());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageIndex == 0 ? 'Pesanan Aktif' : 'Riwayat Pesanan'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil Saya',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await AuthRepository().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderLoaded) {
            final List<OrderModel> historyOrders = state.orders
                .where((order) =>
                    (order.status == 'completed' && order.isPaymentValidated) ||
                    order.status == 'cancelled')
                .toList();
            
            final List<OrderModel> activeOrders = state.orders
                .where((order) => !historyOrders.contains(order))
                .toList();
            
            List<Widget> pages = [
              _buildOrderList(context, activeOrders, 'Anda tidak memiliki pesanan aktif.'),
              _buildOrderList(context, historyOrders, 'Tidak ada riwayat pesanan.'),
            ];

            return IndexedStack(
              index: _pageIndex,
              children: pages,
            );
          }

          if (state is OrderError) {
            return Center(child: Text('Gagal memuat data: ${state.message}'));
          }
          
          return const Center(child: Text('Selamat Datang!'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateOrderPage()),
          ).then((_) {
            context.read<OrderBloc>().add(FetchCustomerOrders());
          });
        },
        child: const Icon(Icons.add),
        elevation: 2.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.dashboard_outlined, color: _pageIndex == 0 ? Theme.of(context).primaryColor : Colors.grey),
              tooltip: 'Dashboard',
              onPressed: () => setState(() => _pageIndex = 0),
            ),
            IconButton(
              icon: Icon(Icons.history, color: _pageIndex == 1 ? Theme.of(context).primaryColor : Colors.grey),
              tooltip: 'Riwayat Pesanan',
              onPressed: () => setState(() => _pageIndex = 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<OrderModel> orders, String emptyMessage) {
    if (orders.isEmpty) {
      // Gunakan Stack untuk menengahkan teks dan menjaga fungsi refresh
      return RefreshIndicator(
        onRefresh: () async {
          context.read<OrderBloc>().add(FetchCustomerOrders());
        },
        child: Stack(
          children: <Widget>[
            ListView(), // ListView kosong agar RefreshIndicator berfungsi
            Center(child: Text(emptyMessage)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(FetchCustomerOrders());
      },
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          
          // --- LOGIKA BARU UNTUK WARNA CARD ---
          Color cardColor = Colors.white;
          if (order.status == 'completed' && order.isPaymentValidated) {
            cardColor = Colors.green.shade50;
          } else if (order.status == 'cancelled') {
            cardColor = Colors.red.shade50;
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: cardColor, // Terapkan warna di sini
            child: ListTile(
              title: Text('Order #${order.id} - ${order.category.name}'),
              subtitle: Text(order.description ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis),

              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text((order.status ?? '-').toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  
                  if (order.status == 'pending' || order.status == 'processed')
                    _buildCancelButton(context, order.id),
                  
                  if (order.status == 'completed' && !order.isPaymentValidated)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        order.paymentProofUrl != null ? 'MENUNGGU VALIDASI' : 'PERLU DIBAYAR',
                        style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    )
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderDetailPage(orderId: order.id)),
                ).then((_){
                   context.read<OrderBloc>().add(FetchCustomerOrders());
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, int orderId) {
    return SizedBox(
      height: 28,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        icon: const Icon(Icons.cancel, color: Colors.red, size: 16),
        label: const Text('Batal', style: TextStyle(color: Colors.red, fontSize: 12)),
        onPressed: () async {
          final bool? confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Konfirmasi Pembatalan'),
              content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Tidak')),
                TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ya, Batalkan')),
              ],
            ),
          );

          if (confirm == true) {
            context.read<OrderBloc>().add(CancelOrder(orderId: orderId));
          }
        },
      ),
    );
  }
}
