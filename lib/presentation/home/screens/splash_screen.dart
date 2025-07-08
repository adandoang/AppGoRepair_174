import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gorepair_app/presentation/auth/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/screens/admin_dashboard_screen.dart';
import '../../home/screens/customer_dashboard_screen.dart';
import '../../home/screens/technician_dashboard_screen.dart';
import '../../home/bloc/order_bloc.dart';
import '../../../data/repository/order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
  await Future.delayed(const Duration(seconds: 1));

  try {
    final token = await const FlutterSecureStorage().read(key: 'authToken');
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (!mounted) return;

    if (token != null && userString != null) {
      final user = json.decode(userString);
      final role = user['role'];

      if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
      } else if (role == 'technician') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TechnicianDashboardScreen()));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => OrderBloc(orderRepository: OrderRepository()),
              child: const CustomerDashboardScreen(),
            ),
          ),
        );
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}