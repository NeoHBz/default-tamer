# Default Tamer Makefile
# Builds the macOS application and packages it into a DMG

NAME = DefaultTamer
VERSION := $(shell cat VERSION.txt | tr -d '[:space:]')
PROJECT = $(NAME).xcodeproj
APP_NAME = $(NAME).app
DMG_NAME = $(NAME)-$(VERSION).dmg
BUILD_DIR = ./build
STAGING_DIR = $(BUILD_DIR)/staging

# Colors for output
BLUE = \033[0;34m
GREEN = \033[0;32m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: all project build dmg clean archive help

all: dmg

help:
	@echo "$(BLUE)Default Tamer Build System$(NC)"
	@echo "Available targets:"
	@echo "  $(GREEN)make project$(NC) - Generate Xcode project using xcodegen"
	@echo "  $(GREEN)make build$(NC)   - Build the app in Release mode"
	@echo "  $(GREEN)make dmg$(NC)     - Create the DMG installer (default)"
	@echo "  $(GREEN)make clean$(NC)   - Remove build artifacts and generated project"

project:
	@echo "$(BLUE)🛠 Generating Xcode project...$(NC)"
	@VERSION=$(VERSION) BUILD_NUMBER=$(shell git rev-list --count HEAD 2>/dev/null || echo 1) xcodegen generate || (echo "$(RED)❌ xcodegen not found. Please install it with 'brew install xcodegen'$(NC)"; exit 1)

build: project
	@echo "$(BLUE)🏗 Building $(NAME) v$(VERSION) in Release mode...$(NC)"
	@mkdir -p $(BUILD_DIR)
	@xcodebuild -project $(PROJECT) \
		-scheme $(NAME) \
		-configuration Release \
		-derivedDataPath $(BUILD_DIR)/DerivedData \
		CODE_SIGNING_ALLOWED=NO \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGN_IDENTITY="" \
		build
	@echo "$(GREEN)✅ Build successful.$(NC)"

archive: build
	@echo "$(BLUE)📦 Preparing staging directory...$(NC)"
	@rm -rf $(STAGING_DIR)
	@mkdir -p $(STAGING_DIR)
	@cp -R $(BUILD_DIR)/DerivedData/Build/Products/Release/$(APP_NAME) $(STAGING_DIR)/
	@ln -s /Applications $(STAGING_DIR)/Applications
	@echo "$(GREEN)✅ Staging complete.$(NC)"

dmg: archive
	@echo "$(BLUE)💿 Creating DMG...$(NC)"
	@rm -f $(DMG_NAME)
	@hdiutil create -volname "$(NAME) $(VERSION)" -srcfolder $(STAGING_DIR) -ov -format UDZO $(DMG_NAME)
	@echo "$(GREEN)🚀 DMG created: $(DMG_NAME)$(NC)"

clean:
	@echo "$(BLUE)🧹 Cleaning up...$(NC)"
	@rm -rf $(BUILD_DIR)
	@rm -f $(DMG_NAME)
	@rm -rf $(PROJECT)
	@echo "$(GREEN)✨ Done.$(NC)"
