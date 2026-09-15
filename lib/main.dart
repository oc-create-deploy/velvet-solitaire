import 'package:flutter/material.dart';
import 'package:velvet_solitaire/invert_solitaire/invert_playscreen.dart';
import 'package:velvet_solitaire/playscreen.dart';
import 'package:velvet_solitaire/screens/options_menu.dart';
import 'package:velvet_solitaire/screens/rules.dart';
import 'package:velvet_solitaire/spider/spider_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velvet Solitaire',
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/menu',
      routes: {
        '/menu': (context) => Options(),
        '/klondike': (context) => PlayScreen(),
        '/rules': (context) => Rules(),
        '/spider': (context) => SpiderPlayScreen(),
        '/invert': (context) => InvertPlayScreen(),
      },
    );
  }
}
