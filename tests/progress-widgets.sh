#!/usr/bin/env bash
# Export test for the progress tiles widget and the steps widget
# (base/reports/progressTilesWidget and base/reports/stepsWidget).
#
# Run from the project root:
#
#     tests/progress-widgets.sh
#
# The test exports the fixtures "Progress tiles widget" and "Steps widget"
# (under "Test content" > "Widgets") as AsciiDoc, and checks that:
#   - each widget on the page renders to an SVG image,
#   - no macro is left unrendered,
#   - Vega-Lite prints no warnings and no errors.
#
# The test passes when it prints "PASS" and exits with 0.

set -uo pipefail

ROOT="$(pwd)"
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT
failed=0

fail() {
  echo "FAIL: $1"
  failed=1
}

# fixture key, title, number of widgets on the page
check() {
  local key="$1" title="$2" expected="$3"
  if ! cyberismo export adoc "$OUT/$key" "$key" >"$OUT/$key.log" 2>&1; then
    cat "$OUT/$key.log"
    fail "$title: AsciiDoc export failed"
    return
  fi
  local file="$OUT/$key/index.adoc"
  if [ ! -f "$file" ]; then
    file="$(find "$OUT/$key" -name '*.adoc' | head -1)"
  fi
  local images
  images="$(grep -c 'image::data:image/svg+xml' "$file")"
  if [ "$images" -ne "$expected" ]; then
    fail "$title: $images SVG images, expected $expected"
  fi
  if grep -q '{{#' "$file"; then
    fail "$title: a macro is not rendered"
  fi
  if grep -q -i -E 'WARN|error' "$OUT/$key.log"; then
    grep -i -E 'WARN|error' "$OUT/$key.log"
    fail "$title: the export printed warnings or errors"
  fi
}

cd "$ROOT" || exit 1
check base_ybuxq82o "Progress tiles widget" 4
check base_7f0kadjk "Steps widget" 3

if [ "$failed" -eq 0 ]; then
  echo "PASS"
  exit 0
fi
exit 1
