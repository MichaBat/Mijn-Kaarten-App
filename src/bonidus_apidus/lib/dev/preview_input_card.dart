import 'package:bonidus_apidus/data/repositories/card_repository_sqlite.dart';
import 'package:bonidus_apidus/presentation/viewmodels/card_viewmodel.dart';
import 'package:bonidus_apidus/presentation/views/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(
      create: (_) => CardViewmodel(cardRepository: CardRepositorySQLite()),
      child: const MaterialApp(
        home: Scaffold(body: Center(child: AddCardScreen())),
      ),
    ),
  );
}