import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'data/repositories/card_repository_sqlite.dart';
import 'domain/entities/card_item.dart';
import 'domain/repositories/card_repository.dart';
import 'l10n/app_localizations.dart';
import 'presentation/views/home_screen.dart';
import 'presentation/views/scan_card_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './presentation/viewmodels/card_viewmodel.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: ".env");
  CardRepository repository = CardRepositorySQLite();
  CardViewmodel viewmodel = CardViewmodel(cardRepository: repository);

  // Resolved before runApp() so a widget tap opens straight into the scan
  // screen as the app's first route, instead of showing HomeScreen first
  // and replacing it a moment later.
  CardItem? initialCard;
  if (Platform.isAndroid) {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      initialCard = await _resolveCardFromUri(uri, viewmodel);
    } catch (e, stackTrace) {
      log(
        "Error reading home widget launch uri",
        error: e,
        stackTrace: stackTrace,
        name: "main",
      );
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => viewmodel,
      child: ApidusBonidus(initialCard: initialCard),
    ),
  );

  if (Platform.isAndroid) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setUpHomeWidgetLaunchHandling(viewmodel);
    });
  }
}

Future<CardItem?> _resolveCardFromUri(
  Uri? uri,
  CardViewmodel viewmodel,
) async {
  if (uri == null || uri.host != 'card') return null;

  final id = int.tryParse(
    uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '',
  );
  if (id == null) return null;

  await viewmodel.loadCards();

  final matches = viewmodel.cardList.where((CardItem c) => c.id == id);
  return matches.isEmpty ? null : matches.first;
}

void _setUpHomeWidgetLaunchHandling(CardViewmodel viewmodel) {
  HomeWidget.widgetClicked.listen(
    (uri) async {
      final card = await _resolveCardFromUri(uri, viewmodel);
      if (card == null) return;

      // Replace the whole stack (instead of pushing on top of whatever is
      // currently shown) so there's nothing left to pop back to in the app:
      // pressing back exits straight to the Android home screen.
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ScanCardScreen(card: card, dismissOnTap: false),
        ),
        (route) => false,
      );
    },
    onError: (Object e, StackTrace st) {
      log(
        "Error handling home widget click",
        error: e,
        stackTrace: st,
        name: "main",
      );
    },
  );
}

class ApidusBonidus extends StatelessWidget {
  const ApidusBonidus({super.key, this.initialCard});

  final CardItem? initialCard;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: initialCard != null
          ? ScanCardScreen(card: initialCard!, dismissOnTap: false)
          : const HomeScreen(),
    );
  }
}
