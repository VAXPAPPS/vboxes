# 🖥️ VAXP Boxes

**A professional Linux VM Manager built with Flutter, powered by QEMU/KVM via libvirt.**

VAXP Boxes provides a modern, beautiful desktop interface for creating and managing virtual machines on Linux — similar to  , but built on the VAXP application framework with a stunning glassmorphism UI.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Create VMs** | Create virtual machines with custom CPU, RAM, and disk size via an intuitive form |
| **Auto Disk Creation** | Disk images (qcow2) are created automatically via libvirt Storage Pool API — no manual setup needed |
| **ISO File Picker** | Select installation ISO files with a native file picker dialog |
| **Disk Size Slider** | Choose disk size (5–500 GB) with a sleek slider — no need to type paths |
| **VM Lifecycle** | Start, Stop, Pause, Resume virtual machines with one click |
| **Live Statistics** | Real-time RAM usage monitoring with animated charts |
| **SPICE Display** | Open the VM's graphical display via `remote-viewer` (SPICE protocol) |
| **VM Details** | View detailed VM information (UUID, OS type, vCPU, RAM) |
| **Glassmorphism UI** | Beautiful frosted-glass design with animations and dark theme |
| **Clean Architecture** | 5-layer architecture: Presentation → Application → Domain → Data → Infrastructure |
| **FFI Only** | All system calls go through C++ FFI bridge — zero `dart:io` usage |
| **BLoC State Management** | Predictable, testable state management with `flutter_bloc` |

---

## 🏗️ Architecture

```
lib/
├── main.dart                          # App entry point
├── core/                              # Theme, layout, DI, colors
│   ├── di/injection_container.dart     # Dependency injection (get_it)
│   ├── theme/vaxp_theme.dart
│   ├── colors/vaxp_colors.dart
│   └── venom_layout.dart              # VenomScaffold, VaxpGlass
├── domain/                            # Business logic (pure Dart)
│   ├── entities/                      # VirtualMachine, VmCreateParams
│   ├── repositories/                  # Abstract VmRepository
│   └── usecases/                      # CreateVm, DeleteVm, GetVms, etc.
├── data/                              # Data layer
│   ├── datasources/                   # QemuFfiDataSource (talks to C++)
│   ├── models/                        # VirtualMachineModel, VmStatsModel
│   └── repositories/                  # VmRepositoryImpl
├── application/                       # BLoC layer
│   ├── vm_list/                       # VmListBloc
│   ├── vm_detail/                     # VmDetailBloc
│   └── create_vm/                     # CreateVmBloc
├── infrastructure/                    # FFI bridge
│   └── ffi/
│       ├── qemu_ffi_bindings.dart     # Native function typedefs
│       └── libqemu_bridge.dart        # DynamicLibrary loader
└── presentation/                      # UI
    ├── pages/                         # HomePage, CreateVmPage, VmDetailPage
    └── widgets/                       # VmCard, ResourceChart
```

### C++ FFI Bridge

```
ffi/
├── qemu_bridge.cc      # C++ source (libvirt API calls)
├── CMakeLists.txt       # Build configuration
└── build/
    └── libqemu_bridge.so  # Compiled shared library
```

---

## 📦 Prerequisites

### System Packages

```bash
# Required: QEMU/KVM and libvirt
sudo apt install qemu-kvm libvirt-daemon-system libvirt-dev libvirt-clients bridge-utils

# Required: SPICE display viewer
sudo apt install virt-viewer

# Required: C++ build tools
sudo apt install cmake g++ pkg-config

# Required: Flutter file picker dependency
sudo apt install zenity
```

### User Permissions

Add your user to the `libvirt` group:
```bash
sudo usermod -aG libvirt $USER
```
> ⚠️ **Log out and log back in** for group changes to take effect.

### Flutter SDK

- Flutter 3.x or later
- Linux desktop support enabled:
  ```bash
  flutter config --enable-linux-desktop
  ```

---

## 🚀 Build & Run

### 1. Install Flutter Dependencies

```bash
flutter pub get
```

### 2. Build the C++ FFI Bridge

```bash
chmod +x build_bridge.sh
./build_bridge.sh
```

