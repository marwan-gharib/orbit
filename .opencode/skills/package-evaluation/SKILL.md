---
name: package-evaluation
description: Evaluate whether and which third-party package to use - SDK or Dart 3 alternative first, existing core coverage, maintenance health, license, size, platform support - and produce an approval proposal with an abstraction plan. Use when a task seems to need a new package. Never adds the package itself.
---

# Package Evaluation

No package is ever added without explicit approval (H-2, CORE-10). This skill produces the
proposal and then stops. Do not edit `pubspec.yaml` and do not run `flutter pub add`.

## When to use
A task needs something the project may not have: a new capability (charts, maps, QR, PDF,
notifications) or a convenience library.

## Procedure

1. **Can we avoid it?**
   - Does the Flutter SDK or Dart 3 cover it?
   - Does something already in `pubspec.yaml` or `core/` cover it? (`docs/CORE_MAP.md`)
   - Is it about 50 lines of our own code? Then write it.
2. **Find 2 to 4 candidates** with web search and pub.dev pages.
3. **Score each candidate:**

   | Criterion | What to check |
   |---|---|
   | Maintenance | Last release date, open issues and PR activity, bus factor |
   | Quality signals | pub points, likes, popularity, verified publisher |
   | Compatibility | Current Flutter and Dart SDK constraints, null safety, Android/iOS (and other targets we ship) |
   | Footprint | App size impact, transitive dependencies, native code or permissions added |
   | License | Compatible with commercial use |
   | Fit | Fits our architecture: can it sit behind a core abstraction (ARCH-5)? Needs `build_runner` or codegen (not allowed, ARCH-8)? |
   | Security | Known advisories, network access, data collection |
   | Exit cost | How hard to replace later |

4. **Write the proposal** and stop:

```text
Need: <what and why it cannot be done without a package>
Already checked: SDK / Dart 3 / existing packages / core - <result>
Candidates:
| Package | Version | Last release | Points / likes | License | Notes |
Recommendation: <package> because <reasons>
Integration plan: wrap behind `core/<area>/` abstraction <name>; only one implementation file imports it (ARCH-5)
Risks: <list>
Approval needed to: add `<package>: ^x.y.z` to pubspec.yaml
```

5. **Wait for explicit approval.** After approval, adding it is a separate, approved step. Then update `docs/CORE_MAP.md`.

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
