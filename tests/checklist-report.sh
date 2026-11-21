#!/usr/bin/env bash
# Export test for the checklist report (base/reports/checklist).
#
# Run from the project root:
#
#     tests/checklist-report.sh
#
# The test exports the fixture "Checklist" (under "Test content" > "Checklist
# tests") as AsciiDoc and as PDF, and checks that:
#   - the table has the text of each checklist item,
#   - the titles of the items are text, not links (the items are hidden, so
#     the export does not have them),
#   - the results show their display names,
#   - the PDF export has no rendering warnings.
#
# The test passes when it prints "PASS" and exits with 0.

set -uo pipefail

FIXTURE=base_6oor0sgk
ROOT="$(pwd)"
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT
failed=0

fail() {
  echo "FAIL: $1"
  failed=1
}

FIXTURE_DIR="$(find "$ROOT/cardRoot" -type d -name "$FIXTURE" | head -1)"
if [ -z "$FIXTURE_DIR" ]; then
  echo "FAIL: fixture $FIXTURE not found"
  exit 1
fi

if ! cyberismo export adoc "$OUT/adoc" "$FIXTURE" >"$OUT/adoc.log" 2>&1; then
  cat "$OUT/adoc.log"
  echo "FAIL: AsciiDoc export failed"
  exit 1
fi
ADOC="$OUT/adoc/index.adoc"
TABLE="$(sed -n '/^| Item | Result | Comment/,/^|===/p' "$ADOC")"
if [ -z "$TABLE" ]; then
  echo "FAIL: the export has no checklist table"
  exit 1
fi

# Each item: its title and the first line of its content are in the table.
items=0
for item in "$FIXTURE_DIR"/c/*/; do
  grep -q '"cardType": "base/cardTypes/checklistItem"' "$item/index.json" || continue
  grep -q '"workflowState": "Archived"' "$item/index.json" && continue
  items=$((items + 1))
  title="$(sed -n 's/^ *"title": "\(.*\)",$/\1/p' "$item/index.json")"
  text="$(head -1 "$item/index.adoc")"
  grep -qF -- "*$title*" <<<"$TABLE" || fail "title of the item \"$title\" is not text in the table"
  grep -qF -- "$text" <<<"$TABLE" || fail "text of the item \"$title\" is not in the table"
done
[ "$items" -gt 0 ] || fail "the fixture has no checklist items"

grep -q '<<' <<<"$TABLE" && fail "the table has links (<<...>>) to the hidden items"

# The fixture is an instance of the template: all items are open.
opens="$(grep -c '^|Open$' <<<"$TABLE")"
[ "$opens" -eq "$items" ] || fail "expected $items results \"Open\", found $opens"
grep -q '^|open$' <<<"$TABLE" && fail "a result shows its value (open), not its display name"

if ! cyberismo export pdf "$OUT/checklist.pdf" "$FIXTURE" >"$OUT/pdf.log" 2>&1; then
  cat "$OUT/pdf.log"
  fail "PDF export failed"
elif grep -q 'warning' "$OUT/pdf.log"; then
  grep 'warning' "$OUT/pdf.log"
  fail "the PDF export has rendering warnings"
fi

if [ "$failed" -eq 0 ]; then
  echo "PASS ($items items)"
fi
exit "$failed"
