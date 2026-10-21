---
name: release-readiness
description: Run a pre-release checklist for a Flutter app - build configuration, versioning, quality gates, localization, accessibility, error and offline states, performance, security, store requirements. Use when preparing a build for testers, TestFlight, Play Console, or production, or when asked if the app is ready to ship.
metadata:
  opencode/slash: "true"
---

# Release Readiness

This skill audits and reports. It does not edit protected files (`pubspec.yaml`, `android/`,
`ios/`, signing config, env files) without approval (CORE-10). It never touches signing keys.

## When to use
Before any build that leaves the team, or "is it ready to release?".

## Checklist

**Quality gates**
- [ ] `dart format --set-exit-if-changed .` clean.
- [ ] `flutter analyze` zero issues.
- [ ] `flutter test` all green (full suite, not only affected).
- [ ] `bash .opencode/scripts/check_rules.sh --all` reports no leads (or each is justified); no file over 300 lines.
- [ ] `testers_release_note.txt` matches this build: tester language, every item has Try and Expect, nothing stale (NOTES-1..7). After the build is sent, run `/release-notes new`.
- [ ] Every feature has an up-to-date `FEATURE.md` and `docs/FEATURES_INDEX.md` is accurate (run `feature-doc` check script for each feature).

**Versioning and config**
- [ ] Version and build number bumped in `pubspec.yaml` (needs approval to edit).
- [ ] Correct flavor and environment (production base URL, keys via `--dart-define`).
- [ ] No debug banners, test screens, mock data, or verbose logging in release.
- [ ] App name, icons, splash, bundle id, and deep link config are correct per platform.

**Functionality**
- [ ] Every list or detail screen has loading, empty, and error states (STATE-5).
- [ ] Offline and slow-network behavior checked. 401 and token refresh flows checked.
- [ ] Permissions requested only when needed, with clear localized rationale.

**Localization and accessibility**
- [ ] All i18n files have the same keys (no missing translations), RTL screens verified (UI-5).
- [ ] Large font scale and small screens do not overflow (UI-6). Semantic labels present (UI-7).

**Performance and stability**
- [ ] Profile-mode check on a low-end device for main flows (see `performance-audit`).
- [ ] Crash and error reporting configured and receives a test event.

**Security**
- [ ] `security-review` checklist passed, especially secrets and cleartext traffic.
- [ ] Obfuscation and symbols: `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols` (Android), `flutter build ipa --obfuscate --split-debug-info=build/symbols` (iOS). Symbols archived for crash symbolication.

**Store requirements**
- [ ] Privacy policy URL, data safety / privacy nutrition labels match actual data collection.
- [ ] Screenshots, description, release notes ready. Target SDK and minimum OS requirements met.
- [ ] Store release notes written from the feature changelogs (not the tester note, which is for testers).

## Report format
```text
Ready: YES | NO | YES WITH RISKS
Blockers: <list with where and why>
Risks: <list>
Passed: <short list>
Needs human action: <signing, store console, approvals>
```
Never claim a check passed without running or inspecting it (CORE-33). Mark unchecked items as `NOT VERIFIED`.

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
