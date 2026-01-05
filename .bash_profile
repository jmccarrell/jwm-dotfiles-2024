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

# ensure kitty terminal is in my path on OS X
if [ -e '/Applications/kitty.app/Contents/MacOS/kitty' ]; then
    if [ ! -d ~/.local/bin ]; then
        mkdir ~/.local/bin
    fi
    for f in kitty kitten; do
        if [ ! -e ~/.local/bin/$f ]; then
            ln -s /Applications/kitty.app/Contents/MacOS/$f ~/.local/bin
        fi
    done
fi

# Set up fzf key bindings and fuzzy completion
command -v fzf &> /dev/null && eval "$(fzf --bash)"

# set up direnv
# cf: https://direnv.net/docs/hook.html
command -v direnv &> /dev/null && eval "$(direnv hook bash)"

test -e "${HOME}/.iterm2_shell_integration.bash" && \
    ( source "${HOME}/.iterm2_shell_integration.bash" || true )

# add rust/cargo to path
[[ -e ${HOME}/.cargo/env ]] && source ${HOME}/.cargo/env

# setup aws cli to autocomplete
command -v aws &> /dev/null && complete -C aws_completer aws

# set up packer to autocomplete
command -v packer &> /dev/null && complete -C packer packer

# tofu autocomplete
command -v tofu &> /dev/null && complete -C /opt/homebrew/bin/tofu tofu

if command -v asdf > /dev/null; then
    export ASDF_DATA_DIR=${HOME}/.asdf
    export PATH="$ASDF_DATA_DIR/shims:$PATH"
fi

command -v starship &> /dev/null && eval "$(starship init bash)"
command -v zoxide &> /dev/null && eval "$(zoxide init bash)"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :

# Mark43 stuff

# We have to add the zscaler cert so node, and thus claude work
zscaler_cert="${HOME}/ca-cert/ZscalerRootCertificate-2048-SHA256.crt"
if [ -e "${zscaler_cert}" ]; then
    export NODE_EXTRA_CA_CERTS=${zscaler_cert}
fi
