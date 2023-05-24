import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Screen/Splash.dart';
import 'package:dsign_london/dataType/adressData.dart';
import 'package:dsign_london/dataType/productData.dart';
import 'package:dsign_london/dataType/userData.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.initFlutter();
  Stripe.publishableKey =
      "pk_live_51N4TEESHFvHiJ90KDqu2rXUqqadOC7QCrtuJsiQ0XLzSIOGpjN3u8r6pLcZy9pYsdaouTsGFJqM1Y7NoU2cKwDmC00mNTLdNsD";

  if (!Hive.isAdapterRegistered(productDataAdapter().typeId)) {
    Hive.registerAdapter(productDataAdapter());
  }
  if (!Hive.isAdapterRegistered(userDataAdapter().typeId)) {
    Hive.registerAdapter(userDataAdapter());
  }
  if (!Hive.isAdapterRegistered(addressDataAdapter().typeId)) {
    Hive.registerAdapter(addressDataAdapter());
  }

  runApp(const dsignlondon());
}

class dsignlondon extends StatelessWidget {
  const dsignlondon({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: primaryColor(),
      title: 'Dsign London',
      home: splashScreen(),
    );
  }
}
