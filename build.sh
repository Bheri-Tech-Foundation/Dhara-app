#!/bin/bash
set -e

echo "Setting up Flutter..."

# Install Flutter if not already installed
if [ ! -d "$HOME/flutter" ]; then
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
fi

# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"

# Verify Flutter installation
flutter doctor

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Regenerate code (Retrofit, JSON serialization, etc.)
echo "Regenerating code with build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

# Build for web
echo "Building Flutter web app..."
flutter build web --release

echo "Build complete!"

