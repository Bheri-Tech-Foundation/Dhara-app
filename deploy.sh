#!/bin/bash

# Dhara Flutter App Deployment Script
# Deploys to www.bheri.in/dhara

set -e  # Exit on error

echo "🚀 Deploying Dhara Flutter App"
echo "================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "⚠️  Vercel CLI not found. Installing..."
    npm install -g vercel
fi

# Clean previous build
echo "🧹 Cleaning previous build..."
if [ -d "build/web" ]; then
    rm -rf build/web
fi

# Build Flutter app
echo ""
echo "🔨 Building Flutter web app..."
echo "   Using --base-href /dhara/"
flutter clean
flutter pub get
flutter build web --release --base-href /dhara/

# Check if build was successful
if [ ! -d "build/web" ]; then
    echo "❌ Build failed! build/web directory not found."
    exit 1
fi

echo "✅ Build successful!"
echo ""

# Copy vercel.json to build directory
echo "📋 Copying configuration..."
cp vercel.json build/web/

# Navigate to build directory
cd build/web

# Deploy to Vercel
echo ""
echo "📦 Deploying to Vercel..."
echo "   This will take a moment..."
echo ""

vercel --prod

# Get deployment URL (optional - for display)
echo ""
echo "✅ Deployment complete!"
echo ""
echo "🌐 Your app should be available at:"
echo "   https://www.bheri.in/dhara"
echo ""
echo "⚠️  IMPORTANT: If this is your first deployment:"
echo "   1. Note the Vercel deployment URL shown above"
echo "   2. Update your React app's vercel.json with this URL"
echo "   3. Redeploy your React app"
echo ""
echo "📚 See DEPLOYMENT_VERCEL_SETUP.md for detailed instructions"
echo ""

