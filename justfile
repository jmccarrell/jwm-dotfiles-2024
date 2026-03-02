set dotenv-load

home_dir := env("HOME")
test_dir := home_dir / "tmp/test-dotfiles"

@_:
    just --list

# stow a package into a target directory, creating it if needed
[private]
stow-pkg target pkg *ignore:
    mkdir -p {{target}}
    stow --verbose --adopt {{ignore}} -t {{target}} -S {{pkg}}

# Install all dotfiles
install: (stow-pkg home_dir "." "--ignore=justfile --ignore=kitty --ignore=claude") (stow-pkg (home_dir / ".config/kitty") "kitty") (stow-pkg (home_dir / ".claude") "claude")

# Test install into temp directory
test: (stow-pkg test_dir "." "--ignore=justfile --ignore=kitty --ignore=claude") (stow-pkg (test_dir / ".config/kitty") "kitty") (stow-pkg (test_dir / ".claude") "claude")

# Clean test directory
clean:
    rm -rf {{test_dir}}
