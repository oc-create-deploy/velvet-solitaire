import "package:flutter/material.dart";
import 'package:flutter_test/flutter_test.dart';
import 'package:velvet_solitaire/solitaire_game.dart';
import 'support/playability_checks.dart';

void main() {
  test('every deal conserves all cards; Spider has54 dealt and50stock', () {
    for (final mode in GameMode.values) {
      for (var seed = 0; seed < 100; seed++) {
        final g = SolitaireGame(mode, seed: seed);
        expect(g.cardCount, mode == GameMode.spider ? 104 : 52);
        expect(g.columns.every((p) => p.last.faceUp), isTrue);
        expect(g.stock.length, mode == GameMode.spider ? 50 : 24);
        if (mode == GameMode.spider)
          expect(g.columns.map((p) => p.length), [
            6,
            6,
            6,
            6,
            5,
            5,
            5,
            5,
            5,
            5,
          ]);
        expect(SolitaireGame.decode(g.encode()).encode(), g.encode());
      }
    }
  });
  test(
    'foundation rejects stacks and wrong suits; legal single card succeeds',
    () {
      for (final mode in [GameMode.klondike, GameMode.invert]) {
        final g = SolitaireGame(mode);
        final rank = mode == GameMode.invert ? 13 : 1;
        g.columns[0] = [
          GameCard(0, 0, rank, faceUp: true),
          GameCard(1, 1, rank, faceUp: true),
        ];
        expect(g.moveToFoundation(const CardMove(0, 0), 0), isFalse);
        expect(g.moveToFoundation(const CardMove(0, 1), 0), isFalse);
        g.columns[0].removeLast();
        expect(g.moveToFoundation(const CardMove(0, 0), 0), isTrue);
        expect(g.foundations[0].single.rank, rank);
        expect(g.undo, returnsNormally);
        expect(g.columns[0].single.rank, rank);
      }
    },
  );
  test('stock draws, recycles and undoes without losing cards', () {
    for (final mode in [GameMode.klondike, GameMode.invert]) {
      final g = SolitaireGame(mode, seed: 7);
      final original = g.encode();
      for (var i = 0; i < 24; i++) {
        expect(g.draw(), isNull);
        expect(g.cardCount, 52);
      }
      final first = g.waste.first.id;
      expect(g.draw(), isNull);
      expect(g.waste, isEmpty);
      expect(g.stock.length, 24);
      expect(g.draw(), isNull);
      expect(g.waste.single.id, first);
      for (var i = 0; i < 26; i++) {
        g.undo();
      }
      expect(g.encode(), original);
    }
  });
  test('Spider deals exactlyfive rows and blocks deals over empty columns', () {
    final g = SolitaireGame(GameMode.spider, seed: 9);
    final initial = g.encode();
    for (var i = 0; i < 5; i++) {
      expect(g.draw(), isNull);
      expect(g.cardCount, 104);
    }
    expect(g.draw(), isNotNull);
    for (var i = 0; i < 5; i++) {
      g.undo();
    }
    expect(g.encode(), initial);
    g.columns[1].addAll(g.columns[0]);
    g.columns[0].clear();
    final before = g.encode();
    expect(g.draw(), isNotNull);
    expect(g.encode(), before);
  });
  test(
    'Spider completes13-card run, reveals covered card and undo restores it',
    () {
      final g = SolitaireGame(GameMode.spider);
      g.columns[0] = [
        GameCard(80, 0, 9),
        ...List.generate(12, (i) => GameCard(i, 0, 13 - i, faceUp: true)),
      ];
      g.columns[1] = [GameCard(90, 0, 1, faceUp: true)];
      expect(g.moveToColumn(const CardMove(1, 0), 0), isTrue);
      expect(g.completed, 1);
      expect(g.columns[0].single.faceUp, isTrue);
      g.undo();
      expect(g.completed, 0);
      expect(g.columns[0].length, 13);
      expect(g.columns[0].first.faceUp, isFalse);
    },
  );
  test('final foundation card produces win and undo returns to playing', () {
    for (final mode in [GameMode.klondike, GameMode.invert]) {
      final g = SolitaireGame(mode);
      g.foundations = List.generate(
        4,
        (s) => List.generate(
          s == 3 ? 12 : 13,
          (i) => GameCard(
            s * 13 + i,
            s,
            mode == GameMode.invert ? 13 - i : i + 1,
            faceUp: true,
          ),
        ),
      );
      g.columns = List.generate(7, (_) => <GameCard>[]);
      g.columns[0] = [
        GameCard(51, 3, mode == GameMode.invert ? 1 : 13, faceUp: true),
      ];
      g.stock = [];
      g.waste = [];
      expect(g.won, isFalse);
      expect(g.moveToFoundation(const CardMove(0, 0), 3), isTrue);
      expect(g.won, isTrue);
      expect(g.cardCount, 52);
      g.undo();
      expect(g.won, isFalse);
      expect(g.cardCount, 52);
    }
  });
  test(
    'long legal play sequences preserve cards, saves and undo in allmodes',
    () {
      for (final mode in GameMode.values) {
        final g = SolitaireGame(mode, seed: 42);
        for (var round = 0; round < 120; round++) {
          final before = g.encode();
          bool moved = false;
          for (var source = 0; source < g.columns.length && !moved; source++) {
            for (var i = 0; i < g.columns[source].length && !moved; i++) {
              final move = CardMove(source, i);
              for (var s = 0; s < 4 && !moved; s++) {
                moved = g.moveToFoundation(move, s);
              }
              for (
                var target = 0;
                target < g.columns.length && !moved;
                target++
              ) {
                moved = g.moveToColumn(move, target);
              }
            }
          }
          if (!moved) g.draw();
          expect(g.cardCount, mode == GameMode.spider ? 104 : 52);
          expect(SolitaireGame.decode(g.encode()).encode(), g.encode());
          if (g.encode() != before && round % 5 == 0) {
            g.undo();
            expect(g.encode(), before);
          }
        }
      }
    },
  );
  for (final size in [(390.0, 844.0), (320.0, 568.0), (844.0, 390.0)]) {
    testWidgets('touch controls and layout ${size.$1}x${size.$2}', (t) async {
      t.view.physicalSize = Size(size.$1, size.$2);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await checkPlayableModes(t);
    });
  }
}
