import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/repository/order_repository.dart';
import 'package:gorepair_app/data/repository/technician_repository.dart';
import '../bloc/admin_order_detail_bloc.dart';
import 'admin_order_detail_screen.dart';

// Ini adalah halaman "Wrapper" penyedia BLoC
class AdminOrderDetailPage extends StatelessWidget {
  final int orderId;
  const AdminOrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminOrderDetailBloc(
        orderRepository: OrderRepository(),
        technicianRepository: TechnicianRepository(),
      )..add(LoadAdminOrderDetail(orderId: orderId)), // Langsung muat data
      child: const AdminOrderDetailScreen(),
    );
  }
}