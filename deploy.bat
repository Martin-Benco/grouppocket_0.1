@echo off
echo 🚀 Deploying GroupPocket to Firebase...
echo.

echo 📝 Deploying Firestore rules...
firebase deploy --only firestore:rules
if %errorlevel% neq 0 (
    echo ❌ Error deploying Firestore rules
    pause
    exit /b 1
)

echo.
echo 🌐 Deploying hosting...
firebase deploy --only hosting
if %errorlevel% neq 0 (
    echo ❌ Error deploying hosting
    pause
    exit /b 1
)

echo.
echo ✅ Deploy completed successfully!
echo 🌍 Your app is available at: https://grouppocket-402df.web.app
echo.
echo 🧪 Test your app:
echo 1. Open the URL above
echo 2. Try creating a group
echo 3. Add members
echo 4. Split expenses
echo.
pause
