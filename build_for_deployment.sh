#!/bin/bash
# Build Flutter web app for deployment to bheri.in/dhara

echo "🏗️  Building Dhara Web App for Production..."
echo ""
echo "📋 Build Configuration:"
echo "   - Mode: Release (optimized)"
echo "   - Base href: /dhara/"
echo "   - Renderer: Auto (Flutter decides based on device)"
echo ""

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building for web..."
flutter build web --release --base-href /dhara/

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📂 Build output: build/web/"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. cd build/web"
    echo "   2. vercel --prod"
    echo "   3. Copy the deployment URL"
    echo "   4. Configure routing in React app"
    echo ""
    echo "📖 See DEPLOYMENT_GUIDE.md for detailed instructions"
else
    echo ""
    echo "❌ Build failed! Check the errors above."
    exit 1
fi





