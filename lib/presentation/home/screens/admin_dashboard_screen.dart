import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/models/category_model.dart';
import 'package:gorepair_app/data/models/order_model.dart';
import 'package:gorepair_app/presentation/admin/screens/admin_order_detail_page.dart';
import 'package:gorepair_app/presentation/admin/screens/category_management_page.dart';
import 'package:gorepair_app/presentation/auth/screens/login_screen.dart';
import '../../../data/repository/auth_repository.dart';
import '../admin_order/admin_order_bloc.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  CategoryModel? _selectedCategory;
  int _pageIndex = 0;

  void _applyFilters() {
    context.read<AdminOrderBloc>().add(ApplyAdminFilters(
      searchQuery: _searchController.text,
      categoryId: _selectedCategory?.id,
    ));
  }

  void _resetAndRefresh() {
    _searchController.clear();
    setState(() {
      _selectedCategory = null;
    });
    context.read<AdminOrderBloc>().add(FetchAdminDashboardData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageIndex == 0
            ? 'Dashboard Admin'
            : _pageIndex == 1
                ? 'Riwayat Order'
                : 'Manajemen Kategori'),
        automaticallyImplyLeading: false,
        actions: [
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
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _pageIndex,
        children: [
          // Tab 0: Dashboard (order aktif)
          _buildOrderTab(context, isHistory: false),
          // Tab 1: Riwayat
          _buildOrderTab(context, isHistory: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryManagementPage()));
        },
        child: const Icon(Icons.category),
        tooltip: 'Manajemen Kategori',
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
              tooltip: 'Riwayat Order',
              onPressed: () => setState(() => _pageIndex = 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTab(BuildContext context, {required bool isHistory}) {
    return Column(
      children: [
        // --- SEARCH BAR PROFESIONAL ---
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon filter di kiri
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filter Kategori',
                    onPressed: () async {
                      final selected = await showModalBottomSheet<CategoryModel?>(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (modalContext) {
                          return BlocProvider.value(
                            value: BlocProvider.of<AdminOrderBloc>(context),
                            child: _CategoryFilterSheet(
                              selectedCategory: _selectedCategory,
                            ),
                          );
                        },
                      );
                      setState(() {
                        _selectedCategory = selected;
                      });
                      _applyFilters();
                    },
                  ),
                  // Search bar
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari ID Order atau Nama Pelanggan...',
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _applyFilters,
                        ),
                      ),
                      onSubmitted: (_) => _applyFilters(),
                    ),
                  ),
                ],
              ),
              // Chip filter kategori jika aktif
              if (_selectedCategory != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                  child: InputChip(
                    label: Text(_selectedCategory!.name),
                    onDeleted: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                      _applyFilters();
                    },
                    avatar: const Icon(Icons.category, size: 18),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        // --- DAFTAR ORDER ---
        Expanded(
          child: BlocBuilder<AdminOrderBloc, AdminOrderState>(
            builder: (context, state) {
              if (state is AdminOrderLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AdminOrderLoaded) {
                // LOGIKA PEMISAHAN SAMA DENGAN CUSTOMER
                final List<OrderModel> historyOrders = state.orders
                    .where((order) =>
                        (order.status == 'completed' && order.isPaymentValidated == true) ||
                        order.status == 'cancelled')
                    .toList();
                final List<OrderModel> activeOrders = state.orders
                    .where((order) => !historyOrders.contains(order))
                    .toList();
                final List<OrderModel> orders = isHistory ? historyOrders : activeOrders;
                return _buildOrderList(context, orders);
              }
              if (state is AdminOrderError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderList(BuildContext context, List<OrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('Tidak ada pesanan yang cocok.'));
    }
    return RefreshIndicator(
      onRefresh: () async => _resetAndRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          
          // --- LOGIKA WARNA CARD SAMA DENGAN CUSTOMER ---
          Color cardColor = Colors.white;
          if (order.status == 'completed' && order.isPaymentValidated == true) {
            cardColor = Colors.green.shade50;
          } else if (order.status == 'cancelled') {
            cardColor = Colors.red.shade50;
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: cardColor,
            child: ListTile(
              title: Text('Order #${order.id} - ${order.category.name}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((order.status ?? '-').toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey)),

                  const SizedBox(height: 4),
                  Text('Customer: ${order.customer.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text((order.status ?? '-').toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey)),

                  if (order.status == 'completed' && order.paymentProofUrl != null && !order.isPaymentValidated)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'BUTUH VALIDASI',
                        style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    )
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminOrderDetailPage(orderId: order.id),
                  ),
                ).then((_) => _applyFilters());
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryFilterSheet extends StatelessWidget {
  final CategoryModel? selectedCategory;
  const _CategoryFilterSheet({Key? key, this.selectedCategory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminOrderBloc, AdminOrderState>(
      builder: (context, state) {
        if (state is AdminOrderLoaded && state.categories.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                DropdownButtonFormField<CategoryModel>(
                  value: selectedCategory,
                  hint: const Text('Semua Kategori'),
                  isExpanded: true,
                  items: state.categories.map((CategoryModel category) {
                    return DropdownMenuItem<CategoryModel>(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (CategoryModel? newValue) {
                    Navigator.pop(context, newValue);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        }
        return const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
