#!/usr/bin/env bash
# Validate a feature's FEATURE.md.
# Usage: bash check_feature_doc.sh lib/features/<feature>
set -u

feature_dir="${1:?usage: check_feature_doc.sh lib/features/<feature>}"
doc="$feature_dir/FEATURE.md"
problems=0

if [ ! -f "$doc" ]; then
  echo "FAIL: missing $doc"
  exit 1
fi

lines=$(wc -l < "$doc" | tr -d ' ')
if [ "$lines" -gt 150 ]; then
  echo "FAIL: $doc has $lines lines (limit 150)"
  problems=$((problems + 1))
fi

if ! grep -q "Last verified: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" "$doc"; then
  echo "FAIL: 'Last verified: YYYY-MM-DD' missing or malformed"
  problems=$((problems + 1))
fi

for n in 1 2 3 4 5 6 7 8 9 10 11 12 13; do
  if ! grep -qE "^## ${n}\. " "$doc"; then
    echo "FAIL: section ${n} heading missing"
    problems=$((problems + 1))
  fi
done

while read -r p; do
  if [ -f "$feature_dir/$p" ] || [ -f "$p" ] || [ -f "lib/$p" ]; then
    :
  else
    echo "FAIL: referenced file not found: $p"
    problems=$((problems + 1))
  fi
done < <(grep -oE '`[A-Za-z0-9_./-]+\.dart`' "$doc" | tr -d '`' | sort -u)

if grep -qE "TBD|TODO|<[A-Za-z ]+>" "$doc"; then
  echo "WARN: placeholders (TBD / TODO / <...>) still present"
fi

if [ "$problems" -eq 0 ]; then
  echo "OK: $doc"
  exit 0
fi
echo "$problems problem(s) in $doc"
exit 1
