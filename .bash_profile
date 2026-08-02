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
# jwm_refresh_completions in ~/.functions.  BASH_COMPLETION_COMPAT_DIR keeps any
# remaining v1-style scripts under etc/bash_completion.d working.
#
# BASH_COMPLETION_USER_DIR is exported by ~/.functions, sourced at the top of
# this file, because jwm_update_tools needs it and `daily` sources only
# ~/.functions and ~/.path. v2 builds its lookup path at source time, so that
# export has to happen before the bash_completion.sh below -- it does, but the
# two are now in different files, so the invariant is spelled out at both ends.

# HOMEBREW_PREFIX is already exported by the `brew shellenv` that jwm_set_path
# ran above, and holds exactly what `brew --prefix` would print -- so reuse it
# rather than forking brew a third time just to ask again (that fork was 0.04s).
# Unset means no brew, in which case the /etc fallback is the right answer.
if [ -r "${HOMEBREW_PREFIX:-}/etc/profile.d/bash_completion.sh" ]; then
    export BASH_COMPLETION_COMPAT_DIR="${HOMEBREW_PREFIX}/etc/bash_completion.d";
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion;
fi;

# jwm_shell_init (~/.functions) sources a cached copy of each init script rather
# than forking the tool per login shell; see the table there for what each one
# runs and what it costs. Falls back to the live command if the cache is
# unusable, so behaviour is unchanged either way.

command -v mise &> /dev/null && jwm_shell_init mise

# Set up fzf key bindings and fuzzy completion
command -v fzf &> /dev/null && jwm_shell_init fzf

# set up direnv
# cf: https://direnv.net/docs/hook.html
command -v direnv &> /dev/null && jwm_shell_init direnv

# add rust/cargo to path
[[ -e ${HOME}/.cargo/env ]] && source ${HOME}/.cargo/env

# setup aws cli to autocomplete
command -v aws &> /dev/null && complete -C aws_completer aws

# set up packer to autocomplete
command -v packer &> /dev/null && complete -C packer packer

# tofu autocomplete
command -v tofu &> /dev/null && complete -C /opt/homebrew/bin/tofu tofu

command -v starship &> /dev/null && jwm_shell_init starship
command -v zoxide &> /dev/null && jwm_shell_init zoxide

# worktrunk (wt) git-worktree manager.  The sourced script defines a `wt` shell
# function wrapping the binary; without it `wt switch` cannot change this shell's
# cwd.  `command wt` is still required when generating the script -- on a
# re-source the function already exists and a bare `wt` would recurse into it
# instead of reaching the binary -- so that lives in JWM_SHELL_INIT_CMDS.  The
# emitted script registers its own lazy completion, so `wt` is deliberately
# absent from jwm_refresh_completions below.
command -v wt &> /dev/null && jwm_shell_init wt

# jwm_refresh_completions now lives in ~/.functions, next to the shell-init
# cache it is a sibling of, so that jwm_update_tools can call it from `daily`.
#
# The bootstrap call stays here rather than moving with it. The function's
# `command -v` probes run when it is called, not when it is defined, and this is
# the first point in startup where ~/.cargo/env and the PATH setup above have
# actually put rustup, ruff, mise and friends on PATH.
#
# Bootstrap once on a fresh machine; afterwards refresh explicitly, via
# `update` (jwm-bin) or by calling jwm_refresh_completions by hand.
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
