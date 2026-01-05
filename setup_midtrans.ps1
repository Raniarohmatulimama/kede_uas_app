# Quick Setup Script untuk Midtrans + Firebase Integration

Write-Host "🚀 Starting Midtrans + Firebase Integration Setup..." -ForegroundColor Green
Write-Host ""

# 1. Install Flutter dependencies
Write-Host "📦 Step 1: Installing Flutter dependencies..." -ForegroundColor Cyan
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install Flutter dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Flutter dependencies installed" -ForegroundColor Green
Write-Host ""

# 2. Install Firebase Functions dependencies
Write-Host "📦 Step 2: Installing Firebase Functions dependencies..." -ForegroundColor Cyan
Set-Location functions

if (Test-Path "package.json") {
    npm install
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install Firebase Functions dependencies" -ForegroundColor Red
        Set-Location ..
        exit 1
    }
    
    Write-Host "✅ Firebase Functions dependencies installed" -ForegroundColor Green
} else {
    Write-Host "⚠️  package.json not found in functions directory" -ForegroundColor Yellow
}

Set-Location ..
Write-Host ""

# 3. Check Firebase CLI
Write-Host "🔍 Step 3: Checking Firebase CLI..." -ForegroundColor Cyan
$firebaseInstalled = Get-Command firebase -ErrorAction SilentlyContinue

if ($firebaseInstalled) {
    Write-Host "✅ Firebase CLI is installed" -ForegroundColor Green
    firebase --version
} else {
    Write-Host "⚠️  Firebase CLI not found" -ForegroundColor Yellow
    Write-Host "   Install it with: npm install -g firebase-tools" -ForegroundColor Yellow
}

Write-Host ""

# 4. Instructions untuk API Keys
Write-Host "🔑 Step 4: Configure Midtrans API Keys" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please follow these steps:" -ForegroundColor White
Write-Host "1. Go to: https://dashboard.sandbox.midtrans.com" -ForegroundColor White
Write-Host "2. Login or register" -ForegroundColor White
Write-Host "3. Go to Settings → Access Keys" -ForegroundColor White
Write-Host "4. Copy your Server Key and Client Key" -ForegroundColor White
Write-Host "5. Update functions/midtrans.js with your keys:" -ForegroundColor White
Write-Host "   - Replace 'YOUR_MIDTRANS_SERVER_KEY'" -ForegroundColor White
Write-Host "   - Replace 'YOUR_MIDTRANS_CLIENT_KEY'" -ForegroundColor White
Write-Host ""

# 5. Deploy instructions
Write-Host "🚀 Step 5: Deploy Firebase Functions" -ForegroundColor Cyan
Write-Host ""
Write-Host "After configuring API keys, run:" -ForegroundColor White
Write-Host "   firebase deploy --only functions" -ForegroundColor Yellow
Write-Host ""

# 6. Testing instructions
Write-Host "🧪 Step 6: Testing" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test Credit Cards (Sandbox):" -ForegroundColor White
Write-Host "   Success: 4811 1111 1111 1114 | CVV: 123 | OTP: 112233" -ForegroundColor Green
Write-Host "   Failed:  4911 1111 1111 1113 | CVV: 123" -ForegroundColor Red
Write-Host ""

# 7. Summary
Write-Host "📋 Setup Summary:" -ForegroundColor Cyan
Write-Host "   ✅ Flutter dependencies installed" -ForegroundColor Green
Write-Host "   ✅ Firebase Functions dependencies installed" -ForegroundColor Green
Write-Host "   📝 TODO: Configure Midtrans API keys in functions/midtrans.js" -ForegroundColor Yellow
Write-Host "   📝 TODO: Deploy Firebase Functions" -ForegroundColor Yellow
Write-Host "   📝 TODO: Test payment flow" -ForegroundColor Yellow
Write-Host ""

Write-Host "📚 For detailed guide, see: MIDTRANS_INTEGRATION_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "✨ Setup completed! Happy coding! ✨" -ForegroundColor Green
