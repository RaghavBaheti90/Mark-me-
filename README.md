# QR Attendance App

A Flutter application for managing classroom attendance using QR codes and Firebase.

## Features

- **User Authentication:** Sign up and log in securely with Firebase Auth.
- **Generate QR Codes:** Teachers can create attendance sessions and generate QR codes for students to scan.
- **Scan QR Codes:** Students scan the QR code to mark their attendance.
- **Attendance Tracking:** Teachers can view attendance sessions and see which students attended.
- **Profile Management:** Users can view and edit their profile information.
- **Class Management:** Create and manage classes (for teachers).

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase Project](https://console.firebase.google.com/)
- Android Studio or VS Code

### Installation

1. **Clone the repository:**

   ```sh
   git clone <your-repo-url>
   cd qr_attendence_app
   ```

2. **Install dependencies:**

   ```sh
   flutter pub get
   ```

3. **Firebase Setup:**

   - Replace the `firebase_options.dart` file with your own (generated via [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)).
   - Make sure your Firebase project has Authentication and Firestore enabled.

4. **Run the app:**
   ```sh
   flutter run
   ```

## Project Structure

- `lib/main.dart` - App entry point and route setup.
- `lib/pages/` - All main screens (login, signup, home, QR generation, scanning, profile, etc.).
- `lib/components/` - Reusable UI components.
- `lib/firebase_options.dart` - Firebase configuration.

## Dependencies

- `firebase_auth`
- `firebase_core`
- `cloud_firestore`
- `qr_flutter`
- `qr_code_scanner`
- `share_plus`
- `intl`
- `uuid`

See [`pubspec.yaml`](pubspec.yaml) for full list.

## Usage

- **Teachers:**

  1. Log in or sign up.
  2. Create a class and generate a QR code for each session.
  3. Share the QR code with students.

- **Students:**
  1. Log in or sign up.
  2. Scan the QR code provided by the teacher to mark attendance.

## License

This project is for educational purposes.

---

**Made with Flutter & Firebase**
