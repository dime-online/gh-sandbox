#!/usr/bin/env bash
# Offline test suite for gh-sandbox. Uses tests/bin/gh as a stub, so no
# network and no authenticated gh is needed. Exit code is non-zero on failure.
set -u
cd "$(dirname "$0")/.." || exit 1
PATH="$(pwd)/tests/bin:$PATH"
export PATH

pass=0 fail=0
ok()  { pass=$((pass + 1)); printf 'ok   %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf 'FAIL %s\n' "$1"; }

# --- unit: prefixed() (sourcing runs nothing thanks to the main guard) -----
source ./gh-sandbox

[ "$(prefixed demo)" = "sandbox-demo" ] \
  && ok "prefixed adds the prefix" || bad "prefixed adds the prefix"
[ "$(prefixed sandbox-demo)" = "sandbox-demo" ] \
  && ok "prefixed keeps an existing prefix" || bad "prefixed keeps an existing prefix"

# --- cli: version, help ----------------------------------------------------
out=$(./gh-sandbox --version)
[ "$out" = "gh-sandbox $VERSION" ] && ok "--version matches VERSION" || bad "--version: $out"

./gh-sandbox help | grep -q "create" && ok "help lists create" || bad "help lists create"

# --- cli: dry-run create/destroy use the stubbed login ---------------------
out=$(./gh-sandbox -n create tmp --description demo)
case "$out" in
  *"[dry-run] gh repo create testuser/sandbox-tmp --private --description demo"*)
    ok "dry-run create builds the right command" ;;
  *) bad "dry-run create: $out" ;;
esac

out=$(./gh-sandbox -n create demo --public)
case "$out" in
  *"testuser/sandbox-demo --public"*) ok "dry-run create --public" ;;
  *) bad "dry-run create --public: $out" ;;
esac

out=$(./gh-sandbox -n destroy tmp --yes)
case "$out" in
  *"[dry-run] gh repo delete testuser/sandbox-tmp --yes"*)
    ok "dry-run destroy prefixes the name" ;;
  *) bad "dry-run destroy: $out" ;;
esac

# --- cli: errors -----------------------------------------------------------
if ./gh-sandbox bogus >/dev/null 2>&1; then
  bad "unknown command exits non-zero"
else
  ok "unknown command exits non-zero"
fi
if ./gh-sandbox create >/dev/null 2>&1; then
  bad "create without a name exits non-zero"
else
  ok "create without a name exits non-zero"
fi

# --- cli: list filters to the sandbox- prefix ------------------------------
out=$(./gh-sandbox list)
case "$out" in
  *sandbox-one*|*sandbox-two*) ok "list shows sandboxes" ;;
  *) bad "list shows sandboxes: $out" ;;
esac
case "$out" in
  *real-repo*) bad "list must not show non-sandboxes" ;;
  *) ok "list hides non-sandboxes" ;;
esac

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
