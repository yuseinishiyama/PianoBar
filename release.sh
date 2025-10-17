#!/bin/bash

# Release script - ensures consistent version tag format
# Usage: ./release.sh X.Y.Z

VERSION=$1

# Check if version was provided
if [ -z "$VERSION" ]; then
    echo "Usage: ./release.sh X.Y.Z"
    echo "Example: ./release.sh 0.0.3"
    exit 1
fi

# Validate version format (X.Y.Z)
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 0.0.3)"
    exit 1
fi

# Create and push tag
echo "Creating release v$VERSION..."
git tag "v$VERSION" -m "v$VERSION"

if [ $? -eq 0 ]; then
    git push origin "v$VERSION"
    if [ $? -eq 0 ]; then
        echo "✓ Successfully released v$VERSION"
        echo "GitHub Actions will now build and create the release."
    else
        echo "Failed to push tag. You may need to push manually:"
        echo "  git push origin v$VERSION"
    fi
else
    echo "Failed to create tag"
    exit 1
fi