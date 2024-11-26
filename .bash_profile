# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{functions,path,exports,aliases,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;

# set up PATH
jwm_set_path

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
# based on prior installation of bash-completion (not bash-completion@2)
# brew install bash-completion
if command -v brew &> /dev/null; then
    bp=''
    bp=$(brew --prefix)
    if [ -r "${bp}/etc/profile.d/bash_completion.sh" ]; then
        # Ensure existing Homebrew v1 completions continue to work
        export BASH_COMPLETION_COMPAT_DIR="${bp}/etc/bash_completion.d";
        source "${bp}/etc/profile.d/bash_completion.sh";
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion;
    fi;
fi;

if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# set up direnv
# cf: https://direnv.net/docs/hook.html
command -v direnv &> /dev/null && eval "$(direnv hook bash)"

test -e "${HOME}/.iterm2_shell_integration.bash" && \
    ( source "${HOME}/.iterm2_shell_integration.bash" || true )
