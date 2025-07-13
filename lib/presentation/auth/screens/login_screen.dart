// lib/presentation/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/auth_repository.dart';
import '../../../data/repository/order_repository.dart';
import '../../home/order/order_bloc.dart';
import '../../home/screens/admin_dashboard_screen.dart';
import '../../home/screens/customer_dashboard_screen.dart';
import '../../home/screens/technician_dashboard_screen.dart';
import '../login/login_bloc.dart';
import 'register_screen.dart';
import '../../home/admin_order/admin_order_bloc.dart';
import '../../home/technician_job/technician_job_bloc.dart';
import '../../../data/repository/category_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(authRepository: AuthRepository()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Login GoRepair')),
        resizeToAvoidBottomInset: true,
        body: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              // Logika pengecekan peran (role)
              if (state.user.role == 'admin') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => AdminOrderBloc(
                        orderRepository: OrderRepository(),
                        categoryRepository: CategoryRepository(), // <-- Tambahkan ini
                      )..add(FetchAdminDashboardData()), // Panggil event
                      child: const AdminDashboardScreen(),
                    ),
                  ),
                );
              } else if (state.user.role == 'technician') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => TechnicianJobBloc(orderRepository: OrderRepository())
                        ..add(FetchTechnicianJobs()), // Panggil event
                      child: const TechnicianDashboardScreen(),
                    ),
                  ),
                );
              } else { // Pelanggan
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) =>
                          OrderBloc(orderRepository: OrderRepository())
                          ..add(FetchCustomerOrders()),
                      child: const CustomerDashboardScreen(),
                    ),
                  ),
                );
              }
            } else if (state is LoginFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Login Gagal: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 200,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                // Logo Repair
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      // Icon Repair dengan background
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFF60A5FA),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF60A5FA).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.build_circle,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Text Logo
                      Text(
                        'GoRepair',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF60A5FA),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Solusi Perbaikan Terpercaya',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    if (state is LoginLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: () {
                        context.read<LoginBloc>().add(
                              LoginButtonPressed(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('LOGIN'),
                    );
                  },
                ),
                const SizedBox(height: 16), // Beri jarak
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  child: const Text('Belum punya akun? Daftar di sini'),
                )
              ],
            ),
          ), // IntrinsicHeight
        ), // ConstrainedBox
      ), // SingleChildScrollView
    ), // BlocListener
  ), // Scaffold
); // BlocProvider
  }
}