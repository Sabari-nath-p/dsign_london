import 'package:hive_flutter/hive_flutter.dart';
part 'adressData.g.dart';

@HiveType(typeId: 2)
class addressData {
  @HiveField(0)
  String address = "";
  @HiveField(1)
  String country = "";
  @HiveField(2)
  String state = "";
  @HiveField(3)
  String city = "";
  @HiveField(4)
  String zip = "";
  @HiveField(5)
  String details = "";
  @HiveField(6)
  String title = "";
  @HiveField(7)
  int id = -1;

  addressData(
      {required this.address,
      required this.city,
      required this.country,
      required this.details,
      required this.state,
      required this.zip,
      required this.title,
      required this.id});
}
