.PHONY: pull push setup install-commands uninstall-commands

pull:
	./utilities/pull.sh

push:
	./utilities/push.sh

setup:
	./utilities/setup.sh

install-commands:
	./utilities/install_commands.sh

uninstall-commands:
	./utilities/uninstall_commands.sh

help:
	@echo "Usage: make <target>"
	@echo "Targets:"
	@echo "  pull - Pull configuration files from the machine"
	@echo "  push - Push configuration files to the machine"
	@echo "  setup - Setup the machine with the configuration files"
	@echo "  install-commands - Install the dotfiles commands"
	@echo "  uninstall-commands - Uninstall the dotfiles commands"
	@echo "  help - Show this help message"