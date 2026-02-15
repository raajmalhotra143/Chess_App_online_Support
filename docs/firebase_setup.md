# Firebase Setup Guide for Chess App

This guide will help you set up Firebase for the online multiplayer feature.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `chess-app` (or your preferred name)
4. Click **Continue**
5. Disable Google Analytics (optional for this app)
6. Click **Create project**
7. Wait for project to be created, then click **Continue**

---

## Step 2: Add Android App

1. In Firebase Console, click the **Android icon** to add an Android app
2. Enter Android package name: `com.example.myapp` (this MUST match your app's package name)
   - To find your package name, check `android/app/build.gradle` → look for `applicationId`
3. Enter app nickname: **Chess App Android** (optional)
4. Leave SHA-1 blank for now (not needed for Firestore)
5. Click **Register app**
6. Download `google-services.json`
7. Place the file in: `android/app/google-services.json`
8. Click **Next** → **Next** → **Continue to console**

---

## Step 3: Enable Firestore Database

1. In Firebase Console, click **Firestore Database** in the left sidebar
2. Click **Create database**
3. Select **Start in test mode** (we'll add security rules later)
4. Choose a location (e.g., `us-central1`)
5. Click **Enable**

---

## Step 4: Configure Firestore Security Rules

1. Go to **Firestore Database** → **Rules** tab
2. Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write to game rooms
    match /game_rooms/{roomId} {
      allow read, write: if true; // For now, allow all (change in production!)
    }
  }
}
```

3. Click **Publish**

> [!WARNING]
> **These rules allow anyone to read/write!** For production, implement proper authentication and restrict access.

---

## Step 5: Run FlutterFire Configure (Automated Setup)

The easiest way to set up Firebase for all platforms is using FlutterFire CLI:

### Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

### Run Configure Command:
```bash
flutterfire configure --project=chess-app
```

This will:
1. Create `lib/firebase_options.dart`
2. Download and place platform-specific config files
3. Configure iOS, Android, and Web automatically

### Select platforms when prompted:
- ✅ Android
- ✅ iOS (if developing for iOS)
- ✅ Web (if developing for Web)

---

## Step 6: Update Android Build Configuration

1. Open `android/build.gradle` (project-level)
2. Add Google services plugin to `dependencies`:

```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

3. Open `android/app/build.gradle`
4. Add plugin at the **bottom** of the file:

```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## Step 7: Initialize Firebase in App

Update `main.dart` to initialize Firebase:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ChessApp());
}
```

---

## Step 8: Add Camera Permissions (for QR Scanner)

### For Android:
Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <!-- Add inside <manifest> tag -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <application>
        <!-- existing code -->
    </application>
</manifest>
```

### For iOS:
Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera is needed to scan QR codes for joining games</string>
```

---

## Step 9: Test the Setup

1. Run the app: `flutter run`
2. Navigate to **Online Multiplayer** → **Create Room**
3. If Firebase is set up correctly, you should see a room code and QR code
4. Check Firebase Console → Firestore Database → `game_rooms` collection to see the created room

---

## Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"
- Make sure you called `Firebase.initializeApp()` in `main()`
- Verify `firebase_options.dart` exists
- Run `flutterfire configure` again

### Error: "google-services.json not found"
- Verify the file is in `android/app/google-services.json` (not in a subfolder)
- Clean and rebuild: `flutter clean && flutter run`

### QR Scanner not working
- Check camera permissions in AndroidManifest.xml and Info.plist
- On Android, you may need to enable Developer Mode (for symlinks)
- Test on a physical device (emulators may not support camera)

---

## Next Steps

Once Firebase is set up:
1. ✅ Create rooms and share codes
2. ✅ Join rooms via code or QR
3. ⏳ Implement real-time game synchronization (coming next)

For additional help, see [FlutterFire Documentation](https://firebase.flutter.dev/)
