@echo off
REM Dhara Flutter App Deployment Script for Windows
REM Deploys to www.bheri.in/dhara

echo.
echo ====================================
echo   Deploying Dhara Flutter App
echo ====================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter not found. Please install Flutter first.
    pause
    exit /b 1
)

REM Check if Vercel CLI is installed
where vercel >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Vercel CLI not found. Installing...
    call npm install -g vercel
)

REM Clean previous build
echo Cleaning previous build...
if exist "build\web" (
    rmdir /s /q "build\web"
)

REM Build Flutter app
echo.
echo Building Flutter web app...
echo Using --base-href /dhara/
echo.
call flutter clean
call flutter pub get
call flutter build web --release --base-href /dhara/

REM Check if build was successful
if not exist "build\web" (
    echo ERROR: Build failed! build\web directory not found.
    pause
    exit /b 1
)

echo Build successful!
echo.

REM Copy vercel.json to build directory
echo Copying configuration...
copy vercel.json build\web\

REM Navigate to build directory
cd build\web

REM Deploy to Vercel
echo.
echo Deploying to Vercel...
echo This will take a moment...
echo.

call vercel --prod

REM Success message
echo.
echo ====================================
echo   Deployment Complete!
echo ====================================
echo.
echo Your app should be available at:
echo   https://www.bheri.in/dhara
echo.
echo IMPORTANT: If this is your first deployment:
echo   1. Note the Vercel deployment URL shown above
echo   2. Update your React app's vercel.json with this URL
echo   3. Redeploy your React app
echo.
echo See DEPLOYMENT_VERCEL_SETUP.md for detailed instructions
echo.

pause

