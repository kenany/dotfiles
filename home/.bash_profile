# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

for file in ~/.{path,bash_prompt,exports,aliases,functions}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file";
done
unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS
shopt -s checkwinsize;

# Save all lines of a multiple-line command in the same history entry (allows
# easy re-editing of multi-line commands)
shopt -s cmdhist;

# Do not autocomplete when accidentally pressing Tab on an empty line. (It takes
# forever and yields "Display all 15 gazillion possibilites?")
shopt -s no_empty_cmd_completion;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2> /dev/null;
done;

# base16 shell
BASE16_SHELL="$HOME/.config/base16-shell/scripts/base16-brewer.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Start X
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx;

source ~/bin/z/z.sh;

# Fortune
echo -e "\e[00;33m$(fortune -n 140 | cowsay -f tux)\e[00m";
