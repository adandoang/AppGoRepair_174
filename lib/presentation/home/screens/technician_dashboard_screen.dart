import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/models/order_model.dart';
import 'package:gorepair_app/presentation/technician/screens/technician_job_detail_page.dart';
import '../../auth/screens/login_screen.dart';
import '../../../data/repository/auth_repository.dart';
import '../technician_job/technician_job_bloc.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  const TechnicianDashboardScreen({super.key});

  @override
  State<TechnicianDashboardScreen> createState() => _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageIndex == 0 ? 'Pekerjaan Aktif' : 'Riwayat Pekerjaan'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
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
      body: BlocBuilder<TechnicianJobBloc, TechnicianJobState>(
        builder: (context, state) {
          if (state is TechnicianJobLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TechnicianJobLoaded) {
            // --- LOGIKA PEMISAHAN DATA ---
            final List<OrderModel> historyJobs = state.jobs
                .where((job) =>
                    job.status == 'completed' || job.status == 'cancelled')
                .toList();
            
            final List<OrderModel> activeJobs = state.jobs
                .where((job) => !historyJobs.contains(job))
                .toList();
            
            List<Widget> pages = [
              _buildJobList(context, activeJobs, 'Anda tidak memiliki pekerjaan aktif.'),
              _buildJobList(context, historyJobs, 'Tidak ada riwayat pekerjaan.'),
            ];

            return IndexedStack(
              index: _pageIndex,
              children: pages,
            );
          }
          if (state is TechnicianJobError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Selamat Datang, Teknisi!'));
        },
      ),
      // --- TIDAK ADA FLOATING ACTION BUTTON ---
      // Footer dengan navigasi
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.dashboard, color: _pageIndex == 0 ? Theme.of(context).primaryColor : Colors.grey),
              tooltip: 'Pekerjaan Aktif',
              onPressed: () => setState(() => _pageIndex = 0),
            ),
            IconButton(
              icon: Icon(Icons.history, color: _pageIndex == 1 ? Theme.of(context).primaryColor : Colors.grey),
              tooltip: 'Riwayat',
              onPressed: () => setState(() => _pageIndex = 1),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membangun daftar pekerjaan
  Widget _buildJobList(BuildContext context, List<OrderModel> jobs, String emptyMessage) {
     if (jobs.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<TechnicianJobBloc>().add(FetchTechnicianJobs());
        },
        child: Stack(
          children: <Widget>[
            ListView(),
            Center(child: Text(emptyMessage)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TechnicianJobBloc>().add(FetchTechnicianJobs());
      },
      child: ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          
          // Logika untuk warna dan tampilan
          Color cardColor = Colors.white;
          Widget trailingWidget = const Icon(Icons.chevron_right);

          if (job.status == 'completed') {
            cardColor = Colors.green.shade50;
            trailingWidget = const Text('SELESAI', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
          } else if (job.status == 'cancelled') {
            cardColor = Colors.red.shade50;
            trailingWidget = const Text('DIBATALKAN', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold));
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: cardColor,
            child: ListTile(
              title: Text('Pekerjaan #${job.id} - ${job.category.name}'),
              subtitle: Text('Pelanggan: ${job.customer.name}'),
              trailing: trailingWidget,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TechnicianJobDetailPage(orderId: job.id),
                  ),
                ).then((_) {
                  context.read<TechnicianJobBloc>().add(FetchTechnicianJobs());
                });
              },
            ),
          );
        },
      ),
    );
  }
}
