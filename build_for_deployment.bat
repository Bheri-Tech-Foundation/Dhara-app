@echo off
REM Build Flutter web app for deployment to bheri.in/dhara (Windows)

echo 🏗️  Building Dhara Web App for Production...
echo.
echo 📋 Build Configuration:
echo    - Mode: Release (optimized)
echo    - Base href: /dhara/
echo    - Renderer: Auto (Flutter decides based on device)
echo.

REM Clean previous build
echo 🧹 Cleaning previous build...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build for web
echo 🔨 Building for web...
flutter build web --release --base-href /dhara/

REM Check if build was successful
if %errorlevel% equ 0 (
    echo.
    echo ✅ Build successful!
    echo.
    echo 📂 Build output: build\web\
    echo.
    echo 🚀 Next steps:
    echo    1. cd build\web
    echo    2. vercel --prod
    echo    3. Copy the deployment URL
    echo    4. Configure routing in React app
    echo.
    echo 📖 See DEPLOYMENT_GUIDE.md for detailed instructions
) else (
    echo.
    echo ❌ Build failed! Check the errors above.
    exit /b 1
)





