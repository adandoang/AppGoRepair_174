part of 'category_management_bloc.dart';

abstract class CategoryManagementState {}

class CategoryManagementInitial extends CategoryManagementState {}
class CategoryManagementLoading extends CategoryManagementState {}
class CategoryManagementLoaded extends CategoryManagementState {
  final List<CategoryModel> categories;
  CategoryManagementLoaded({required this.categories});
}
class CategoryManagementError extends CategoryManagementState {
  final String message;
  CategoryManagementError({required this.message});
}
class CategoryManagementActionSuccess extends CategoryManagementState {
    final String message;
    CategoryManagementActionSuccess({required this.message});
}