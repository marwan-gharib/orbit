#!/usr/bin/env bash
# Mechanical rules scan for the Flutter project. Hits are LEADS, not proof:
# open each line, confirm it, then fix it or justify it.
#
# Usage (from anywhere; it runs from the project root):
#   bash .opencode/scripts/check_rules.sh            changed files (git), else everything
#   bash .opencode/scripts/check_rules.sh --all      everything under lib test docs .opencode
#   bash .opencode/scripts/check_rules.sh <path>...  only these files or folders
# Exit code: 0 = no leads, 1 = at least one lead. Warnings never fail the run.
# Needs bash (Git Bash or WSL on Windows) and LF line endings. Keep this file LF.

cd "$(cd "$(dirname "$0")/../.." && pwd)" || exit 2

MAX_LINES=300
OUT="$(mktemp)"; WARN="$(mktemp)"
trap 'rm -f "$OUT" "$WARN"' EXIT

is_generated() {
  case "$1" in
    *.g.dart|*.freezed.dart|lib/core/i18n/*|*package-lock.json|*pubspec.lock|*bun.lock) return 0 ;;
    */node_modules/*|*/.dart_tool/*|*/build/*|build/*|.dart_tool/*|.git/*) return 0 ;;
  esac
  return 1
}

matches_any() { # path 'glob1|glob2'
  local p="$1" g IFS='|'
  set -f
  for g in $2; do
    case "$p" in $g) set +f; return 0 ;; esac
  done
  set +f
  return 1
}

collect_all() {
  find lib test docs .opencode -type f 2>/dev/null
  for x in AGENTS.md opencode.json testers_release_note.txt; do [ -f "$x" ] && echo "$x"; done
}

collect_changed() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
  { git diff --name-only --relative HEAD 2>/dev/null || git diff --name-only --relative 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null; } | sort -u
}

MODE="changed"; FILES=(); CHANGED_LIST=""
if [ "$1" = "--all" ]; then MODE="all"; shift; fi
if [ "$#" -gt 0 ]; then
  MODE="paths"
  for a in "$@"; do
    a="${a#./}"
    if [ -d "$a" ]; then
      while IFS= read -r f; do FILES+=("$f"); done < <(find "$a" -type f 2>/dev/null)
    elif [ -f "$a" ]; then FILES+=("$a"); fi
  done
elif [ "$MODE" = "changed" ]; then
  CHANGED_LIST="$(collect_changed)"
  if [ -n "$CHANGED_LIST" ]; then
    while IFS= read -r f; do [ -f "$f" ] && FILES+=("$f"); done <<< "$CHANGED_LIST"
  else
    MODE="all"
  fi
fi
if [ "$MODE" = "all" ]; then
  while IFS= read -r f; do FILES+=("$f"); done < <(collect_all)
fi

SCAN=(); DART=()
for f in "${FILES[@]}"; do
  is_generated "$f" && continue
  SCAN+=("$f")
  case "$f" in *.dart) DART+=("$f") ;; esac
done
echo "Scanning ${#SCAN[@]} file(s) (mode: $MODE)"
[ "${#SCAN[@]}" -eq 0 ] && { echo "Nothing to scan."; exit 0; }

in_scope() { # scope path
  case "$1" in
    lib)     case "$2" in lib/*) return 0 ;; esac ;;
    libtest) case "$2" in lib/*|test/*) return 0 ;; esac ;;
    feat)    case "$2" in lib/core/*|lib/dev/*) return 1 ;; lib/*) return 0 ;; esac ;;
    features) case "$2" in lib/features/*) return 0 ;; esac ;;
    data)    case "$2" in lib/features/*/data/*) return 0 ;; esac ;;
    domain)  case "$2" in lib/features/*/domain/*) return 0 ;; esac ;;
    pres)    case "$2" in lib/features/*/presentation/*) return 0 ;; esac ;;
    cubits)  case "$2" in lib/features/*/presentation/cubits/*) return 0 ;; esac ;;
    router)  case "$2" in lib/core/router/*) return 0 ;; esac ;;
  esac
  return 1
}

scan() { # rule scope regex [skip-globs]
  local rule="$1" scope="$2" re="$3" skip="${4:-}" f
  for f in "${DART[@]}"; do
    in_scope "$scope" "$f" || continue
    [ -n "$skip" ] && matches_any "$f" "$skip" && continue
    grep -nE -- "$re" "$f" 2>/dev/null | grep -vE '^[0-9]+:[[:space:]]*//' |
      while IFS= read -r l; do printf '[%s] %s:%s\n' "$rule" "$f" "$l" >> "$OUT"; done
  done
}

