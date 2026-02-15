# Firebase Setup Guide for Chess App

## Prerequisites
✅ Firebase packages are already installed:
- firebase_core
- firebase_auth
- cloud_firestore
- firebase_database

✅ Code is ready - just need Firebase credentials!

## Step-by-Step Setup Instructions

### 1. Create/Access Your Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" (or select an existing one)
3. Enter project name: `app-learning-chess` (or any name you prefer)
4. Follow the setup wizard (you can disable Google Analytics if you want)

### 2. Add Your Flutter App to Firebase

#### For Android:

1. In Firebase Console, click "Add app" → Select **Android** icon
2. Enter the Android package name: `com.example.app_learning`
   - You can find this in `android/app/build.gradle.kts` (look for `applicationId`)
3. Download the `google-services.json` file
4. Place it in: `android/app/google-services.json`
5. Firebase Console will show you gradle modifications - **SKIP THESE** (we'll handle it differently)

#### For Web:

1. In Firebase Console, click "Add app" → Select **Web** icon (</> symbol)
2. Enter app nickname: `Chess App Web`
3. Copy the configuration object that looks like:
```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:..."
};
```

#### For iOS (Optional):

1. Click "Add app" → Select **iOS** icon
2. Enter iOS bundle ID: `com.example.appLearning`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### 3. Update firebase_options.dart

Open `lib/firebase_options.dart` and replace the placeholder values with your actual Firebase credentials:

**For Web:**
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_WEB_API_KEY',
  appId: 'YOUR_ACTUAL_WEB_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
  projectId: 'YOUR_ACTUAL_PROJECT_ID',
  authDomain: 'your-project-id.firebaseapp.com',
  storageBucket: 'your-project-id.appspot.com',
);
```

**For Android:**
- You can extract these from the `google-services.json` file:
  - `apiKey`: Found in `client[0].api_key[0].current_key`
  - `appId`: Found in `client[0].client_info.mobilesdk_app_id`
  - `messagingSenderId`: Found in `project_info.project_number`
  - `projectId`: Found in `project_info.project_id`

### 4. Configure Android Build Files

Add the Google Services plugin to your Android configuration:

**File: `android/build.gradle`**
Add to dependencies:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

**File: `android/app/build.gradle.kts`**
Add at the bottom:
```kotlin
apply plugin: 'com.google.gms.google-services'
```

### 5. Enable Firebase Services (in Firebase Console)

#### Authentication:
1. Go to **Build** → **Authentication** → Click "Get Started"
2. Enable sign-in methods you want:
   - Email/Password
   - Google Sign-In
   - Anonymous

#### Firestore Database:
1. Go to **Build** → **Firestore Database** → Click "Create database"
2. Start in **Test mode** (for development)
3. Select your preferred region

#### Realtime Database (Optional):
1. Go to **Build** → **Realtime Database** → Click "Create database"
2. Start in **Test mode**

### 6. Test the Connection

Run your Flutter app:
```bash
flutter run
```

If Firebase initializes successfully, you won't see any errors. You can add this test code to verify:

```dart
// In any screen, add this to test:
print('Firebase initialized: ${Firebase.apps.isNotEmpty}');
```

## Quick Reference: Where to Find Configuration Values

### From Firebase Console:
1. Open your project
2. Click the ⚙️ (Settings) icon → **Project settings**
3. Scroll down to "Your apps" section
4. Click on your app (Web/Android/iOS)
5. Copy the configuration values

### From google-services.json (Android):
```json
{
  "project_info": {
    "project_number": "123456789", // This is messagingSenderId
    "project_id": "your-project-id"
  },
  "client": [{
    "client_info": {
      "mobilesdk_app_id": "1:123:android:abc" // This is appId
    },
    "api_key": [{
      "current_key": "AIza..." // This is apiKey
    }]
  }]
}
```

## Troubleshooting

**Error: "FirebaseOptions cannot be null"**
→ Make sure you've replaced all `YOUR_*` placeholders in `firebase_options.dart`

**Error: "No Firebase App"**
→ Ensure Firebase.initializeApp() is called in main() before runApp()

**Android build fails**
→ Check that google-services.json is in the correct location (android/app/)

## Next Steps

Once connected, you can:
- Implement user authentication with Firebase Auth
- Store game data in Firestore
- Sync multiplayer games in real-time with Realtime Database
- Track user stats and leaderboards

Need help with any of these? Just ask!
