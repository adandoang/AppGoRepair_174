import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/category_repository.dart';
import '../../category/bloc/category_bloc.dart';
import 'create_order_screen.dart';

// Ini adalah "Wrapper" atau halaman penyedia BLoC
class CreateOrderPage extends StatelessWidget {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryBloc(
        categoryRepository: CategoryRepository(),
      ),
      child: const CreateOrderScreen(), // Widget anak adalah screen kita
    );
  }
}