import 'package:provider/provider.dart';
import 'package:tadhkir_app/core/pp/pp.dart';
import 'package:tadhkir_app/core/utils/route.dart';
import 'package:tadhkir_app/notification_service.dart';
import 'package:tadhkir_app/sqldb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize(); // ✅ تهيئة الإشعارات
  SqlDb sqlDb = SqlDb(); // إنشاء كائن لقاعدة البيانات
  await sqlDb.intialDb(); // تهيئة قاعدة البيانات

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlarmGroupProvider()),
        ChangeNotifierProvider(create: (_) => sqlDb), // 🔹 إضافة SqlDb كمزود
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder:
          (context, child) => MaterialApp(
            initialRoute: "/",
            onGenerateRoute: AppRoute.routeApp,
            theme: ThemeData(
              textTheme: GoogleFonts.cairoTextTheme(
                Theme.of(context).textTheme,
              ),
              useMaterial3: false,
              scaffoldBackgroundColor: const Color(
                0xfffffbfb,
              ), // Set default background color
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'AR'), // Arabic, no country code
            ],
            locale: const Locale('ar', 'AR'),
            debugShowCheckedModeBanner: false,
          ),
    );
  }
}
