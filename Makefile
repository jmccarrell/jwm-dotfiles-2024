INSTALL_DIR := $(HOME)
TEST_DIR := $(HOME)/tmp/test-dotfiles
# relative to our install prefix
DIRENV_CONFIG_DIR := .config/direnv
TEST_DIRENV_CONFIG_DIR := $(TEST_DIR)/$(DIRENV_CONFIG_DIR)
HOME_DIRENV_CONFIG_DIR := $(HOME)/$(DIRENV_CONFIG_DIR)

all: test

install: $(HOME_DIRENV_CONFIG_DIR)
	stow --verbose --ignore=Makefile -t $(INSTALL_DIR) -S .

test: $(TEST_DIR) $(TEST_DIRENV_CONFIG_DIR)
	stow --verbose --ignore=Makefile -t $(TEST_DIR) -S .

.PHONY: clean

clean:
	rm -rf $(TEST_DIR)

$(TEST_DIR) $(TEST_DIRENV_CONFIG_DIR) $(HOME_DIRENV_CONFIG_DIR):
	mkdir -p $@
