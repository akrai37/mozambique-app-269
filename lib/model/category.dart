import 'package:hive/hive.dart';

part 'category.g.dart'; //name of file that will be generated

@HiveType(typeId: 0)
class Category extends HiveObject{

  @HiveField(0)
  String name;

  @HiveField(1)
  String type;

  Category(this.name, this.type);
}
