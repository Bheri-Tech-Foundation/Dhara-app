#!/bin/bash
set -e

echo "Setting up Flutter..."

# Install Flutter pinned to specific version for build consistency
FLUTTER_VERSION="3.29.3"
if [ ! -d "/vercel/flutter" ]; then
  echo "Installing Flutter $FLUTTER_VERSION..."
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" --depth 1 /vercel/flutter
else
  echo "Flutter already installed, ensuring correct version..."
  cd /vercel/flutter
  git fetch --depth 1 origin "$FLUTTER_VERSION"
  git checkout "$FLUTTER_VERSION" 2>/dev/null || true
  cd -
fi

# Add Flutter to PATH
export PATH="$PATH:/vercel/flutter/bin:$HOME/flutter/bin"

# Verify Flutter installation
flutter doctor

# Clean any existing build artifacts
echo "Cleaning build artifacts..."
flutter clean

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Regenerate code (Retrofit, JSON serialization, etc.)
echo "Regenerating code with build_runner..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build for web
echo "Building Flutter web app..."
flutter build web --release

echo "Build complete!"

