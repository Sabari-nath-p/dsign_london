import 'package:hive_flutter/hive_flutter.dart';
part 'productData.g.dart';

@HiveType(typeId: 1)
class productData {
  @HiveField(0)
  int id = 0;
  @HiveField(1)
  String name = "";
  @HiveField(2)
  String slug = "";
  @HiveField(3)
  int price = 0;
  @HiveField(4)
  int quantity = 0;
  @HiveField(5)
  int subTotal = 0;
  @HiveField(6)
  int save = 0;
  @HiveField(7)
  String image;
  @HiveField(8)
  String unit;
  @HiveField(9)
  int vid = 0;

  productData(
      {required this.id,
      required this.name,
      required this.price,
      required this.quantity,
      required this.slug,
      required this.subTotal,
      required this.save,
      required this.image,
      required this.unit,
      this.vid = 0});
}
