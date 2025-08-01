
# List of available projects
PROJECTS := client

# Folders to keep during web server cleanup
FOLDER_TO_KEEP := .well-known cgi-bin

# Internal variables
BASE_FOLDER := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
WEB_BUILD_FOLDER := build/web

# Make targets
.PHONY: all list $(PROJECTS)

all: list

list:
	@echo "Available projects:"
	@for project in $(PROJECTS); do \
		echo "  - $$project"; \
	done

client:
	@echo "Building CLIENT project..."; \
	PROJECT_FOLDER=$(BASE_FOLDER); \
	# Make sure the authentication are provided (SSH_USER, SSH_SERVER, SSH_FOLDER_CLIENT) \
	if [ -z "$${SSH_USER}" ] || [ -z "$${SSH_SERVER}" ] || [ -z "$${SSH_FOLDER_CLIENT}" ]; then \
		echo "ERROR -- SSH_USER, SSH_SERVER, or SSH_FOLDER_CLIENT is not set. Please set them before building."; \
		exit 1; \
	fi; \
	cd $${PROJECT_FOLDER}; \
	flutter clean; \
	flutter pub get; \
	flutter build web --release; \
	cd $(BASE_FOLDER); \
	ssh $${SSH_USER}@$${SSH_SERVER} "cd $${SSH_FOLDER_CLIENT} && find . $(addprefix ! -name ,$(FOLDER_TO_KEEP)) -delete"; \
	rsync -azvP $${PROJECT_FOLDER}/$(WEB_BUILD_FOLDER)/ $${SSH_USER}@$${SSH_SERVER}:$${SSH_FOLDER_CLIENT}; \
	echo "Project built and sent successfully."
