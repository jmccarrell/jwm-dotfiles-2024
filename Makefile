INSTALL_DIR := $(HOME)
TEST_DIR := $(HOME)/tmp/test-dotfiles

all: test

install: $(INSTALL_DIR)
	stow --verbose --ignore=Makefile -t $(INSTALL_DIR) -S .

test: $(TEST_DIR)
	stow --verbose --ignore=Makefile -t $(TEST_DIR) -S .

.PHONY: clean

clean:
	rm -rf $(TEST_DIR)


$(TEST_DIR):
	mkdir $(TEST_DIR)
