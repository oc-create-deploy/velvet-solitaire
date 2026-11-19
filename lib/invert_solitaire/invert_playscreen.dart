import 'package:flutter/material.dart';
import '../solitaire_game.dart';
import '../solitaire_table.dart';

class InvertPlayScreen extends StatelessWidget {
  const InvertPlayScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const SolitaireTable(mode: GameMode.invert);
}
