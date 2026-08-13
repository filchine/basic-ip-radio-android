import 'package:flutter/material.dart';
import 'package:ip_radio_app/themes/theme_provider.dart';
import 'package:ip_radio_app/providers/radio_provider.dart';
import 'package:ip_radio_app/providers/player_provider.dart';
import 'package:provider/provider.dart';
import 'pages/main_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => RadioProvider()),
        ChangeNotifierProvider(create: (context) => PlayerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const MainPage(),
    );
  }
}
