import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvet_solitaire/main.dart';
import 'package:velvet_solitaire/solitaire_game.dart';
import 'package:velvet_solitaire/solitaire_table.dart';

typedef Capture = Future<void> Function(String name);
Future<void> checkPlayableModes(
  WidgetTester t, {
  Capture? capture,
  bool mockPreferences = true,
}) async {
  if (mockPreferences) SharedPreferences.setMockInitialValues({});
  await t.pumpWidget(const MyApp());
  await t.pumpAndSettle();
  expect(find.text('Velvet Solitaire'), findsOneWidget);
  await capture?.call('01-menu');
  for (final mode in GameMode.values) {
    final name = switch (mode) {
      GameMode.klondike => 'Klondike',
      GameMode.spider => 'Spider',
      GameMode.invert => 'Invert',
    };
    await t.ensureVisible(find.text(name));
    await t.tap(find.text(name));
    await t.pumpAndSettle();
    final state = t.state<SolitaireTableState>(find.byType(SolitaireTable));
    expect(state.game.cardCount, mode == GameMode.spider ? 104 : 52);
    await capture?.call('02-${mode.name}-deal');
    final stockBefore = state.game.stock.length;
    await t.ensureVisible(find.byKey(const ValueKey('stock')));
    await t.tap(find.byKey(const ValueKey('stock')));
    await t.pumpAndSettle();
    expect(
      state.game.stock.length,
      stockBefore - (mode == GameMode.spider ? 10 : 1),
    );
    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(state.game.stock.length, stockBefore);
    // Find a legal move on the real randomly dealt board, then execute touch input.
    CardMove? from;
    int? dest;
    bool foundation = false;
    for (var draws = 0; draws < 25 && from == null; draws++) {
      final g = state.game;
      final candidates = [
        if (g.waste.isNotEmpty) CardMove(-1, g.waste.length - 1),
        for (var c = 0; c < g.columns.length; c++)
          for (var i = 0; i < g.columns[c].length; i++) CardMove(c, i),
      ];
      for (final move in candidates) {
        for (var suit = 0; suit < 4; suit++) {
          if (g.canMoveToFoundation(move, suit)) {
            from = move;
            dest = suit;
            foundation = true;
            break;
          }
        }
        if (from != null) break;
        for (var col = 0; col < g.columns.length; col++) {
          if (g.canMoveToColumn(move, col)) {
            from = move;
            dest = col;
            break;
          }
        }
        if (from != null) break;
      }
      if (from == null) {
        await t.tap(find.byKey(const ValueKey('stock')));
        await t.pumpAndSettle();
      }
    }
    expect(
      from,
      isNotNull,
      reason: 'A legal touch move must be exercised in $name',
    );
    final moving = state.game.moving(from!).first;
    final source = find.byKey(ValueKey('card-${moving.id}'));
    await t.ensureVisible(source);
    await t.pumpAndSettle();
    final rect = t.getRect(source);
    // Exposed rank strip, not the covered center of a tableau card.
    final start = Offset(rect.center.dx, rect.top + min(6.0, rect.height / 4));
    final before = state.game.moves;
    if (foundation || t.view.physicalSize.width > t.view.physicalSize.height) {
      await t.tapAt(start);
      await t.pumpAndSettle();
      final tapTarget = foundation
          ? find.byKey(ValueKey('foundation-$dest'))
          : find.byKey(ValueKey('card-${state.game.columns[dest!].last.id}'));
      await t.ensureVisible(tapTarget);
      await t.pumpAndSettle();
      await t.tap(tapTarget);
      await t.pumpAndSettle();
    } else {
      final pile = state.game.columns[dest!];
      expect(pile, isNotEmpty);
      final target = find.byKey(ValueKey('card-${pile.last.id}'));
      await t.ensureVisible(target);
      await t.pumpAndSettle();
      final end = t.getRect(target).center;
      // The same pointer path a player uses: press, drag and release.
      final freshRect = t.getRect(source);
      final gesture = await t.startGesture(
        Offset(freshRect.center.dx, freshRect.top + 6),
      );
      await gesture.moveBy(const Offset(0, 2));
      await t.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(end);
      await t.pump(const Duration(milliseconds: 400));
      await gesture.up();
      await t.pumpAndSettle();
    }
    expect(
      state.game.moves,
      before + 1,
      reason: 'Actual touch move must be accepted in $name',
    );
    expect(state.game.cardCount, mode == GameMode.spider ? 104 : 52);
    await capture?.call('03-${mode.name}-moved');
    await t.tap(find.text('Undo'));
    await t.pumpAndSettle();
    expect(state.game.moves, before);
    await t.tap(find.byTooltip('Rules'));
    await t.pumpAndSettle();
    expect(find.text('$name rules'), findsOneWidget);
    await t.tap(find.text('Got it'));
    await t.pumpAndSettle();
    await t.tap(find.text('New deal'));
    await t.pumpAndSettle();
    await t.tap(find.text('Keep playing'));
    await t.pumpAndSettle();
    await t.tap(find.text('New deal'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(FilledButton, 'New deal'));
    await t.pumpAndSettle();
    expect(state.game.moves, 0);
    expect(state.game.cardCount, mode == GameMode.spider ? 104 : 52);
    expect(t.takeException(), isNull);
    await state.saveQueue;
    final savedBoard = state.game.encode();
    ScaffoldMessenger.of(
      t.element(find.byType(SolitaireTable)),
    ).clearSnackBars();
    await t.pageBack();
    await t.pumpAndSettle();
    await t.ensureVisible(find.text(name));
    await t.tap(find.text(name));
    await t.pumpAndSettle();
    final resumed = t.state<SolitaireTableState>(find.byType(SolitaireTable));
    expect(
      resumed.game.encode(),
      savedBoard,
      reason: 'Board survives screen recreation',
    );
    await t.pageBack();
    await t.pumpAndSettle();
  }
}
