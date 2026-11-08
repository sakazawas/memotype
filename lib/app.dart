import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/home_page.dart';

class MemotypeApp extends StatelessWidget {
  const MemotypeApp({super.key});

  @override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Memotype',
    theme: AppTheme.darkTheme,
    home: const HomePage(),
  );
 }
}