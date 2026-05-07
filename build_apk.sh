#!/bin/bash
# ============================================================
# Shift Filter - One-Command APK Builder
# ============================================================
# Prerequisites: Flutter SDK installed and in PATH
# Run: chmod +x build_apk.sh && ./build_apk.sh
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════╗"
echo "║        SHIFT FILTER APK BUILDER       ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found. Install from https://flutter.dev${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Flutter found: $(flutter --version | head -1)${NC}"

# Check Android SDK
if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
    echo -e "${YELLOW}⚠ ANDROID_HOME not set. Make sure Android SDK is configured.${NC}"
fi

# Accept licenses
echo -e "${BLUE}→ Accepting Android licenses...${NC}"
yes | flutter doctor --android-licenses > /dev/null 2>&1 || true

# Clean previous build
echo -e "${BLUE}→ Cleaning project...${NC}"
flutter clean

# Get dependencies
echo -e "${BLUE}→ Getting dependencies...${NC}"
flutter pub get

# Generate launcher icons (if asset exists)
if [ -f "assets/icon.png" ]; then
    echo -e "${BLUE}→ Generating launcher icons...${NC}"
    flutter pub run flutter_launcher_icons 2>/dev/null || true
fi

# Build release APK
echo -e "${BLUE}→ Building release APK...${NC}"
flutter build apk --release --no-tree-shake-icons

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    SIZE=$(du -sh "$APK_PATH" | cut -f1)
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           ✓ BUILD SUCCESS!            ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}APK Location: ${APK_PATH}${NC}"
    echo -e "${GREEN}APK Size:     ${SIZE}${NC}"
    echo ""
    echo -e "${BLUE}Install on device:${NC}"
    echo "  adb install -r $APK_PATH"
    echo ""
    echo -e "${BLUE}Copy to current directory:${NC}"
    echo "  cp $APK_PATH ./ShiftFilter.apk"
    
    # Auto-copy to project root
    cp "$APK_PATH" "./ShiftFilter-release.apk"
    echo ""
    echo -e "${GREEN}✓ Copied to: ./ShiftFilter-release.apk${NC}"
else
    echo -e "${RED}✗ Build failed. Check output above.${NC}"
    exit 1
fi
