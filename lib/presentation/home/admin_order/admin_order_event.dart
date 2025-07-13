part of 'admin_order_bloc.dart';

abstract class AdminOrderEvent {}

// Event untuk memuat semua data awal (orders dan categories)
class FetchAdminDashboardData extends AdminOrderEvent {}

// Event untuk menerapkan filter/pencarian
class ApplyAdminFilters extends AdminOrderEvent {
  final int? categoryId;
  final String? searchQuery;

  ApplyAdminFilters({this.categoryId, this.searchQuery});
}