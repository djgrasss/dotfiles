#!/usr/bin/env bash

[[ -z "$1" ]] || [[ ! -d "$1" ]] && {
  echo "Usage: $0 project_dir" >&2
  exit 1
}

PROJDIR=$(realpath "$1")
export PROJDIR
cd "$PROJDIR" || exit 1
ctags -aR ./
vim -c ":NERDTree $PROJDIR" 

