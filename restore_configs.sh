#!/bin/bash

# Restore custom configurations after flutter create

echo "🔧 Restoring custom configurations..."

# Restore iOS Info.plist
if [ -f "ios/Runner/Info.plist.backup" ]; then
    cp ios/Runner/Info.plist.backup ios/Runner/Info.plist
    echo "✅ Restored iOS Info.plist"
else
    echo "⚠️  Backup not found: ios/Runner/Info.plist.backup"
fi

# Restore Android Manifest
if [ -f "android/app/src/main/AndroidManifest.xml.backup" ]; then
    cp android/app/src/main/AndroidManifest.xml.backup android/app/src/main/AndroidManifest.xml
    echo "✅ Restored Android Manifest"
else
    echo "⚠️  Backup not found: android/app/src/main/AndroidManifest.xml.backup"
fi

echo ""
echo "✅ Configuration restore complete!"
