// GENERATED NATIVE FUNCTION SIGNATURES
// Maps Dart types to C++ function signatures in libqemu_bridge.so

import 'dart:ffi';
import 'package:ffi/ffi.dart';

// ─── Native Signatures ────────────────────────────────────────────────────────

// list_vms() → char*
typedef ListVmsNative = Pointer<Utf8> Function();
typedef ListVmsDart = Pointer<Utf8> Function();

// start_vm(name) → int
typedef StartVmNative = Int32 Function(Pointer<Utf8> name);
typedef StartVmDart = int Function(Pointer<Utf8> name);

// stop_vm(name) → int
typedef StopVmNative = Int32 Function(Pointer<Utf8> name);
typedef StopVmDart = int Function(Pointer<Utf8> name);

// force_stop_vm(name) → int
typedef ForceStopVmNative = Int32 Function(Pointer<Utf8> name);
typedef ForceStopVmDart = int Function(Pointer<Utf8> name);

// pause_vm(name) → int
typedef PauseVmNative = Int32 Function(Pointer<Utf8> name);
typedef PauseVmDart = int Function(Pointer<Utf8> name);

// resume_vm(name) → int
typedef ResumeVmNative = Int32 Function(Pointer<Utf8> name);
typedef ResumeVmDart = int Function(Pointer<Utf8> name);

typedef GetDefaultDiskPathNative = Pointer<Utf8> Function(Pointer<Utf8> name);
typedef GetDefaultDiskPathDart = Pointer<Utf8> Function(Pointer<Utf8> name);

typedef CreateDiskNative = Int32 Function(Pointer<Utf8> path, Int32 sizeGb);
typedef CreateDiskDart = int Function(Pointer<Utf8> path, int sizeGb);

// create_vm(xml_desc) → int
typedef CreateVmNative = Int32 Function(Pointer<Utf8> xmlDesc);
typedef CreateVmDart = int Function(Pointer<Utf8> xmlDesc);

// delete_vm(name) → int
typedef DeleteVmNative = Int32 Function(Pointer<Utf8> name);
typedef DeleteVmDart = int Function(Pointer<Utf8> name);

// open_vm_display(name) → int
typedef OpenVmDisplayNative = Int32 Function(Pointer<Utf8> name);
typedef OpenVmDisplayDart = int Function(Pointer<Utf8> name);

// get_vm_stats(name) → char*
typedef GetVmStatsNative = Pointer<Utf8> Function(Pointer<Utf8> name);
typedef GetVmStatsDart = Pointer<Utf8> Function(Pointer<Utf8> name);

// get_last_error() → char*
typedef GetLastErrorNative = Pointer<Utf8> Function();
typedef GetLastErrorDart = Pointer<Utf8> Function();

// free_string(ptr) → void
typedef FreeStringNative = Void Function(Pointer<Utf8> ptr);
typedef FreeStringDart = void Function(Pointer<Utf8> ptr);
