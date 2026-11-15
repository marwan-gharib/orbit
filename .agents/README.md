# Antigravity workflow — guide

Entry point: `AGENTS.md` (hard rules H-1..H-16, routing table, skills table, commands table).
Six rule files have `trigger: always_on` and are always loaded: `00-core`, `00-style`, `00-done`, `core-first`,
`file-size`, `release-notes`. Everything else is read on demand through the routing table.

## Rules (`.agents/rules/`, one topic per file, each under 70 lines)

| File | IDs | Topic |
|---|---|---|
| `00-core.md` | CORE-1..13 | start protocol, working agreement, workflow order |
| `00-style.md` | CORE-14..23 | comments, staying current, response and report format |
| `00-done.md` | CORE-24..33, H-checklist | Definition of Done and self-review |
| `core-first.md` | BASE-1..6 | every layer builds on `lib/core/` |
| `file-size.md` | FILE-1..4 | no file over 300 lines |
| `release-notes.md` | NOTES-1..7 | `testers_release_note.txt` for testers |
| `architecture.md`, `folder-structure.md`, `constants.md` | ARCH-1..10 | layers, tree, no literal keys |
| `domain-and-errors.md`, `data-layer.md`, `state-management.md` | DOM, ERR, DATA, STATE | the three layers |
| `ui-foundation.md`, `ui-layout.md`, `widgets.md`, `responsive.md`, `animations.md` | UI, WIDGET, RESP, ANIM | UI built on core |
| `di-and-navigation.md`, `testing.md`, `feature-docs.md` | DI, NAV, TEST, DOC | wiring, tests, docs |

## Skills (`.agents/skills/`, loaded with the `skill` tool)
`clean-code`, `solid-principles`, `clean-architecture`, `ui-from-core`, `feature-scaffold`, `add-endpoint`,
`write-tests`, `feature-doc`, `tester-release-notes`, `debugging`, `refactoring`, `code-review`,
`performance-audit`, `security-review`, `package-evaluation`, `git-workflow`, `release-readiness`.

## Commands (skills in `.agents/skills/`, typed as `/<name>`)
`/feature /screen /change /fix /core-check /promote-widget /tests /check /file-size /audit /review
/release-notes /pr /doc-sync`. Reviewer: the `reviewer` skill (`/reviewer`, read-only).

## Rules script
`bash .agents/scripts/check_rules.sh [--all | paths]` scans for file size, literal keys and paths,
raw widgets and animation APIs, bare sizes, layer breaks, hardcoded text. Hits are leads to confirm.
Needs bash (Git Bash or WSL on Windows) and LF line endings. To keep LF on Windows add to `.gitattributes`:
`*.sh text eol=lf`.

## Tester release note
Update `testers_release_note.txt` with every tester-visible change. After you send a build to testers,
run `/release-notes new` to start the next cycle. Fastlane keeps reading the same file.

## Before first use
- Adjust `docs/CORE_MAP.md` when `core/` changes; the agent trusts it and the files it points to.
- Skeletons in `skills/feature-scaffold/templates-*.md` use placeholders marked `ADAPT`; they are not compiled.

## Antigravity specifics
- Rules need YAML frontmatter with a `trigger`; a rule file without it is silently ignored.
- Commands are skills: type `/<name>` and the arguments in the same message.
- Terminal policy (Antigravity settings): deny `git commit*` and `git push*`; ask for `rm *`,
  `flutter pub add*`, and `flutter pub upgrade*`.
- If rules or skills do not show up, open the Customizations menu in the agent panel, then
  `/skills reload` or start a new conversation.
