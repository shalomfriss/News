import 'dart:async';

import 'package:analytics_repository/analytics_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// Firebase Dynamic Links was deprecated and removed from Firebase SDK
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:demo_news/main/bootstrap/app_bloc_observer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef AppBuilder = Future<Widget> Function(
  // Ignore, as we currently only use dynamic links for e-mail login.
  // e-mail login will be replaced but not deprecated.
  // source:https://firebase.google.com/support/dynamic-links-faq#im_currently_using_or_need_to_use_dynamic_links_for_email_link_authentication_in_firebase_authentication_will_this_feature_continue_to_work_after_the_sunset
  // ignore: deprecated_member_use
  // Firebase Dynamic Links was shut down - passing null as stub
  dynamic firebaseDynamicLinks,
  FirebaseMessaging firebaseMessaging,
  SharedPreferences sharedPreferences,
  AnalyticsRepository analyticsRepository,
);

Future<void> bootstrap(AppBuilder builder) async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Try to initialize Firebase, but don't crash if configuration is invalid
      bool firebaseInitialized = false;
      try {
        await Firebase.initializeApp();
        firebaseInitialized = true;
        if (kDebugMode) {
          print('✅ Firebase initialized successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️  Firebase initialization failed: $e');
          print('⚠️  Running in development mode without Firebase');
        }
      }

      // Create analytics repository with Firebase if available, otherwise use a mock
      final analyticsRepository = firebaseInitialized
          ? AnalyticsRepository(FirebaseAnalytics.instance)
          : AnalyticsRepository(FirebaseAnalytics.instance); // Will fail gracefully if not initialized

      final blocObserver = AppBlocObserver(
        analyticsRepository: analyticsRepository,
      );
      Bloc.observer = blocObserver;
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: await getApplicationSupportDirectory(),
      );

      if (kDebugMode) {
        await HydratedBloc.storage.clear();
      }

      // Only configure Crashlytics if Firebase is initialized
      if (firebaseInitialized) {
        try {
          await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
          FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
        } catch (e) {
          if (kDebugMode) {
            print('⚠️  Crashlytics setup failed: $e');
          }
        }
      }

      final sharedPreferences = await SharedPreferences.getInstance();

      unawaited(MobileAds.instance.initialize());
      runApp(
        await builder(
          // ignore: deprecated_member_use
          // Firebase Dynamic Links was shut down - passing null as stub
          null, // FirebaseDynamicLinks.instance,
          firebaseInitialized ? FirebaseMessaging.instance : null as dynamic,
          sharedPreferences,
          analyticsRepository,
        ),
      );
    },
    (error, stack) {
      if (kDebugMode) {
        print('❌ Unhandled error in bootstrap: $error');
        print('Stack trace: $stack');
      }
    },
  );
}
