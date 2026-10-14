---
name: security-review
description: Review a Flutter mobile app change or feature for security issues - secrets, token storage, logging of sensitive data, input and deep link validation, network configuration, platform settings, dependencies, and release hardening. Use when handling auth, tokens, payments, personal data, deep links, WebViews, or before a release.
metadata:
  opencode/slash: "true"
---

# Security Review (mobile)

## When to use
Auth or session work, anything storing or sending personal or financial data, deep links,
WebViews, new dependencies, pre-release review, or an explicit security request.

## Checklist

**Secrets and config**
- [ ] No API keys, tokens, passwords, or private URLs in source, assets, or `FEATURE.md`.
      Config comes from build-time `--dart-define` or flavor config. Never commit `.env`.
      Environment variable NAMES live in `core/constants/` (ARCH-10); secret VALUES never appear in source.
- [ ] Anything shipped in the app is treated as public. Real secrets stay on the server.

**Storage**
- [ ] Tokens and sensitive values only through the secure-storage abstraction (DATA-9).
- [ ] Non-sensitive cache is encrypted or excluded when it contains personal data.
- [ ] Sensitive data is cleared on logout.

**Logging and errors**
- [ ] No tokens, passwords, full request bodies, or personal data in logs, analytics, or crash reports (use redaction in the logging interceptor).
- [ ] Users never see raw exceptions or server messages (ERR-4).

**Network**
- [ ] HTTPS only. No cleartext traffic allowed in release (Android network security config, iOS ATS).
- [ ] Certificate pinning considered for high-risk apps (through the API client, never per datasource).
- [ ] Auth header attached by the interceptor only (DATA-2). Refresh-token flow handles races.

**Input and links**
- [ ] Client-side validation is for UX only. Assume the server validates.
- [ ] Deep link and route parameters are validated and treated as untrusted (NAV-4: IDs and primitives only).
- [ ] WebViews: restrict JavaScript and navigation to trusted origins, no sensitive data in URLs.
- [ ] No sensitive data passed through `extra` or exposed in route paths.

**Platform**
- [ ] Android: `allowBackup` considered, exported components minimal, permissions minimal and justified, debuggable off in release.
- [ ] iOS: only needed permissions and usage descriptions, keychain accessibility appropriate.
- [ ] Screens with sensitive data considered for screenshot or app-switcher protection.

**Auth**
- [ ] Biometric or local auth is a convenience gate on top of server auth, not a replacement.
- [ ] Token expiry, refresh failure, and forced logout paths are tested.

**Dependencies (H-2)**
- [ ] No new package without approval (use `package-evaluation`). Check maintenance and known issues.

**Release hardening**
- [ ] `--obfuscate --split-debug-info` for release builds. Debug banners, test hooks, and verbose logs off.

## Quick scans (leads, not proof)
```bash
grep -rnE "(api[_-]?key|secret|password|token)\s*[:=]\s*['\"][^'\"]+['\"]" lib --include=*.dart
grep -rnE "(print|debugPrint|log)\(.*(token|password|authorization)" lib --include=*.dart -i
grep -rn "http://" lib --include=*.dart
```

## Report format
```text
Critical: <issue - where - impact - fix>
High:
Medium:
Low / hardening:
Checked and OK: <short list>
```
Never paste real secrets into a report. Reference the file and line only.

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
