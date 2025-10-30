# Driver Course Monitoring System - Mobile Application

A comprehensive mobile application system to digitize and automate the tracking of driving practice hours and distances for driver training schools.

## Overview

This mobile application replaces paper-based registration with a Bluetooth-enabled pairing system between students and instructors, featuring:

- **Bluetooth pairing** between student and instructor devices during driving sessions
- **Automatic distance tracking** using GPS
- **Real-time progress monitoring** for school administrators
- **Automated data submission** to driver examination systems
- **Digital record-keeping** for compliance and auditing

## Features

### For Students
- View overall progress (distance and classroom hours)
- Real-time session tracking
- Session history with route maps
- Submit feedback and complaints
- Exam eligibility status

### For Instructors
- Pair with students via Bluetooth
- Start/end driving sessions
- Track distance automatically using GPS
- Add session notes
- View session history and statistics

### For School Administrators
- Dashboard with real-time active users
- Manage students and instructors
- View detailed progress reports
- Monitor compliance and feedback
- Export data for exam submissions
- Configure school requirements

## Technology Stack

- **Framework:** Flutter 3.0+
- **Language:** Dart
- **State Management:** Provider
- **Local Database:** SQLite (sqflite)
- **Location Services:** Geolocator
- **Bluetooth:** Flutter Blue Plus
- **Maps:** Google Maps Flutter
- **Authentication:** Secure Storage + Local Auth
- **Push Notifications:** Firebase Cloud Messaging

## Prerequisites

- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- Android Studio / Xcode
- Google Maps API Key
- Firebase project (for notifications)

## Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd driver_mobile
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Google Maps API

#### Android
Edit `android/app/src/main/AndroidManifest.xml` and replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

#### iOS
Edit `ios/Runner/Info.plist` and replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your actual API key:

```xml
<key>GMSApiKey</key>
<string>YOUR_ACTUAL_API_KEY_HERE</string>
```

### 4. Configure Firebase (for push notifications)

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app to Firebase project
3. Download `google-services.json` and place in `android/app/`
4. Add iOS app to Firebase project
5. Download `GoogleService-Info.plist` and place in `ios/Runner/`

### 5. Run the app

```bash
# For development
flutter run

# For release build
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Project Structure

```
lib/
├── core/
│   ├── models/           # Data models
│   │   ├── user_model.dart
│   │   ├── driving_session.dart
│   │   ├── student_progress.dart
│   │   └── feedback_model.dart
│   ├── providers/        # State management
│   │   ├── auth_provider.dart
│   │   ├── session_provider.dart
│   │   ├── bluetooth_provider.dart
│   │   └── location_provider.dart
│   ├── services/         # Core services
│   │   ├── database_service.dart
│   │   └── permission_service.dart
│   ├── theme/           # App theme
│   └── app.dart         # Main app widget
├── features/
│   ├── auth/
│   │   └── screens/
│   │       └── login_screen.dart
│   ├── student/
│   │   └── screens/
│   │       └── student_dashboard.dart
│   ├── instructor/
│   │   └── screens/
│   │       └── instructor_dashboard.dart
│   └── admin/
│       └── screens/
│           └── admin_dashboard.dart
└── main.dart            # Entry point
```

## User Roles

### Super Admin (Backend/Web Portal)
- Creates initial credentials for Driving School Admins
- System-level management

### School Admin (Mobile App)
- Manages instructors and students
- Views real-time dashboard
- Generates reports
- Reviews feedback and complaints
- Configures school requirements

### Instructor (Mobile App)
- Initiates Bluetooth pairing with students
- Starts/ends driving sessions
- Tracks distance via GPS
- Adds session notes
- Views assigned students

### Student (Mobile App)
- Views progress dashboard
- Accepts pairing requests
- Tracks active sessions
- Views session history
- Submits feedback and complaints

## Configuration

### School Requirements (Configurable)
Default requirements can be modified by School Admin:

- Minimum total driving distance: 100 km
- Minimum roadway distance: 70 km
- Minimum practice place distance: 30 km
- Minimum classroom hours: 20 hours

### Session Timeout
- Admin: 30 minutes of inactivity
- Instructor/Student: 4 hours of inactivity

## Permissions

### Android
- Location (Fine & Background)
- Bluetooth (Scan, Connect, Advertise)
- Camera (for attachments)
- Storage (for photos)
- Notifications

### iOS
- Location (When In Use & Always)
- Bluetooth
- Camera
- Photo Library
- Face ID / Touch ID (optional)

## Key Features Implementation

### Bluetooth Pairing
1. Instructor selects student from list
2. Instructor initiates Bluetooth scanning
3. Student device discovered within 10m radius
4. Student accepts pairing request
5. Both devices confirm connection

### GPS Tracking
- Updates every 5 seconds or 10 meters
- Accuracy: ±10 meters
- Continues offline with automatic sync
- Uses Haversine formula for distance calculation

### Offline Capability
- Sessions continue without internet connection
- Data stored locally in SQLite
- Automatic sync when connection restored
- Maximum 48 hours offline operation

### Security
- Password hashing using SHA-256
- Secure storage for credentials
- Role-based access control
- Session timeout management
- Encrypted data at rest and in transit

## Database Schema

### Tables
- `users` - All user types (admin, instructor, student)
- `driving_sessions` - Session records with route data
- `student_progress` - Aggregated progress data
- `feedback` - Instructor ratings and comments
- `complaints` - Student complaints
- `classroom_sessions` - Classroom attendance records

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build for App Store
flutter build ios --release
```

## Troubleshooting

### Bluetooth Issues
- Ensure Bluetooth is enabled on both devices
- Check location permissions (required for Bluetooth scanning on Android)
- Verify devices are within 10 meters

### GPS Accuracy
- Ensure location services are enabled
- Check for clear sky visibility
- Wait for GPS signal to stabilize (15-30 seconds)

### Build Errors
- Run `flutter clean && flutter pub get`
- Check Flutter and Dart versions
- Verify all API keys are configured

## Future Enhancements

- Advanced analytics and predictive insights
- Gamification features
- Instructor scheduling system
- Vehicle management
- Parent portal
- Video recording integration
- AI-powered driving feedback
- Multi-language support
- Payment integration

## Requirements Document

See [REQUIREMENTS.md](REQUIREMENTS.md) for the complete System Requirements Document.

## License

Copyright © 2025 Driver Course Monitoring System. All rights reserved.

## Support

For issues and questions:
- Create an issue in the repository
- Contact: support@driver-monitoring.com

---

**Version:** 1.0.0
**Last Updated:** October 30, 2025
