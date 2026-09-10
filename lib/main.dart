import 'package:flutter/material.dart';
//import 'screens/home_screen.dart';
import 'package:my_task_pad/Screens/home_screen.dart';
import 'services/hive_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Bloc Note',
      theme: AppTheme.light(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

