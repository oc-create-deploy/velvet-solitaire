import 'package:flutter/material.dart';
import 'solitaire_game.dart';
import 'solitaire_table.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const SolitaireTable(mode: GameMode.klondike);
}
