// lib/presentation/order/screens/create_order_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/category_repository.dart';
import '../../../data/repository/order_repository.dart'; // Import OrderRepository
import '../../category/bloc/category_bloc.dart';
import '../create_order/create_order_bloc.dart'; // Import CreateOrderBloc
import 'create_order_screen.dart';

class CreateOrderPage extends StatelessWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sediakan CategoryBloc
    return BlocProvider(
      create: (context) => CategoryBloc(
        categoryRepository: CategoryRepository(),
      ),
      // Sediakan juga CreateOrderBloc
      child: BlocProvider(
        create: (context) => CreateOrderBloc(
          orderRepository: OrderRepository(),
        ),
        child: const CreateOrderScreen(),
      ),
    );
  }
}