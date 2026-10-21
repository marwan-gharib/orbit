---
description: Sync testers_release_note.txt with the current changes, or start a new cycle with "new"
---
Argument: $ARGUMENTS

Load the skill `tester-release-notes` and `.opencode/rules/release-notes.md`.

Current note:
!`cat testers_release_note.txt 2>/dev/null || echo "(file does not exist yet)"`

Changed files:
!`git status --short 2>/dev/null | head -60`

- No argument: read the diff, find every change a tester can see or feel, and add or fix items in the
  note (NOTES-1..7): tester language, "Try" and "Expect" lines, no file names, no code terms. Remove
  items that no longer describe the current code. Show the final text.
- Argument `new`: a build was just sent to testers. Reset the note to the empty template and keep nothing
  from the previous cycle (NOTES-6).
