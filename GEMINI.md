# PayMe Project Overview

PayMe is a simple, fast, and minimal Flutter application designed for splitting expenses between two people, **Poom** and **Poy**. The app prioritizes speed, minimal taps, and a modern "fintech" aesthetic.

## 🚀 Technologies
- **Framework:** Flutter (3.41.9+)
- **Language:** Dart
- **State Management:** `provider`
- **Persistence:** `shared_preferences` (local storage)
- **Deployment:**
  - **Android:** Release APK
  - **Web:** GitHub Pages (tppoom.github.io/PayMe/)

## 🏗️ Architecture
The project follows a clean, modular structure:
- `lib/models/`: Data models (e.g., `Entry`).
- `lib/logic/`: Business logic and state management (`ExpenseProvider`).
- `lib/screens/`: High-level page widgets (`HomeScreen`).
- `lib/widgets/`: Reusable UI components (`PayerToggle`, `PercentageSelector`).

## 🎨 Design & Theming
The app supports two primary themes, toggleable via the AppBar:
1.  **Deep Navy Dark Mode (Default):** A professional, high-contrast dark theme with navy backgrounds and blue accents.
2.  **Premium Pink Light Mode:** A sophisticated pink-toned theme using `#E91E63` (Primary) and `#FFF1F6` (Background).

## 🛠️ Key Features
- **Fast Input:** Large numeric field with auto-focus and built-in clear button.
- **Payer Selection:** Full-width segmented control for choosing who paid.
- **Ergonomic Layout:** Action-oriented components (Split % and Add Entry) are placed at the bottom for easy one-handed access.
- **Flexible Splitting:** One-tap 50% and 100% buttons, with others (25, 33, 66, 75) in a "More" dropdown.
- **History Management:**
    - Filter entries by payer (All, Poom, Poy).
    - Edit existing entries (Amount & Percentage).
    - Delete entries via dedicated icons or swipe-to-dismiss.
- **Haptic Feedback:** Tactile vibrations for a premium feel.

## 📦 Building and Running

### Mobile (Android)
```bash
flutter build apk --release
```

### Web
```bash
flutter build web --base-href "/PayMe/" --release --no-tree-shake-icons
```

### Run Locally
```bash
flutter run
```

## 📝 Development Conventions
- **Naming:** Follow standard Dart/Flutter PascalCase for classes and camelCase for variables/methods.
- **Material 3:** Strictly use Material 3 widgets and color schemes.
- **Modern Standards:** Avoid deprecated methods (e.g., use `withValues` instead of `withOpacity`).
- **Icons:** Use `Icons` from the Material set. Ensure `--no-tree-shake-icons` is used for web builds to avoid missing glyphs.
