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
Native QA 44493562861 passed on 2026-11-19: all three modes executed draw/undo, real legal touch moves, rules, new-deal confirmation/cancel and saved-board restoration using native iOS preferences. Log reports All tests passed; screenshots show accepted tableau moves in Klondike/Spider and a foundation move in Invert. Local suite passed 11 tests, including three viewport sizes.

Manual capture inspection found a wrapped Waste label and route-transition remnants in initial screenshots. Reduced that label font and added a real compositor settling delay before native screenshots; final native recheck of this polish pending. No physical device available or claimed. Final main merge, signed release and replacement TestFlight distribution NOT YET PASSED.


## Final native acceptance — 2026-11-19 10:03 UTC
QA 44499639333 passed the same three-mode integration suite on source fbbad70969baa95cbc3b3f40adec93c2a01569e5. Manually inspected all seven menu/deal/moved PNGs: Waste label is readable on one line, route-transition remnants gone, all ten Spider columns and seven Klondike/Invert columns visible, legal accepted moves visible with move counts. Native log reports All tests passed. Explicit simulator debug endpoint attachment resolved intermittent unified-log discovery hangs; no acceptance assertions removed.

Source fast-forwarded to main after acceptance. TestFlight build 3 release requested separately; deployment remains pending Apple processing and intended tester-group/beta-state verification.
