# zsh Bookmarks

A zsh plugin that allows the user to make aliases to directories on the fly.

## Install

- Source the script into an alias.
- Create an environment variable called BM_CONFIG that points to your config.sh.

```
alias cdbm="path/to/zshbookmark.sh"
export BM_CONFIG="path/to/config.sh"
```

## Examples

Create an alias

```
cdbm dir -a ~/Documents docs
```

Remove an alias

```
cdbm dir -r docs
or
cdbm dir -r ~/Documents
```

Using an alias

```
cdbm dir docs
cdbm dir docs:[DIRECTORY] # You can go into child directories.
cdbm dir -c path/to/.dirbookmarks docs
```
## FZF

Bookmarks can be used with [fzf](https://github.com/junegunn/fzf)

```
cdbm dir --fzf-bm
```

## zshrc

In your zshrc you might want to put something like this.

```
alias d="cdbm -c $HOME/zsh./dirbookmarks dir"
alias f="cdbm -c $HOME/zsh/.filebookmarks file"
```

You can also add keybindings for fzf search.

```
bindkey -s '^e' 'f -f\n'
bindkey -s '^h' 'd -f\n'
```

