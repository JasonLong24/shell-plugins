# zsh Bookmarks

A zsh plugin that allows the user to make aliases to directories on the fly.

# Install

- Source the script into an alias.
- Create an environment variable called BM_CONFIG that points to your config.sh.

```
alias cdbm="path/to/zshbookmark.sh"
export BM_CONFIG="path/to/config.sh"
```

# Examples

Create an alias

```
cdbm -a ~/Documents docs
```

Remove an alias

```
cdbm -r docs 
or 
cdbm -r ~/Documents
```

Using an alias

```
cdbm docs
cdbm docs:[DIRECTORY] # You can go into child directories.
cdbm -c path/to/.dirbookmarks docs
```
