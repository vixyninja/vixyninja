mkcd() {
  if [[ -z $1 ]]; then
    printf 'Usage: mkcd <directory>\n'
    return 1
  fi
  mkdir -p -- "$1" && cd -- "$1"
}

dlogs() {
  docker compose logs -f "${1:-}"
}

tre() {
  command -v tree >/dev/null 2>&1 && tree -aC --dirsfirst "$@" || ls -lah "$@"
}