This compiles `ffi/qemu_bridge.cc` → `libqemu_bridge.so` and copies it to the project root.

### 3. Run the Application

```bash
flutter run -d linux
```

---

## ⚙️ Configuration

### libvirt/QEMU Configuration

For VAXP Boxes to work properly, the following settings are applied in `/etc/libvirt/qemu.conf`:

| Setting | Value | Purpose |
|---------|-------|---------|
| `security_driver` | `"none"` | Disables AppArmor/DAC restrictions so QEMU can access ISO files |
| `user` | `"root"` | Allows QEMU to access files in user home directories |
| `group` | `"root"` | Same as above |

To apply these settings:
```bash
sudo sed -i 's/#security_driver = "selinux"/security_driver = "none"/' /etc/libvirt/qemu.conf
sudo bash -c "echo 'user = \"root\"' >> /etc/libvirt/qemu.conf"
sudo bash -c "echo 'group = \"root\"' >> /etc/libvirt/qemu.conf"
sudo systemctl restart libvirtd
```

### Default Storage Pool

VAXP Boxes stores VM disk images in `/var/lib/libvirt/images/` (the standard libvirt storage pool). If the "default" pool doesn't exist:
```bash
sudo virsh pool-define-as default dir --target /var/lib/libvirt/images
sudo virsh pool-start default
sudo virsh pool-autostart default
```

---

## 🔧 Troubleshooting

### Permission Denied when creating VM disk

**Error:**
```
qemu-img: Could not create '/var/lib/libvirt/images/xxx.qcow2': Permission denied
```

**Solution:** VAXP Boxes creates disks via libvirt's Storage Pool API. Make sure the default pool is active:
```bash
sudo virsh pool-start default
```

---

### Permission Denied when accessing ISO file

**Error:**
```
Could not open '/home/user/file.iso': Permission denied
```

**Solution:** QEMU runs as a restricted user by default. Set `user = "root"` and `security_driver = "none"` in `/etc/libvirt/qemu.conf`, then restart libvirtd:
```bash
sudo systemctl restart libvirtd
```

---

### "Storage pool not found: 'default'"

**Error:**
```
libvirt: Storage Driver error : Storage pool not found: no storage pool with matching name 'default'
```

**Solution:**
```bash
sudo virsh pool-define-as default dir --target /var/lib/libvirt/images
sudo virsh pool-start default
sudo virsh pool-autostart default
```

---

### "Broken pipe" / "client socket is closed"

**Error:**
```
libvirt: XML-RPC error : Cannot write data: Broken pipe
```

**Cause:** The application's libvirt connection became stale (e.g., after restarting `libvirtd`).

**Solution:** Simply restart the application. A fresh libvirt connection will be established automatically.

---

### VM Stop button doesn't work

**Cause:** If using graceful shutdown (`virDomainShutdown`), the guest OS must have ACPI support. VMs without an installed OS won't respond.

**Solution:** VAXP Boxes uses `virDomainDestroy` (force power off) by default, which always works. If you still experience issues, use the force stop option.

---

### libqemu_bridge.so not found

**Error:**
```
LibraryNotLoadedFailure: libqemu_bridge.so not loaded
```

**Solution:** Rebuild the C++ bridge:
```bash
./build_bridge.sh
```

Make sure `libvirt-dev` is installed:
```bash
sudo apt install libvirt-dev
```

---

### Display viewer doesn't open

**Error:** Clicking "Display" does nothing.

**Solution:** Install `virt-viewer`:
```bash
sudo apt install virt-viewer
```

The display uses SPICE protocol. Make sure the VM is running before opening the display.

---

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **UI Framework** | Flutter (Linux Desktop) |
| **State Management** | flutter_bloc + equatable |
| **Dependency Injection** | get_it |
| **Error Handling** | dartz (Either/Functional) |
| **Virtualization** | QEMU/KVM via libvirt |
| **System Interface** | C++ FFI (dart:ffi) |
| **Display Protocol** | SPICE (via remote-viewer) |
| **Disk Format** | qcow2 |
| **File Picker** | file_picker |

---

## 📄 License

This project is part of the VAXP ecosystem.

---


