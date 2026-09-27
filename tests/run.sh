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

# --- unit: valid_name() ----------------------------------------------------
if valid_name demo-1_2.3; then ok "valid_name accepts safe names"; else bad "valid_name accepts safe names"; fi
if valid_name '' || valid_name .hidden || valid_name 'two words' || valid_name 'a/b'; then
  bad "valid_name rejects unsafe names"
else
  ok "valid_name rejects unsafe names"
fi

# --- cli: bad names fail before any gh call --------------------------------
if ./gh-sandbox -n create 'two words' >/dev/null 2>&1; then
  bad "create with a bad name exits non-zero"
else
  ok "create with a bad name exits non-zero"
fi
if ./gh-sandbox -n destroy 'a/b' --yes >/dev/null 2>&1; then
  bad "destroy with a bad name exits non-zero"
else
  ok "destroy with a bad name exits non-zero"
fi

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

out=$(./gh-sandbox -n create demo --clone)
case "$out" in
  *"testuser/sandbox-demo --private --clone"*) ok "dry-run create --clone" ;;
  *) bad "dry-run create --clone: $out" ;;
esac

out=$(./gh-sandbox -n create demo --add-readme)
case "$out" in
  *"testuser/sandbox-demo --private --add-readme"*) ok "dry-run create --add-readme" ;;
  *) bad "dry-run create --add-readme: $out" ;;
esac

out=$(./gh-sandbox -n destroy tmp --yes)
case "$out" in
  *"[dry-run] gh repo delete testuser/sandbox-tmp --yes"*)
    ok "dry-run destroy prefixes the name" ;;
  *) bad "dry-run destroy: $out" ;;
esac

out=$(./gh-sandbox -n open tmp)
case "$out" in
  *"[dry-run] gh browse --repo testuser/sandbox-tmp"*)
    ok "dry-run open prefixes the name" ;;
  *) bad "dry-run open: $out" ;;
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

out=$(./gh-sandbox list --json)
case "$out" in
  *'"name":"sandbox-one"'*) ok "list --json emits json" ;;
  *) bad "list --json: $out" ;;
esac
case "$out" in
  *real-repo*) bad "list --json must not show non-sandboxes" ;;
  *) ok "list --json hides non-sandboxes" ;;
esac

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
