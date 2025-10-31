#!/bin/bash

# Driver Mobile App - Setup Script
# This script generates missing platform files and configures the project

echo "🚀 Setting up Driver Mobile App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"

# Generate missing platform files
echo ""
echo "📱 Generating iOS and Android platform files..."
flutter create . --org com.driverschool --platforms=ios,android

# Check if generation was successful
if [ ! -d "ios/Runner.xcodeproj" ]; then
    echo "❌ Failed to generate iOS project files"
    exit 1
fi

echo "✅ Platform files generated successfully"

# Clean and get dependencies
echo ""
echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "✅ Setup complete!"
echo ""
echo "⚠️  IMPORTANT: Before running the app, you need to:"
echo ""
echo "1. Add Google Maps API Key:"
echo "   - Android: android/app/src/main/AndroidManifest.xml"
echo "   - iOS: ios/Runner/Info.plist"
echo ""
echo "2. Configure Firebase (optional for notifications):"
echo "   - Run: flutterfire configure"
echo "   - Or manually add google-services.json and GoogleService-Info.plist"
echo ""
echo "3. Restore custom configurations in Info.plist and AndroidManifest.xml"
echo "   - Check git diff to see what changed"
echo ""
echo "To run the app:"
echo "  flutter run"
echo ""
echo "To check your setup:"
echo "  flutter doctor"
echo ""
