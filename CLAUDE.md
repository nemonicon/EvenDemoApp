# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EvenDemoApp (`demo_ai_even`) is a Flutter demo application for **Even G1 Smart Glasses**. It demonstrates AI-powered voice interaction, BMP image transmission, and text display through dual Bluetooth Low Energy (BLE) connections to the glasses' left and right arms.

## Build & Development Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device (requires paired G1 glasses or emulator)
flutter build apk            # Build Android APK
flutter build ios            # Build iOS app
flutter analyze              # Run Dart static analysis
flutter test                 # Run tests (currently only boilerplate widget test)
```

Android native C++ libraries (LC3 decoder, RNNoise) are built automatically via CMake during `flutter build apk`. The CMake config is at `android/app/src/main/cpp/CMakeLists.txt`.

## Architecture

### Layer Structure

```
Flutter UI (lib/views/)
    ↓
GetX Controllers (lib/controllers/)
    ↓
Services (lib/services/)
    ↓
BLE Manager (lib/ble_manager.dart)
    ↓
Platform Channels (MethodChannel)
    ↓
Native BLE (Android: Kotlin, iOS: Swift)
    ↓
Native Audio (Android only: C++ LC3 + RNNoise via JNI)
```

### Key Files

- **`lib/main.dart`** — Entry point. Initializes `BleManager` and GetX `EvenaiModelController`.
- **`lib/ble_manager.dart`** — Core dual-BLE communication. Manages left/right arm connections, request/response matching, heartbeat (8s interval), and command routing.
- **`lib/services/evenai.dart`** — Even AI orchestration: voice activation, LC3 audio streaming, speech-to-text, AI query, and result paging to glasses.
- **`lib/services/proto.dart`** — Protocol implementation for glasses commands (0x4E text, 0x15 BMP, 0x0E mic, etc.).
- **`lib/services/api_services_deepseek.dart`** — Active AI backend (DeepSeek chat API).
- **`lib/services/api_services.dart`** — Alternative AI backend (Alibaba Qwen).
- **`lib/services/text_service.dart`** — Text measurement and paging (488px max width, 21pt font, 5 lines/page).

### Dual BLE Communication Pattern

The G1 glasses have **separate BLE connections for each arm**. The protocol requires:
1. Send command to **left arm first**
2. Wait for acknowledgment
3. Then send to **right arm**

Exception: some commands target only one side (e.g., mic activation → right arm only). BMP data can be sent to both sides simultaneously.

### Platform Channel Bridge

Flutter communicates with native BLE via `MethodChannel`:
- **Android**: `BleManager.kt` / `BleChannelHelper.kt` (Kotlin)
- **iOS**: `BluetoothManager.swift` / `AppDelegate.swift` (Swift)

Android additionally uses JNI to call C++ libraries for LC3 audio decoding and RNNoise denoising (`android/app/src/main/cpp/`).

### State Management

Uses **GetX** (`get` package) for reactive state management. Controllers are registered via `Get.put()` in `main.dart`.

## Protocol Reference

All protocol details (command bytes, field layouts, paging semantics) are documented in `README.md`. Key commands:
- `0xF5` — TouchBar events and Even AI start/stop
- `0x0E` — Microphone enable/disable
- `0xF1` — Audio data stream (LC3 format)
- `0x4E` — Send AI result or text to display (with paging metadata)
- `0x15` — BMP data packets (194 bytes each, 1-bit 576x136 images)
- `0x16` — CRC32-XZ verification for BMP
- `0x20` — BMP transmission end marker

## Key Constraints

- Glasses display: **576x136 pixels** (488px usable width for AI/text content)
- Text rendering: 21pt font, 5 lines per screen page
- BMP images: must be **1-bit, 576x136 pixels**
- Max recording duration: **30 seconds**
- BLE packet size limit: 194 bytes for BMP data
- NDK ABI filters: `armeabi-v7a`, `arm64-v8a` only
