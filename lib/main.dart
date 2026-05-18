import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:leudaar_app/res/app_colors.dart';
import 'package:leudaar_app/routes/app_pages.dart';
import 'package:leudaar_app/routes/app_routes.dart';
import 'package:leudaar_app/utils/service/local_storage/auth_storage.dart';
import 'package:leudaar_app/utils/service/socket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('authBox');

  final token = AuthStorage.getToken();
  final user = AuthStorage.getUser();

  await Get.putAsync(() => SocketService().init(token ?? '', user?.id ?? ''));

  // System UI Configuration (Status Bar & Navigation Bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF111827),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Optional: Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Le Udhaar',
      debugShowCheckedModeBanner: false,

      // Improved Theme
      theme: ThemeData(
        primaryColor: const Color(0xFF0EA5E9),
        scaffoldBackgroundColor: const Color(0xFF111827),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        useMaterial3: true,
      ),

      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages, // Better to use getPages with GetX
      // routes: AppPages.pages, // You can remove this if using getPages
    );
  }
}
