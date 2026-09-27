# bash completion for gh-sandbox (also covers `gh sandbox` via gh's own completion)
_gh_sandbox() {
  local cur prev names
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "create list open rename destroy help" -- "$cur") )
  elif [ "$prev" = "destroy" ] || [ "$prev" = "open" ] || [ "$prev" = "rename" ]; then
    names=$(gh repo list --limit 1000 --json name \
              --jq '.[] | select(.name | startswith("sandbox-")) | .name' 2>/dev/null)
    COMPREPLY=( $(compgen -W "$names" -- "$cur") )
  elif [ "$prev" = "--template" ]; then
    COMPREPLY=( $(compgen -W "--public --clone --add-readme --description --yes" -- "$cur") )
  fi
}
complete -F _gh_sandbox gh-sandbox
