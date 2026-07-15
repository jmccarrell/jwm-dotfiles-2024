# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Load shell functions and PATH definitions.
for file in ~/.{functions,path}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;

# set up PATH
jwm_set_path

# Load settings that can rely on the finalized PATH.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{exports,aliases,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;

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

# Add tab completion for many Bash commands.
#   brew install bash-completion@2      (needs bash >= 4.2; we run Homebrew bash 5.x)
#
# v2 lazily sources a completion the first time you TAB a command, rather than
# eagerly sourcing every script at startup the way v1 did.  It searches
# $BASH_COMPLETION_USER_DIR/completions first, so tools that generate their own
# completion script just drop one file named after the command there; see
# jwm_refresh_completions below.  BASH_COMPLETION_COMPAT_DIR keeps any remaining
# v1-style scripts under etc/bash_completion.d working.
#
# Must be exported before bash_completion.sh is sourced: v2 builds its lookup
# path at source time.
export BASH_COMPLETION_USER_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion";

brew_cmd=''
if brew_cmd=$(jwm_brew_cmd 2>/dev/null); then
    bp=''
    bp=$("$brew_cmd" --prefix 2>/dev/null)
    if [ -r "${bp}/etc/profile.d/bash_completion.sh" ]; then
        export BASH_COMPLETION_COMPAT_DIR="${bp}/etc/bash_completion.d";
        source "${bp}/etc/profile.d/bash_completion.sh";
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion;
    fi;
fi;

command -v asdf &> /dev/null && source <(asdf completion bash)

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

# Generate bash completions for CLI tools that emit their own script.
# bash-completion@2 lazily sources $BASH_COMPLETION_USER_DIR/completions/<cmd>
# on the first TAB for <cmd>, so these only need writing once -- not on every
# shell start.  They are generated artifacts and stay out of git; this function
# is the tracked recipe.  Re-run it by hand after a toolchain or tool upgrade:
#
#     jwm_refresh_completions
#
# Deliberately placed after ~/.cargo/env and the asdf/PATH setup above, so the
# `command -v` probes below can actually see rustup, ruff, and friends.
jwm_refresh_completions() {
    local d="${BASH_COMPLETION_USER_DIR}/completions"
    mkdir -p "$d" || return 1

    # `rustup completions bash cargo` emits a shim that sources
    # "$(rustc --print sysroot)"/etc/bash_completion.d/cargo, resolving the
    # sysroot at source time -- so it survives `rustup update` and toolchain
    # switches, where a copied script would go stale.
    if command -v rustup > /dev/null; then
        rustup completions bash          > "$d/rustup"
        rustup completions bash cargo    > "$d/cargo"
    fi
    command -v rg   > /dev/null && rg --generate=complete-bash          > "$d/rg"
    command -v just > /dev/null && just --completions bash              > "$d/just"
    command -v uv   > /dev/null && uv generate-shell-completion bash    > "$d/uv"
    command -v ruff > /dev/null && ruff generate-shell-completion bash  > "$d/ruff"

    printf 'bash completions refreshed in %s\n' "$d"
}

# Bootstrap once on a fresh machine; afterwards refresh explicitly.
[ -d "${BASH_COMPLETION_USER_DIR}/completions" ] || jwm_refresh_completions

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :

# Mark43 stuff
# there is mark43 path stuff in .path as well

# We have to add the zscaler cert so node, and thus claude work
zscaler_cert="${HOME}/ca-cert/ZscalerRootCertificate-2048-SHA256.crt"
if [ -e "${zscaler_cert}" ]; then
    export NODE_EXTRA_CA_CERTS=${zscaler_cert}
fi

# load up the vault config
vault_rc=${HOME}/.vaultrc
if [ -e ${vault_rc} ]; then
    source ${vault_rc}
fi
