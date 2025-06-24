#!/bin/bash

echo "Setting up git hooks..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not a git repository. Run this from the repository root."
    exit 1
fi

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Remove existing pre-push hook if it exists
if [ -f ".git/hooks/pre-push" ]; then
    rm .git/hooks/pre-push
fi

# Create symbolic link to our version-controlled hook
ln -s ../../git-hooks/pre-push .git/hooks/pre-push

# Make sure the hook is executable
chmod +x git-hooks/pre-push

echo "✅ Git hooks set up successfully!"
echo "The pre-push hook will now run ./build.sh before each push." 