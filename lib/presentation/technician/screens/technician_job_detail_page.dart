import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/repository/order_repository.dart';
import '../bloc/technician_job_detail_bloc.dart';
import 'technician_job_detail_screen.dart';

// Halaman "Wrapper" untuk menyediakan BLoC
class TechnicianJobDetailPage extends StatelessWidget {
  final int orderId;
  const TechnicianJobDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TechnicianJobDetailBloc(
        orderRepository: OrderRepository(),
      )..add(LoadTechnicianJobDetail(orderId: orderId)),
      child: const TechnicianJobDetailScreen(),
    );
  }
}