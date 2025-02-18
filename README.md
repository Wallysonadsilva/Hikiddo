# 📱 HiKiddo! - Family Bonding App

## 📝 Project Overview
HiKiddo! is a mobile app developed as a final year project for a Computer Science degree, designed to strengthen family bonds and address issues arising from physical disconnection between parents and children. 

The name "HiKiddo" was inspired by "Aikido," a Japanese self-defence martial art.
Blends "Hi," a common greeting, with "Kiddo," a friendly term for children. 
Reflects the app's goal of protecting and strengthening family bonds.

## ✨ **Features**
- 🖼️ **Shared Memory Board**: Add and share photos, videos, and meaningful voice recordings.
- 🎮 **Weekly Challenges**: Complete engaging tasks to earn rewards and points.
- 💗 **Emotional Support**: Enhance emotional connections and meet the developmental needs of children.
- 🔑 Firebase Authentication (Email Verification, Login, Registration)
- 📱 Cross-platform support

## 🎯 Project Goals
- Assist parents in being more attentive and responsive to their children's needs.
- Strengthen familial ties through the use of modern technology.
- Provide a secure and engaging platform for families to stay connected.
- Encourage meaningful interactions and create shared experiences.

## 🛠️ Stack
- **Flutter**
- **Firebase**
- **Google Maps Platform** 

## 📂 Folder Structure
Here's how the project is structured for scalability and maintainability:

```plaintext
lib/
├── components/             # Reusable UI components (buttons, cards, inputs)
├── models/                 # Data models for the app
├── screens/                # UI and logic for individual screens
├── services/               # API service logic (auth, Database)
├── constants.dart          # Constants (colors)
├── firebase_options.dart   # Firebase configuration (auto-generated)
├── loading.dart            # Loading screen
├── main.dart               # App entry point
├── utils.dart              # Utility functions for reusability
├── verification_email.dart # UI for email verification
```

## **📦 Dependencies**
### You can find the dependencies list in [pubspec.yaml](https://github.com/Wallysonadsilva/Hikiddo/blob/main/hikiddo/pubspec.yaml)

## **Prerequisites**
Before running the app, make sure you have the following:
- ✅ [Flutter SDK](https://docs.flutter.dev/get-started/install) installed  
- ✅ [Firebase project setup](https://firebase.google.com/docs/flutter/setup)
- ✅ Android Studio / Xcode  
- ✅ A preferred IDE (used - **VS Code**)

## 🚀 Installation Steps
Follow these steps to set up and run the project on your local machine:

1️⃣ Clone the repository:
```bash
git clone https://github.com/Wallysonadsilva/Hikiddo.git
cd hikiddo
```
2️⃣ Install the dependencies:
```bash
flutter pub get
```

3️⃣ Add Firebase Configuration:
- Create a Firebase project.
- Download your google-services.json file and place it in the android/app folder (for Android).
- Download your GoogleService-Info.plist file and place it in the ios/Runner folder (for iOS).

4️⃣ Add Google Maps API Key:
- Go to the [Google Cloud Console](https://console.cloud.google.com/).
- Enable the Google Maps API and create a new API key.
- Add the API key to your AndroidManifest.xml and AppDelegate.swift files:

Android: Add the key under <application> in android/app/src/main/AndroidManifest.xml:
```
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="API_KEY" />
```
iOS: Add the key in ios/Runner/AppDelegate.swift:
```
GMSServices.provideAPIKey("API_KEY")
```

5️⃣ Run the app:
```bash
flutter run
```

## Preview
<div>
    <img src="Preview%20Imgs/IMG_0894.PNG" width="20%" style="display: inline-block;">
    <img src="Preview%20Imgs/IMG_0895.PNG" width="20%" style="display: inline-block;">
    <img src="Preview%20Imgs/IMG_0896.PNG" width="20%" style="display: inline-block;">
    <img src="Preview%20Imgs/IMG_0897.PNG" width="20%" style="display: inline-block;">
</div>

More screenshots under the [Preview Imgs](https://github.com/Wallysonadsilva/Hikiddo/tree/main/Preview%20Imgs) folder

#### Quick Demo video [Link](https://www.canva.com/design/DAGfaPKbtuQ/sqIT7QeGrAkXJBKMDpuGLg/edit?utm_content=DAGfaPKbtuQ&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton) 🔗

