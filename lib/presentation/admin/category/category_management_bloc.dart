import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gorepair_app/data/models/category_model.dart';
import 'package:gorepair_app/data/repository/category_repository.dart';

part 'category_management_event.dart';
part 'category_management_state.dart';

class CategoryManagementBloc extends Bloc<CategoryManagementEvent, CategoryManagementState> {
  final CategoryRepository categoryRepository;

  CategoryManagementBloc({required this.categoryRepository}) : super(CategoryManagementInitial()) {
    on<LoadAllCategories>((event, emit) async {
      emit(CategoryManagementLoading());
      try {
        final categories = await categoryRepository.getAllCategories();
        emit(CategoryManagementLoaded(categories: categories));
      } catch (e) {
        emit(CategoryManagementError(message: e.toString()));
      }
    });

    on<AddCategory>((event, emit) async {
      try {
        await categoryRepository.createCategory(event.name, event.description);
        emit(CategoryManagementActionSuccess(message: 'Kategori berhasil ditambahkan!'));
        add(LoadAllCategories()); // Muat ulang daftar
      } catch (e) {
        emit(CategoryManagementError(message: e.toString()));
      }
    });

    on<EditCategory>((event, emit) async {
      try {
        await categoryRepository.updateCategory(event.id, event.name, event.description);
        emit(CategoryManagementActionSuccess(message: 'Kategori berhasil diperbarui!'));
        add(LoadAllCategories());
      } catch (e) {
        emit(CategoryManagementError(message: e.toString()));
      }
    });

    on<DeleteCategory>((event, emit) async {
      try {
        await categoryRepository.deleteCategory(event.id);
        emit(CategoryManagementActionSuccess(message: 'Kategori berhasil dihapus!'));
        add(LoadAllCategories());
      } catch (e) {
        emit(CategoryManagementError(message: e.toString()));
      }
    });
  }
}