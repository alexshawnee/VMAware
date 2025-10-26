#!/bin/bash
set -e

mkdir -p build

# -----------------------
# macOS universal library
# -----------------------
clang++ -std=c++17 -c -arch x86_64 -o build/vmaware_mac_x86_64.o src/vmaware.cpp
ar rcs build/libvmaware_mac_x86_64.a build/vmaware_mac_x86_64.o

clang++ -std=c++17 -c -arch arm64 -o build/vmaware_mac_arm64.o src/vmaware.cpp
ar rcs build/libvmaware_mac_arm64.a build/vmaware_mac_arm64.o

lipo -create build/libvmaware_mac_x86_64.a build/libvmaware_mac_arm64.a -output build/libvmaware_mac.a

# -----------------------
# iOS libraries
# -----------------------
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
SIM_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)

# Device arm64
clang++ -std=c++17 -c -arch arm64 -isysroot $IOS_SDK -o build/vmaware_ios_arm64.o src/vmaware.cpp
ar rcs build/libvmaware_ios_arm64.a build/vmaware_ios_arm64.o

# Simulator x86_64
clang++ -std=c++17 -c -arch x86_64 -isysroot $SIM_SDK -mios-simulator-version-min=13.0 -o build/vmaware_ios_sim_x86_64.o src/vmaware.cpp
ar rcs build/libvmaware_ios_sim_x86_64.a build/vmaware_ios_sim_x86_64.o

# Simulator arm64 (Apple Silicon)
clang++ -std=c++17 -c -arch arm64 -isysroot $SIM_SDK -mios-simulator-version-min=13.0 -o build/vmaware_ios_sim_arm64.o src/vmaware.cpp
ar rcs build/libvmaware_ios_sim_arm64.a build/vmaware_ios_sim_arm64.o

# Combine simulator libs into universal
lipo -create build/libvmaware_ios_sim_x86_64.a build/libvmaware_ios_sim_arm64.a -output build/libvmaware_ios_sim_universal.a

# -----------------------
# Create XCFramework
# -----------------------
xcodebuild -create-xcframework \
  -library build/libvmaware_mac.a -headers include/ \
  -library build/libvmaware_ios_arm64.a -headers include/ \
  -library build/libvmaware_ios_sim_universal.a -headers include/ \
  -output build/VMAware.xcframework
