#!/usr/bin/env bash
# Reference test for the module documentation.
#
# Run from the project root:
#
#     tests/module-documentation-links.sh
#
# Exports leave out the test content, so the documentation must not refer to
# it. tests/module-documentation.lp checks the links between cards. This test
# checks the references in the content of the documentation cards: each card
# key in an index.adoc (in an xref or a macro parameter) must be a card of the
# documentation, and not a card of the test content.
#
# The test passes when it prints "PASS" and exits with 0.

set -uo pipefail

DOCS=base_mrohzme2
TESTS=base_h8a3eqto
ROOT="$(pwd)"
failed=0

fail() {
  echo "FAIL: $1"
  failed=1
}

DOCS_DIR="$(find "$ROOT/cardRoot" -maxdepth 1 -type d -name "$DOCS")"
TESTS_DIR="$(find "$ROOT/cardRoot" -maxdepth 1 -type d -name "$TESTS")"
[ -n "$DOCS_DIR" ] || { echo "FAIL: documentation $DOCS not found"; exit 1; }
[ -n "$TESTS_DIR" ] || { echo "FAIL: test content $TESTS not found"; exit 1; }

card_keys() {
  find "$1" -name index.json -exec dirname {} \; | xargs -n1 basename | sort -u
}

doc_keys="$(card_keys "$DOCS_DIR")"
test_keys="$(card_keys "$TESTS_DIR")"

count=0
while IFS= read -r file; do
  for key in $(grep -oE 'base_[a-z0-9]{8}([^A-Za-z0-9_]|$)' "$file" | cut -c1-13 | sort -u); do
    count=$((count + 1))
    card="$(basename "$(dirname "$file")")"
    if grep -qx "$key" <<<"$test_keys"; then
      fail "$card refers to the test content card $key"
    elif ! grep -qx "$key" <<<"$doc_keys"; then
      fail "$card refers to $key, which is not a documentation card"
    fi
  done
done < <(find "$DOCS_DIR" -name index.adoc)

if [ "$failed" -eq 0 ]; then
  echo "PASS ($count references)"
fi
exit "$failed"
