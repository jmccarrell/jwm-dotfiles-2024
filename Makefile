INSTALL_DIR := $(HOME)
TEST_DIR := $(HOME)/tmp/test-dotfiles
# relative to our install prefix
DIRENV_CONFIG_DIR := .config/direnv
TEST_DIRENV_CONFIG_DIR := $(TEST_DIR)/$(DIRENV_CONFIG_DIR)
HOME_DIRENV_CONFIG_DIR := $(HOME)/$(DIRENV_CONFIG_DIR)
KITTY_CONFIG_DIR := .config/kitty
KITTY_TEST_DIR := $(TEST_DIR)/$(KITTY_CONFIG_DIR)
KITTY_HOME_DIR := $(HOME)/$(KITTY_CONFIG_DIR)

all: test

install: $(HOME_DIRENV_CONFIG_DIR) install-kitty
	stow --verbose --ignore=Makefile -t $(INSTALL_DIR) -S .

install-kitty: $(KITTY_HOME_DIR)
	stow --verbose -t $(KITTY_HOME_DIR) -S kitty

test: $(TEST_DIR) $(TEST_DIRENV_CONFIG_DIR) test-kitty
	stow --verbose --ignore=Makefile -t $(TEST_DIR) -S .

test-kitty: $(KITTY_TEST_DIR)
	stow --verbose -t $(KITTY_TEST_DIR) -S kitty

.PHONY: clean

clean:
	rm -rf $(TEST_DIR)

$(TEST_DIR) $(TEST_DIRENV_CONFIG_DIR) $(HOME_DIRENV_CONFIG_DIR) $(KITTY_TEST_DIR) $(KITTY_HOME_DIR):
	mkdir -p $@
