import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/datastore/unperch_datastore.dart';
import 'core/db/app_database.dart';
import 'core/services/background/background_service_manager.dart';
import 'core/services/notification/notification_service.dart';
import 'core/services/reminder_scheduler.dart';
import 'core/services/tts/tts_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init shared prefs + datastore
  final prefs = await SharedPreferences.getInstance();
  final dataStore = UnperchDataStore(prefs);

  // 2. Init database
  final db = AppDatabase();

  // 3. Init notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 4. Init TTS service
  final ttsService = await TtsService.create(dataStore);

  // 5. Init reminder scheduler
  final scheduler = ReminderScheduler(
    dataStore: dataStore,
    reminderDao: db.reminderDao,
    skipDao: db.skipDao,
    shiftDao: db.shiftDao,
  );

  // 6. Init background service manager
  final bgManager = BackgroundServiceManager();
  await bgManager.initialize();

  // 7. Schedule today if needed — await to avoid DB lock race with first render
  await scheduler.scheduleTodayIfNeeded();

  runApp(
    ProviderScope(
      overrides: [
        unperchDataStoreProvider.overrideWithValue(dataStore),
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notificationService),
        ttsServiceProvider.overrideWithValue(ttsService),
        reminderSchedulerProvider.overrideWithValue(scheduler),
        backgroundServiceManagerProvider.overrideWithValue(bgManager),
      ],
      child: const UnperchApp(),
    ),
  );
}
