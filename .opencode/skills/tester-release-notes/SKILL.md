---
name: tester-release-notes
description: Write or update testers_release_note.txt (fastlane and Firebase App Distribution release notes) from the tester's point of view - what changed in the app, how to try it, what to expect - never the developer's file list. Use after any change a tester can see, use, or feel, when asked for release notes, or before sending a build.
---

# Tester Release Notes

The file `testers_release_note.txt` (project root) is uploaded as plain text with each build.
Testers read it to know what to test. Rules: `release-notes.md` (NOTES-1..7).

## When to use
After any tester-visible change; `/release-notes`; before a build leaves the team.

## Procedure

1. **Decide if it is tester-visible.** A tester can see or feel it (screen, text, flow, behavior,
   speed, a fixed bug) → write an item. Refactor, rename, tests, docs, logs, a feature not yet
   reachable from the UI → no item; report `Release note: none (no tester-visible change)`.
2. **Find the real words.** Screen names, button labels, and messages from `assets/i18n/*.json` and the
   screen code. The route and the widgets tell you how a tester gets there. Never invent navigation.
3. **Read the current file.** Same screen already listed → edit that item (NOTES-5). Item no longer
   true → rewrite or remove it. Otherwise append to NEW / CHANGED or FIXED.
4. **Write each item** with: what is different now, `Try:` steps, `Expect:` result. At most 3 lines.
5. **Check tone.** No file, class, layer, API, package, or rule names. No markdown, no emojis.

## Developer voice → tester voice

| Wrong (developer) | Right (tester) |
|---|---|
| Added `OrdersCubit` and `GetOrdersUseCase` | Orders: your orders now load when you open the Orders tab. |
| Fixed null check in `ProfileModel.fromJson` | Profile: the screen no longer closes by itself when your photo is missing. |
| Refactored login screen into widgets | (no item: nothing changed for the tester) |
| Migrated dialogs to `AppDialog` | Dialogs: all confirmation pop-ups now look the same and animate in. Try: delete an address. Expect: one consistent pop-up. |

## Template (also the empty file after `/release-notes new`)

```text
What to test in this build

NEW / CHANGED
1. Orders: a new empty state appears when you have no orders.
   Try: open Orders with a new account.
   Expect: an illustration and the text "No orders yet".

FIXED
1. Login: the button no longer stays disabled after a wrong password.
   Try: enter a wrong password, then the right one.
   Expect: you can tap Sign in again immediately.
```

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