# ---- FILE-1: maximum 300 lines (every hand-written file) -------------------------------------
for f in "${SCAN[@]}"; do
  n=$(wc -l < "$f" | tr -d ' ')
  [ "$n" -gt "$MAX_LINES" ] && printf '[FILE-1] %s: %s lines (limit %s)\n' "$f" "$n" "$MAX_LINES" >> "$OUT"
done

# ---- ARCH-10 / H-10: string literals as keys, paths, identifiers -----------------------------
CONST_SKIP='lib/core/constants/*|lib/core/router/route_names.dart|lib/core/router/route_paths.dart'
scan ARCH-10 libtest "json\[['\"]" "$CONST_SKIP"
scan ARCH-10 libtest "\.(get|post|put|patch|delete|head)(<[^>]*>)?\(\s*['\"]" "$CONST_SKIP"
scan ARCH-10 libtest "Uri\.parse\(\s*['\"]" "$CONST_SKIP"
scan ARCH-10 libtest "(getString|setString|getInt|setInt|getBool|setBool|getDouble|setDouble|getStringList|setStringList|containsKey|remove)\(\s*['\"]" "$CONST_SKIP"
scan ARCH-10 lib "\b(key|tag|heroTag|path|routeName|eventName|channel)\s*:\s*['\"]" "$CONST_SKIP"
scan ARCH-10 data "^\s*['\"][A-Za-z0-9_.-]+['\"]\s*:" "$CONST_SKIP"
scan ARCH-10 lib "context\.(go|push|replace|pushReplacement|goNamed|pushNamed|replaceNamed)\(\s*['\"]" "$CONST_SKIP"
scan ARCH-10 lib "['\"]assets/" "$CONST_SKIP"
scan ARCH-10 router "\bname\s*:\s*['\"]" "$CONST_SKIP"

# ---- Layers, DI, navigation ------------------------------------------------------------------
scan ARCH-1 domain "package:flutter/"
scan ARCH-1 pres "^import .*/data/"
scan STATE-2 cubits "^import .*(repositories|datasources)/"
scan DATA-1 lib "package:dio/" 'lib/core/network/*|lib/core/errors/*'
scan DOM-1 lib "(extends|implements|with)\s+UseCase(WithoutParams)?\b|class\s+NoParams\b"
scan DI-4 features "\b(getIt|GetIt)\b"
scan NAV-1 feat "Navigator\.(of|push|pushNamed|pushReplacement|pop|maybePop|popUntil)\b"

# ---- UI-1 / UI-4 / H-5: hardcoded text and styling ------------------------------------------
scan UI-4 feat "\bText\(\s*['\"]"
scan UI-4 feat "\b(labelText|hintText|helperText|errorText|tooltip|semanticsLabel|semanticLabel|title|label|hint|message|subtitle)\s*:\s*['\"]"
scan UI-1 feat "Color\(0x|Color\.fromARGB|Color\.fromRGBO|\bTextStyle\(|\bAppColors\.|\bAppTextStyles\."
scan UI-1 feat "\bColors\.[A-Za-z0-9]+" ''
# Colors.transparent is allowed: drop those hits
if [ -s "$OUT" ]; then grep -v 'Colors\.transparent' "$OUT" > "$OUT.t"; mv "$OUT.t" "$OUT"; fi

