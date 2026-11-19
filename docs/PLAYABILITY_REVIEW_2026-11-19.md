# Velvet Solitaire — playability repair and release gate

## Scope and identity
- Three modes: Klondike, one-suit Spider, Invert.
- Existing App Store Connect app: 6812283839; bundle `Com.play.solitairegame`.
- Version 1.0.0. Replacement build number must be greater than the current ASC build (currently 2; re-query before uploading).
- iPhone portrait app; SafeArea + scrollable responsive tableau. No camera/sensor or special hardware features.
- Public metadata/testing status and native physical-device checks are separate from simulator gameplay acceptance.

## Repairs
- Replaced duplicated mode controllers with one explicit, tested game model. The previous Spider deal reused a random index while shrinking its deck and dealt the wrong starting counts. Now 54 tableau / 50 stock cards, ten columns, five complete stock deals.
- Foundation moves accept exactly one face-up card, correct suit and rank. Klondike builds up, Invert down.
- Tableau moves validate the entire face-up sequence, destination rank/color, and empty-column rule. Spider completed runs collect automatically.
- Shared typed touch/drag input; tap-select/tap-destination alternative; no hidden double-tap requirement.
- Correct recycle order; undo includes deals, reveals and collected runs.
- Separate per-mode board persistence after actions, with validated saved state.
- Readable branded menu, safe-area layout, scrollable long columns, back navigation, mode-specific rules and new-deal confirmation.

## Required acceptance evidence
1. Rules tests: reject multi-card/wrong-suit foundations; legal foundation moves; wins and undo.
2. Deck conservation and save round-trips for all three modes, 100 initial seeds each; long legal-play sequences.
3. Spider deal exhaustion, empty-column deal restriction, complete-run collection/reveal/undo.
4. Actual widget touch gestures on normal deals in all three modes: draw/undo, legal move, rules, new-deal cancel/confirm, route recreation/resume; 390x844, 320x568, 844x390.
5. Fresh iPhone simulator execution of the same gameplay scenarios using the native shared-preferences plugin, plus screenshots/video inspected for readability, clipped cards, launch/runtime errors.
6. Only after acceptance: merge/push final source, signed device build, Apple VALID, intended tester group/build membership and beta state verified.

## Status
Implementation and local regression tests in progress. Native render/gameplay review, final release and replacement distribution NOT YET PASSED. Existing TestFlight build is not this repaired source.
