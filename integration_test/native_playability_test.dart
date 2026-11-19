import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:integration_test/integration_test.dart';
import '../test/support/playability_checks.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'all three native modes: draw, undo, real touch move, rules, new deal',
    (t) async {
      final prefs = await SharedPreferences.getInstance();
      for (final mode in ['klondike', 'spider', 'invert']) {
        await prefs.remove('velvet-board-v1-$mode');
      }
      await checkPlayableModes(
        t,
        mockPreferences: false,
        capture: (name) async {
          // Native screenshot RPC can observe a compositor frame behind the
          // settled widget tree; allow route rasterization to finish in real time.
          await t.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 600)),
          );
          await t.pumpAndSettle();
          await binding.takeScreenshot(name);
        },
      );
    },
  );
}
