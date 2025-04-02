import 'package:hive/hive.dart';
import '../model/category.dart';

class CategoryRepository {
  final Box<Category> _categoryBox = Hive.box<Category>('categories'); //mark

  List<Category> getAllCategories() {
    return _categoryBox.values.toList();
  }

  void addCategory(Category category) {
    _categoryBox.put(category.name, category);
  }

  void deleteCategory(String name) {
    _categoryBox.delete(name);
  }
}