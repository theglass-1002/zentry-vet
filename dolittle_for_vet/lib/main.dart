import 'dart:async';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/screens/screens.dart';
import 'package:dolittle_for_vet/app_theme/app_theme.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';

late AndroidNotificationChannel channel;
FirebaseMessaging messaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const AndroidInitializationSettings initialzationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  AppCache appCache = AppCache();
  var st_translation = await appCache.getTranslation();
  var _bellState = await appCache.getMonitoringAlarmState();
  int translation = 0;
  AndroidNotification? android = message.notification?.android;
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  if (st_translation.contains('en')) {
    translation = 0;
  } else if (st_translation.contains('ko')) {
    translation = 1;
  } else if (st_translation.contains('es')) {
    translation = 2;
  }

  var Listlocale = [
    Locale('en-US', 'US'),
    Locale('ko-KR', 'KR'),
    Locale('es-ES', 'ES'),
  ];

  final controller = EasyLocalizationController(
    supportedLocales: const [
      Locale('en-US', 'US'),
      Locale('ko-KR', 'KR'),
      Locale('es-ES', 'ES')
    ],
    saveLocale: true,
    useOnlyLangCode: true,
    fallbackLocale: Listlocale[translation], // 기본값
    useFallbackTranslations: true,
    path: 'assets/translations',
    onLoadError: (FlutterError e) {
      UtilityFunction.log.e(e);
    },
    assetLoader: RootBundleAssetLoader(),
  );

  await controller.loadTranslations();
  UtilityFunction.log.e(controller.path.toString());
  UtilityFunction.log.e(controller.assetLoader);
  Localization.load(
    controller.locale,
    translations: controller.translations,
    fallbackTranslations: controller.fallbackTranslations,
  );
}

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    Wakelock.enable();
    await EasyLocalization.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
      UtilityFunction.log.e('isCrashlyticsCollectionEnabled-true');
    } else {
      UtilityFunction.log.e('isCrashlyticsCollectionEnabled-false');
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    runApp(
      Phoenix(
        child: EasyLocalization(
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ko', 'KR'),
            Locale('es', 'ES')
          ], //const ['en', 'ko'], // 지원하는 언어 리스트
          path: 'assets/translations', // 언어 파일이 있는 경로
          fallbackLocale: const Locale('en', 'US'), // 기본값
          child: MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()),
        ),
      ),
    );
  }, (error, stack) {
    print('Firebase initialization error: $error');
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  NotificationManager notificationManager = NotificationManager();
  ProfileManager profileManager = ProfileManager();
  SocketManager socketManager = SocketManager();
  MonitoringRoomManager monitoringRoomManager = MonitoringRoomManager();
  MonitoringDataManager monitoringDataManager = MonitoringDataManager();

  @override
  void initState() {
    if (mounted) {
      notificationManager.initializeApp();
      Vibration.cancel();
      WidgetsBinding.instance.addObserver(this);
      notificationManager.notificationMsg(context);
      super.initState();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    UtilityFunction.log.e('앱이 백그라운드 상태입니다');
    UtilityFunction.log.e(monitoringRoomManager.audioPlayer.state);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.inactive) {
    } else if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.resumed) {
    } else if (state == AppLifecycleState.detached) {
    } else {}
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    UtilityFunction().horizontalModeBlocking();
    AppCache().setTranslation(context.locale.languageCode);
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationManager>(
              create: (_) => notificationManager),
          ChangeNotifierProvider<ProfileManager>(create: (_) => profileManager),
          ChangeNotifierProvider<MonitoringDataManager>(
              create: (_) => monitoringDataManager),
          ChangeNotifierProvider<MonitoringRoomManager>(
              create: (_) => monitoringRoomManager),
          ChangeNotifierProvider<SocketManager>(create: (_) => socketManager)
        ],
        child: MaterialApp(
          title: 'vet',
          debugShowCheckedModeBanner: false,
          locale: context.locale, //언어 지역화 추가
          localizationsDelegates: context.localizationDelegates, //언어 지역화 추가
          supportedLocales: context.supportedLocales, //언어 지역화 추가
          // localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: ThemeData(
              scrollbarTheme: ScrollbarThemeData().copyWith(
                  thumbColor:
                      MaterialStateProperty.all(VetTheme.mainIndigoColor)),
              iconTheme: const IconThemeData(color: Colors.white),
              iconButtonTheme: IconButtonThemeData(
                  style: IconButton.styleFrom(
                      foregroundColor : Colors.white,
                      backgroundColor: Colors.transparent
                  )),
              dialogTheme: DialogTheme(
                  surfaceTintColor: Colors.white
              ),
              appBarTheme: AppBarTheme(
                titleTextStyle: TextStyle(
                  fontSize: VetTheme.titleTextSize(context),
                  color: Colors.white
                ),
                color: VetTheme.mainIndigoColor

              ),
              cardTheme: CardTheme(
                elevation: 0,
                surfaceTintColor: Colors.white
              ),
              bottomAppBarTheme: BottomAppBarTheme(
                color: Colors.transparent,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: VetTheme.mainIndigoColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7))
                    )
              )),
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              })),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/permission': (context) => const PermissionScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/main': (context) => MainScreen(),
            '/heartFailure': (context) => HeartFailureScreen(),
            //'/addAnimal':(context)=>const AddAnimalScreen(),
            '/addWithQrScreen': (context) => AddWithQrScreen(),
            '/notify': (context) => const NoticeScreen(),
            '/search': (context) => const SearchScreen(),
            '/setting': (context) => const SettingScreen(),
            '/profile': (context) => ProfileScreen(),
            '/webView': (context) => const WebViewExample(),
            '/announcementBoard': (context) => const AnnouncementBoardScreen(),
            '/announcementPost': (context) => const AnnouncementPostScreen(),
            '/help': (context) => const HelpScreen(),
            '/hospitalRegister': (context) => const HospitalRegisterScreen(),
            '/veterinarianRegister': (context) =>
                const VeterinarianRegisterScreen(),
            '/technicianRegister': (context) =>
                const TechnicianRegisterScreen(),
            '/hiddenAnimal': (context) => const HiddenAnimalScreen(),
            '/veterinarianManagement': (context) =>
                const VeterinarianManagementScreen(),
            '/vetQrScan': (context) => const ScanVeterinarianQrScreen(),
            '/hospitalManagement': (context) =>
                const HospitalManagementScreen(),
            '/hospitalHandover': (context) => const HospitalHandoverScreen(),
            '/handoverSubmission': (context) =>
                const HospitalHandoverSubmissionScreen(),
            '/createVetQr': (context) => const CreatVeteQrCodeScreen(),
            '/addVeterinarianScreen': (context) =>
                const AddVeterinarianScreen(),
            '/animalQrScan': (context) => const ScanAnimalQrScreen(),
            '/addAnimalScreen': (context) => const AddAnimalScreen(),
            '/animalDataModify': (context) => const AnimalDataModifyScreen(),
            '/monitoringSetting': (context) => const MonitoringSettingScreen(),
            '/TechnicianMainScreen': (context) => const TechnicianMainScreen(),
            '/createMultiLoginQr': (context) =>
                const CreateMultiLoginQrCodeScreen()
          },
        ));
  }
}
