import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/domain.dart';
import 'database.dart';

/// User preferences. Immutable; changes go through [SettingsStore].
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark, // dark recommended for fog days (§7.2)
    this.dynamicColor = false,
    this.appLock = false,
    this.secureScreen = true,
    this.topSymptoms = SymptomCluster.defaultTop3,
    this.notificationText = 'Time for your check-in',
    this.onboarded = false,
  });

  final ThemeMode themeMode;
  final bool dynamicColor;
  final bool appLock;
  final bool secureScreen; // FLAG_SECURE
  final List<SymptomCluster> topSymptoms;
  final String notificationText;
  final bool onboarded;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? dynamicColor,
    bool? appLock,
    bool? secureScreen,
    List<SymptomCluster>? topSymptoms,
    String? notificationText,
    bool? onboarded,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        dynamicColor: dynamicColor ?? this.dynamicColor,
        appLock: appLock ?? this.appLock,
        secureScreen: secureScreen ?? this.secureScreen,
        topSymptoms: topSymptoms ?? this.topSymptoms,
        notificationText: notificationText ?? this.notificationText,
        onboarded: onboarded ?? this.onboarded,
      );

  Map<String, String> toRows() => {
        'themeMode': themeMode.name,
        'dynamicColor': '$dynamicColor',
        'appLock': '$appLock',
        'secureScreen': '$secureScreen',
        'topSymptoms': jsonEncode(topSymptoms.map((s) => s.name).toList()),
        'notificationText': notificationText,
        'onboarded': '$onboarded',
      };

  factory AppSettings.fromRows(Map<String, String> r) {
    const d = AppSettings();
    return AppSettings(
      themeMode: r['themeMode'] == null
          ? d.themeMode
          : ThemeMode.values.byName(r['themeMode']!),
      dynamicColor: r['dynamicColor'] == null
          ? d.dynamicColor
          : r['dynamicColor'] == 'true',
      appLock: r['appLock'] == 'true',
      secureScreen: r['secureScreen'] == null
          ? d.secureScreen
          : r['secureScreen'] == 'true',
      topSymptoms: r['topSymptoms'] == null
          ? d.topSymptoms
          : [
              for (final n in jsonDecode(r['topSymptoms']!) as List)
                SymptomCluster.values.byName(n as String),
            ],
      notificationText: r['notificationText'] ?? d.notificationText,
      onboarded: r['onboarded'] == 'true',
    );
  }
}

class SettingsStore {
  SettingsStore(this._db);
  final AppDatabase _db;

  Future<AppSettings> load() async {
    final rows = await _db.select(_db.settings).get();
    return AppSettings.fromRows({for (final r in rows) r.key: r.value});
  }

  Future<void> save(AppSettings s) => _db.batch((b) {
        b.insertAllOnConflictUpdate(_db.settings, [
          for (final e in s.toRows().entries)
            SettingsCompanion.insert(key: e.key, value: e.value),
        ]);
      });
}
