import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/app_settings.dart';
import 'data/database.dart';
import 'data/key_store.dart';
import 'data/providers.dart';

/// Minimal startup (PRD §10.7 rule 6): open the DB and load settings (which
/// include the theme). Everything else is lazy.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bundled font used in the PDF report; read only if the licences page opens.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['Roboto'],
        await rootBundle.loadString('assets/fonts/LICENSE-Roboto.txt'));
  });

  final db = await AppDatabase.open(await KeyStore.databaseKey());
  final settings = await SettingsStore(db).load();

  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      initialSettingsProvider.overrideWithValue(settings),
    ],
    child: const AfterglowApp(),
  ));
}
