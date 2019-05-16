#!/bin/zsh

ZSH_PLUG_ROOT="."
PLUG_PATH="."

# Source base tools
source $ZSH_PLUG_ROOT/src/base/*.zsh

# Source functions
source $ZSH_PLUG_ROOT/src/functions/*.zsh

"$@"
