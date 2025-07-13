part of 'category_management_bloc.dart';

abstract class CategoryManagementEvent {}

class LoadAllCategories extends CategoryManagementEvent {}
class AddCategory extends CategoryManagementEvent {
  final String name;
  final String? description;
  AddCategory({required this.name, this.description});
}
class EditCategory extends CategoryManagementEvent {
  final int id;
  final String name;
  final String? description;
  EditCategory({required this.id, required this.name, this.description});
}
class DeleteCategory extends CategoryManagementEvent {
  final int id;
  DeleteCategory({required this.id});
}