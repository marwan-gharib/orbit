# Tester Release Notes (always loaded)

`testers_release_note.txt` (project root) is the release-notes file for testers. Fastlane sends
it to Firebase App Distribution as a plain text file, so it must always be ready to ship.
Detailed examples: `.opencode/skills/tester-release-notes/SKILL.md`.

- NOTES-1  After ANY change a tester can see, use, or feel, update `testers_release_note.txt` in
           the same task (CORE-30). Create the file if it does not exist.
- NOTES-2  Write for the tester, not the developer: what changed in the app and what to test.
           Never mention files, classes, layers, Cubits, APIs, endpoints, packages, refactors, or
           rule IDs. Use the screen names and button labels the tester sees on screen. Read the
           real labels from `assets/i18n/*.json`, never the key names.
- NOTES-3  No entry when nothing changes for the tester: refactors, renames, tests, docs, logging,
           internal cleanup, or work not reachable from the UI yet. Report
           `Release note: none (no tester-visible change)`.
- NOTES-4  Every item has three parts: what is different now, how to try it (short steps), what
           should happen. At most 3 lines per item. Steps must be true: derive them from the
           routes, screens, and labels in the code you read or changed. Never invent navigation.
- NOTES-5  Keep it current, not a log. The file holds what changed since the last build sent to
           testers. The same screen or flow changed again → edit its existing item. A change
           reverted or replaced in the same cycle → remove or rewrite its item. New items go at
           the end of their section.
- NOTES-6  Plain text only: no markdown (`#`, `**`, backticks, tables), no emojis, no code. English,
           unless the file is already in another language (then match it). Format:

```text
What to test in this build

NEW / CHANGED
1. <Screen or flow>: <what is different now>.
   Try: <steps>.
   Expect: <what you should see>.

FIXED
1. <Screen or flow>: <what was wrong, now fixed>.
   Try: <steps>.
   Expect: <result>.
```

           Leave out a section that has no items. Number items from 1 inside each section.
- NOTES-7  Only the user starts a new cycle: clear the file only when the user says the build was
           sent or runs `/release-notes new`. Never clear it yourself. Never delete an item you
           did not replace.