# ---- BASE-3: raw SDK widgets that core already covers ---------------------------------------
scan BASE-3 feat "\b(ElevatedButton|TextButton|OutlinedButton|FilledButton|TextField|TextFormField|AlertDialog|SimpleDialog|Dialog|SnackBar|BottomSheet|Card|PopupMenuButton|showDialog|showModalBottomSheet|showBottomSheet|showMenu|showCupertinoDialog|showCupertinoModalPopup|ScaffoldMessenger)\b"

# ---- ANIM-2: raw animation, overlay, haptic, and Lottie APIs in features ---------------------
scan ANIM-2 feat "\b(AnimationController|AnimatedBuilder|TweenAnimationBuilder|CurvedAnimation|AnimatedContainer|AnimatedOpacity|AnimatedSwitcher|AnimatedSize|AnimatedCrossFade|AnimatedPositioned|AnimatedAlign|AnimatedPadding|AnimatedScale|AnimatedRotation|AnimatedSlide|AnimatedDefaultTextStyle|AnimatedList|FadeTransition|SlideTransition|ScaleTransition|RotationTransition|SizeTransition|PositionedTransition|Hero|PageRouteBuilder|MaterialPageRoute|CupertinoPageRoute|CustomTransitionPage|HapticFeedback|CircularProgressIndicator|LinearProgressIndicator|SingleTickerProviderStateMixin|TickerProviderStateMixin)\b|\bTween(<|\()|package:(lottie|shimmer|flutter_animate|animations)/|\bCurves\."

# ---- RESP-2 / RESP-3 / RESP-4: bare sizes and screen math ------------------------------------
NUM='[1-9][0-9]*(\.[0-9]+)?'
scan RESP-2 feat "\b(width|height|size|radius|fontSize|thickness|strokeWidth|spacing|runSpacing|gap|top|bottom|left|right|start|end|horizontal|vertical|minWidth|maxWidth|minHeight|maxHeight|iconSize)\s*:\s*$NUM\s*[,)]"
scan RESP-2 feat "(EdgeInsets(Directional)?\.all|BorderRadius\.circular|Radius\.circular|SizedBox\.square|Size\.square|Size\.fromWidth|Size\.fromHeight|EdgeInsets(Directional)?\.(fromLTRB|fromSTEB)|\bSize)\(\s*$NUM"
scan RESP-3 feat "MediaQuery\.(sizeOf|widthOf|heightOf|orientationOf)\(|MediaQuery\.(of|maybeOf)\([^)]*\)\.(size|orientation)|constraints\.(maxWidth|maxHeight|minWidth|minHeight)\s*[<>]=?\s*[0-9]"
scan RESP-4 lib "package:(flutter_screenutil|sizer|responsive_sizer|responsive_framework|flutter_sizer)/" 'lib/core/responsive/*'

# ---- Warnings: git-based reminders (never fail the run) --------------------------------------
if [ -n "$CHANGED_LIST" ]; then
  echo "$CHANGED_LIST" | grep -qE '^(lib|assets)/' &&
    ! echo "$CHANGED_LIST" | grep -qx 'testers_release_note.txt' &&
    echo "[NOTES-1] lib/ or assets/ changed but testers_release_note.txt did not (fine only if nothing is tester-visible)" >> "$WARN"
  for d in $(echo "$CHANGED_LIST" | sed -n 's#^\(lib/features/[^/]*\)/.*#\1#p' | sort -u); do
    echo "$CHANGED_LIST" | grep -qx "$d/FEATURE.md" || echo "[DOC-2] $d changed but $d/FEATURE.md did not" >> "$WARN"
  done
fi

LEADS=0; [ -s "$OUT" ] && LEADS=$(wc -l < "$OUT" | tr -d ' ')
WARNS=0; [ -s "$WARN" ] && WARNS=$(wc -l < "$WARN" | tr -d ' ')
[ "$LEADS" -gt 0 ] && sort -u "$OUT"
[ "$WARNS" -gt 0 ] && { echo "--- warnings"; cat "$WARN"; }
echo "Result: $LEADS lead(s), $WARNS warning(s). Leads are not proof: confirm each by reading the line."
[ "$LEADS" -gt 0 ] && exit 1
exit 0
