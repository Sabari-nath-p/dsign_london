import 'package:dsign_london/dataType/adressData.dart';
import 'package:hive_flutter/adapters.dart';
part 'userData.g.dart';

@HiveType(typeId: 3)
class userData {
  @HiveField(0)
  int id = -1;
  @HiveField(1)
  String name = "";
  @HiveField(2)
  String email = "";
  @HiveField(3)
  String phone = "";
  @HiveField(4)
  String profileUrl =
      "https://www.oseyo.co.uk/wp-content/uploads/2020/05/empty-profile-picture-png-2.png";
  @HiveField(5)
  List<addressData> address = [];
  @HiveField(6)
  int availablePoint = 0;

  userData(
      {required this.name,
      required this.email,
      required this.id,
      required this.phone,
      required this.address,
      required this.profileUrl,
      required this.availablePoint});
}
