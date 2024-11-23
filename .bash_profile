# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{functions,path,bash_prompt,exports,aliases,extra}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;

# set up PATH
jwm_set_path

# load jeffs sh functions
for file in ~/lib/git-sync.sh; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;

if which brew &> /dev/null; then
    for file in ~/.iterm2_shell_integration.bash; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
    done;
fi

unset file;

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
if which brew &> /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
        source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion;
fi;

# jwm: I don't use the g alias
# Enable tab completion for `g` by marking it as an alias for `git`
# if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
#       complete -o default -o nospace -F _git g;
# fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

if which brew &> /dev/null; then
    # Add tab completion for `defaults read|write NSGlobalDomain`
    # You could just use `-g` instead, but I like being explicit
    complete -W "NSGlobalDomain" defaults;

    # Add `killall` tab completion for common apps
    complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;
fi;

# prefer direnv when I get to wanting per-directory state
#  it is preferred by KReitz and has direct emacs support.
# jwm: add support for autoenv by Kenneth Reitz
# if which brew &> /dev/null && $(brew --prefix autoenv > /dev/null 2>&1); then
#     source $(brew --prefix autoenv)/activate.sh;
# fi;

# setup rbenv when appropriate
if [ -d "$HOME/.rbenv" ]; then
  export RBENV_SHELL=bash
  source $(brew --prefix rbenv)/completions/rbenv.bash
  command rbenv rehash 2>/dev/null
  rbenv() {
    local command
    command="$1"
    if [ "$#" -gt 0 ]; then
      shift
    fi

    case "$command" in
    rehash|shell)
      eval "$(rbenv "sh-$command" "$@")";;
    *)
      command rbenv "$command" "$@";;
    esac
  }
fi

# setup rvm when installed
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

if which starship &> /dev/null; then
    case "$SHELL" in
    *bash)
        eval "$(starship init bash)";;
    *zsh)
        eval "$(starship init zsh)";;
    esac
fi

# set up direnv
# cf: https://direnv.net/docs/hook.html
eval "$(direnv hook bash)"
