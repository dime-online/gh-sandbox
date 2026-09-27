# bash completion for gh-sandbox (also covers `gh sandbox` via gh's own completion)
_gh_sandbox() {
  local cur prev
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "create list destroy help" -- "$cur") )
  elif [ "$prev" = "--template" ]; then
    COMPREPLY=( $(compgen -W "--public --description --yes" -- "$cur") )
  fi
}
complete -F _gh_sandbox gh-sandbox
