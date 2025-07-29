#!/bin/bash

# QuickTools Release Creation Script
# Usage: ./scripts/create-release.sh 1.0.1

set -e

git pull origin main

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.1"
    exit 1
fi

VERSION="$1"
echo "🚀 Creating release for QuickTools v$VERSION"

# Check if we're in the right directory
if [ ! -f "QuickTools.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Run this script from the QuickTools project root"
    exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Error: You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Update version in AppConstants.swift
echo "📝 Updating version in AppConstants.swift..."
sed -i '' "s/static let appVersion = \"[^\"]*\"/static let appVersion = \"$VERSION\"/" QuickTools/Models/AppConstants.swift

# Update version in Info.plist
echo "📝 Updating version in Info.plist..."
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" QuickTools/Resources/Info.plist

# Generate build number from version (e.g., 1.1.5 -> 115)
echo "📝 Updating build number in Info.plist..."
BUILD_NUMBER=$(echo "$VERSION" | sed 's/\.//g')  # Remove dots: 1.1.5 -> 115
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" QuickTools/Resources/Info.plist
echo "   Version: $VERSION, Build: $BUILD_NUMBER"

# Commit version changes
echo "💾 Committing version changes..."
git add QuickTools/Models/AppConstants.swift QuickTools/Resources/Info.plist
git commit -m "Bump version to $VERSION"

# Create and push tag
echo "🏷️  Creating tag v$VERSION..."
git tag "v$VERSION"
git push origin main
git push origin "v$VERSION"

echo "✅ Release v$VERSION created successfully!"
echo "🔄 GitHub Actions will now build and publish the release automatically."
echo "📱 Check: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions" 