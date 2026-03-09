#!/usr/bin/env bash

# Run this script to configure the git hooks for this project

echo "Setting up git hooks..."
git config core.hooksPath .git-hooks
echo "Git hooks configured successfully!"
