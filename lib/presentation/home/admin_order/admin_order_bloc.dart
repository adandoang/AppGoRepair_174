import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/models/category_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repository/category_repository.dart';
import '../../../data/repository/order_repository.dart';

part 'admin_order_event.dart';
part 'admin_order_state.dart';

class AdminOrderBloc extends Bloc<AdminOrderEvent, AdminOrderState> {
  final OrderRepository orderRepository;
  final CategoryRepository categoryRepository; // Tambahkan repository kategori

  AdminOrderBloc({required this.orderRepository, required this.categoryRepository}) : super(AdminOrderInitial()) {

    // Handler untuk memuat data awal
    on<FetchAdminDashboardData>((event, emit) async {
      emit(AdminOrderLoading());
      try {
        final results = await Future.wait([
          orderRepository.getAdminOrders(),
          categoryRepository.getAllCategories(),
        ]);
        final orders = results[0] as List<OrderModel>;
        final categories = results[1] as List<CategoryModel>;
        emit(AdminOrderLoaded(orders: orders, categories: categories));
      } catch (e) {
        emit(AdminOrderError(message: e.toString()));
      }
    });

    // Handler untuk menerapkan filter
    on<ApplyAdminFilters>((event, emit) async {
      final currentState = state;
      if (currentState is AdminOrderLoaded) {
        emit(AdminOrderLoading());
        try {
          final filteredOrders = await orderRepository.getAdminOrders(
            categoryId: event.categoryId,
            searchQuery: event.searchQuery,
          );
          // Kirim kembali daftar order yang baru dengan daftar kategori yang lama
          emit(AdminOrderLoaded(orders: filteredOrders, categories: currentState.categories));
        } catch (e) {
          emit(AdminOrderError(message: e.toString()));
        }
      }
    });
  }
}