#!/bin/zsh

ZSH_PLUG_ROOT="."
PLUG_PATH="./plugs"

# Source base tools
for base in $ZSH_PLUG_ROOT/src/base/*.zsh; do
    source "$base"
done

# Source functions
for function in $ZSH_PLUG_ROOT/src/functions/*.zsh; do
    source "$function"
done

"$@"
