#!/bin/zsh

echo "📦 Installing Flutter dependencies..."
flutter pub get

echo ""
echo "🧹 Cleaning build..."
flutter clean

echo ""
echo "📦 Getting dependencies again..."
flutter pub get

echo ""
echo "🔨 Building iOS pods..."
cd ios
pod install
cd ..

echo ""
echo "✅ Setup complete! Now run:"
echo "flutter run -d 00008030-000959420CDA402E"
