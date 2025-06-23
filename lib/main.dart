import 'package:flutter/material.dart';
import 'package:project_2_graphs/config/routes/app_router.dart';
import 'package:project_2_graphs/core/theme/app_theme.dart';
import 'package:project_2_graphs/presentation/getx/theme_controller.dart';
import 'package:get/get.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => MaterialApp.router(
        title: "Project 2 Graphs",
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode.value,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
