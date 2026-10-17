import 'package:bonidus_apidus/presentation/views/view_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../domain/entities/card_item.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
      MaterialApp(
        home: Scaffold
          (body: ViewCardScreen(
          card: CardItem(title: 'ah', domain: 'ah.nl'

        ),)),
      )
  );
}