#!/usr/bin/env bash
# build_bridge.sh — Builds libqemu_bridge.so from ffi/qemu_bridge.cc
# Run this from the project root once before `flutter run -d linux`

set -e

echo "🔧 Checking for libvirt-dev..."
if ! pkg-config --exists libvirt; then
  echo "  libvirt not found. Installing..."
  sudo apt-get install -y libvirt-dev
fi

echo "🏗️  Building C++ bridge..."
mkdir -p ffi/build
cd ffi/build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --target qemu_bridge
cd ../..

# Copy .so to project root (Flutter linker picks it up from here on Linux)
cp ffi/build/libqemu_bridge.so ./

echo "✅ libqemu_bridge.so built successfully!"
echo ""
echo "Next step:"
echo "  flutter run -d linux"
