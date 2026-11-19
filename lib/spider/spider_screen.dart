import 'package:flutter/material.dart';
import '../solitaire_game.dart';
import '../solitaire_table.dart';

class SpiderPlayScreen extends StatelessWidget {
  const SpiderPlayScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const SolitaireTable(mode: GameMode.spider);
}
