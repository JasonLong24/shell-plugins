# stagit-gen

A shell script that wraps around [stagit](https://git.2f30.org/stagit/log.html).

See in action [here](http://jasonlong24.crabdance.com/stagit/)

# Usage

```
stagit-gen

Usage: stagit-gen [OPTIONS]... PATH

Options:
  -rp, --repos-path [FILE]    Path to your repos file. Default ./repos
  -s, --style [FILE]          Path to stylesheet. Default ./style.css
  -r, --repo                  Generate static repos based on repos file
  -i, --index                 Generate index file based on repos file.
  -a, --all                   Clear, generate repos and index.
  -c, --clear                 Clear current directory of all repos.
  -h, --help                  Show this screen
Examples:
  stagit-gen --all -s ~/style.css
  stagit-gen --index -rp ~/repos
```

# Cron job

You can create a cron job to update your repos.

`0 0 * * * cd /var/www/html/stagit/ && path/to/gen.sh -a -s path/to/style.css > ~/stagit-gen.log 2>&1`
