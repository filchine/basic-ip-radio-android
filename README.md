# Basic IP Radio App

A basic Android radio station management app built with Flutter.

##  Features
*   **Material 3 UI**: Modern and clean interface with dynamic light/dark themes.
*   **Background Playback**: Audio streaming that continues even when the app is in the background or the screen is off.
*   **Station Management**: Easily add, edit, or remove your favorite IP radio stations.
*   **Persistence**: Your custom station list and preferences are saved locally on your device using SQLi.
*   **Smart Reordering**: Organize your station list with intuitive drag-and-drop support.

##  Getting Started

### Prerequisites
*   Flutter SDK
*   Android Studio / VS Code
*   An Android device or emulator

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/filchine/basic-ip-radio-android.git
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```

##  Built With
*   [just_audio](https://pub.dev/packages/just_audio) - Audio playback
*   [audio_service](https://pub.dev/packages/audio_service) - Background audio support
*   [sqflite](https://pub.dev/packages/sqflite) - SQLite database
*   [provider](https://pub.dev/packages/provider) - State management
*   [cached_network_image](https://pub.dev/packages/cached_network_image) - Image caching
