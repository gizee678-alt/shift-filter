# 📅 Shift Filter — Offline Roster OCR App

A fully offline Android app that scans Excel roster screenshots via OCR and filters employees by day and shift.

---

## ✨ Features

| Feature | Details |
|---------|---------|
| 📷 Image Input | Camera capture + gallery picker |
| 🔍 OCR Engine | Google ML Kit (on-device, offline) |
| 🗂️ Roster Parsing | Detects employees, days, and shift values |
| 🔎 Smart Filter | Filter by day + shift type instantly |
| 🔍 Search | Search employees by name |
| 🌙 Dark Mode | Full dark/light theme toggle |
| 👥 Employee Count | Total + filtered count shown |
| ✈️ 100% Offline | No internet, no backend, no login |

---

## 🕐 Supported Shifts

| Shift Code | Time | Type |
|-----------|------|------|
| `0730-1730` | 7:30 AM – 5:30 PM | Morning |
| `1230-2230` | 12:30 PM – 10:30 PM | Afternoon |
| `2200-0800` | 10:00 PM – 8:00 AM | Night |
| `RDO` | Rest Day Off | Day Off |

---

## 🚀 Build Instructions

### Prerequisites

1. **Flutter SDK** (3.x or later)  
   Download: https://flutter.dev/docs/get-started/install

2. **Android Studio** (for Android SDK)  
   Download: https://developer.android.com/studio

3. **Java 11+** (usually bundled with Android Studio)

### Quick Build (One Command)

```bash
chmod +x build_apk.sh
./build_apk.sh
```

The APK will be at `ShiftFilter-release.apk` in the project root.

### Manual Build

```bash
# 1. Get dependencies
flutter pub get

# 2. Accept Android licenses (first time only)
flutter doctor --android-licenses

# 3. Build release APK
flutter build apk --release

# 4. Find your APK
# build/app/outputs/flutter-apk/app-release.apk
```

### Install on Device

```bash
# Via ADB (USB debugging enabled)
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Or copy APK to device and install manually
```

---

## 📱 How to Use

1. **Open App** → Tap **Camera** or **Gallery**
2. **Capture/Select** your Excel roster screenshot
3. **Wait ~2-3 seconds** for OCR processing
4. **Filter results**:
   - Tap a **Day** chip to filter by day
   - Tap a **Shift** chip to filter by shift type
   - Use the **Search bar** to find an employee
5. **Employee count** updates in real time

---

## 📐 Project Structure

```
shift_filter/
├── lib/
│   ├── main.dart                 # App entry, theme setup
│   ├── models/
│   │   └── employee.dart         # Data models
│   ├── providers/
│   │   └── app_provider.dart     # State management
│   ├── screens/
│   │   └── home_screen.dart      # Main UI
│   ├── utils/
│   │   └── ocr_parser.dart       # ML Kit OCR + table parser
│   └── widgets/
│       ├── employee_card.dart    # Employee list item
│       ├── shift_chip.dart       # Color-coded shift badge
│       ├── stat_card.dart        # Stat summary card
│       └── upload_zone.dart      # Scan entry zone
├── android/
│   └── app/
│       ├── build.gradle
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/.../MainActivity.kt
├── pubspec.yaml
└── build_apk.sh                  # One-command build script
```

---

## 🛠️ Tech Stack

| Package | Purpose |
|---------|---------|
| `google_mlkit_text_recognition` | On-device OCR |
| `image_picker` | Gallery + camera access |
| `permission_handler` | Runtime permissions |
| `flutter_animate` | Smooth animations |
| `google_fonts` | Inter typeface |

---

## 📝 OCR Tips for Best Results

- Use **good lighting** when photographing printed rosters
- **Screenshots** of Excel/spreadsheets work best
- Ensure **shift values are clearly visible** (e.g., `0730-1730`)
- Higher image resolution = better OCR accuracy
- Avoid heavy **glare or shadows** on the page

---

## ⚙️ Troubleshooting

| Issue | Fix |
|-------|-----|
| No employees detected | Try a clearer image with better contrast |
| Missing shifts | Ensure shift values match: 0730-1730, 1230-2230, 2200-0800, RDO |
| Camera not working | Grant camera permission in Android Settings |
| Build fails | Run `flutter doctor` and fix any issues shown |
| Gradle error | Run `flutter clean` then `flutter pub get` |

---

## 🔒 Privacy

- **Zero data collection** — all processing is on-device
- **No internet required** — ML Kit runs fully offline after installation
- **No accounts** — no login, no tracking

---

*Built with Flutter + Google ML Kit OCR*
