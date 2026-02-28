import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'qemu_ffi_bindings.dart';

/// Singleton that loads libqemu_bridge.so and exposes all native functions.
/// All system calls go through this — NO dart:io anywhere.
class LibQemuBridge {
  static final LibQemuBridge _instance = LibQemuBridge._internal();
  factory LibQemuBridge() => _instance;
  LibQemuBridge._internal() {
    _load();
  }

  late final DynamicLibrary _lib;
  bool _loaded = false;
  String? _loadError;

  // ── Resolved function handles ──────────────────────────────────────────────
  late final ListVmsDart listVmsNative;
  late final StartVmDart startVmNative;
  late final StopVmDart stopVmNative;
  late final ForceStopVmDart forceStopVmNative;
  late final PauseVmDart pauseVmNative;
  late final ResumeVmDart resumeVmNative;
  late final GetDefaultDiskPathDart getDefaultDiskPathNative;
  late final CreateDiskDart createDiskNative;
  late final CreateVmDart createVmNative;
  late final DeleteVmDart deleteVmNative;
  late final OpenVmDisplayDart openVmDisplayNative;
  late final GetVmStatsDart getVmStatsNative;
  late final GetLastErrorDart getLastErrorNative;
  late final FreeStringDart freeStringNative;

  bool get isLoaded => _loaded;
  String? get loadError => _loadError;

  void _load() {
    try {
      final devPath = '${Directory.current.path}/libqemu_bridge.so';
      
      try {
        _lib = DynamicLibrary.open(devPath);
      } catch (_) {
        try {
          _lib = DynamicLibrary.open('libqemu_bridge.so');
        } catch (_) {
          _lib = DynamicLibrary.open('/usr/local/lib/libqemu_bridge.so');
        }
      }

      listVmsNative     = _lib.lookupFunction<ListVmsNative,     ListVmsDart>    ('list_vms');
      startVmNative     = _lib.lookupFunction<StartVmNative,     StartVmDart>    ('start_vm');
      stopVmNative      = _lib.lookupFunction<StopVmNative,      StopVmDart>     ('stop_vm');
      forceStopVmNative = _lib.lookupFunction<ForceStopVmNative, ForceStopVmDart>('force_stop_vm');
      pauseVmNative     = _lib.lookupFunction<PauseVmNative,     PauseVmDart>    ('pause_vm');
      resumeVmNative    = _lib.lookupFunction<ResumeVmNative,    ResumeVmDart>   ('resume_vm');
      getDefaultDiskPathNative = _lib.lookupFunction<GetDefaultDiskPathNative, GetDefaultDiskPathDart>('get_default_disk_path');
      createDiskNative  = _lib.lookupFunction<CreateDiskNative,  CreateDiskDart> ('create_disk');
      createVmNative    = _lib.lookupFunction<CreateVmNative,    CreateVmDart>   ('create_vm');
      deleteVmNative    = _lib.lookupFunction<DeleteVmNative,    DeleteVmDart>   ('delete_vm');
      openVmDisplayNative = _lib.lookupFunction<OpenVmDisplayNative, OpenVmDisplayDart>('open_vm_display');
      getVmStatsNative  = _lib.lookupFunction<GetVmStatsNative,  GetVmStatsDart> ('get_vm_stats');
      getLastErrorNative= _lib.lookupFunction<GetLastErrorNative, GetLastErrorDart>('get_last_error');
      freeStringNative  = _lib.lookupFunction<FreeStringNative,  FreeStringDart> ('free_string');

      _loaded = true;
    } catch (e) {
      _loaded = false;
      _loadError = e.toString();
    }
  }

  /// Safe helper: call native fn that returns char*, convert to Dart string, free C memory.
  String callReturnsString(Pointer<Utf8> Function() nativeFn) {
    final ptr = nativeFn();
    final result = ptr.toDartString();
    freeStringNative(ptr);
    return result;
  }

  /// Safe helper for functions that take a name parameter and return char*.
  String callNameReturnsString(
    Pointer<Utf8> Function(Pointer<Utf8>) nativeFn,
    String name,
  ) {
    final namePtr = name.toNativeUtf8();
    final ptr = nativeFn(namePtr);
    final result = ptr.toDartString();
    calloc.free(namePtr);
    freeStringNative(ptr);
    return result;
  }

  /// Safe helper for functions that take a name and return int.
  int callNameReturnsInt(
    int Function(Pointer<Utf8>) nativeFn,
    String name,
  ) {
    final namePtr = name.toNativeUtf8();
    final result = nativeFn(namePtr);
    calloc.free(namePtr);
    return result;
  }

  String getDefaultDiskPath(String name) {
    return callNameReturnsString(getDefaultDiskPathNative, name);
  }

  int createDisk(String path, int sizeGb) {
    final pathPtr = path.toNativeUtf8();
    final result = createDiskNative(pathPtr, sizeGb);
    calloc.free(pathPtr);
    return result;
  }
}
