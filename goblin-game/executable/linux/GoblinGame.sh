#!/bin/sh
printf '\033c\033]0;%s\a' GoblinGame
base_path="$(dirname "$(realpath "$0")")"
"$base_path/GoblinGame.x86_64" "$@"
