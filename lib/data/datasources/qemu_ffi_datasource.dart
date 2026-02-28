import 'dart:async';
import 'package:ffi/ffi.dart';
import '../../infrastructure/ffi/libqemu_bridge.dart';
import '../models/virtual_machine_model.dart';
import '../models/vm_stats_model.dart';
import '../../domain/repositories/failures.dart';

/// The ONLY place in the codebase that talks to native C++.
/// NO dart:io. NO Process.run(). NO dart:isolate.
class QemuFfiDataSource {
  final LibQemuBridge _bridge;
  QemuFfiDataSource(this._bridge);

  void _assertLoaded() {
    if (!_bridge.isLoaded) {
      throw LibraryNotLoadedFailure(
        'libqemu_bridge.so not loaded: ${_bridge.loadError}',
      );
    }
  }

  // ── VM List ────────────────────────────────────────────────────────────────

  Future<List<VirtualMachineModel>> getVms() async {
    _assertLoaded();
    final json = _bridge.callReturnsString(_bridge.listVmsNative);
    if (json.startsWith('{"error"')) {
      throw NativeCallFailure(json);
    }
    return VirtualMachineModel.listFromJson(json);
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Future<void> startVm(String name) async {
    _assertLoaded();
    final result = _bridge.callNameReturnsInt(_bridge.startVmNative, name);
    if (result < 0) throw NativeCallFailure(_getLastError());
  }

  Future<void> stopVm(String name) async {
    _assertLoaded();
    final result = _bridge.callNameReturnsInt(_bridge.stopVmNative, name);
    if (result < 0) throw NativeCallFailure(_getLastError());
  }

  Future<void> forceStopVm(String name) async {
    _assertLoaded();
    final result = _bridge.callNameReturnsInt(_bridge.forceStopVmNative, name);
    if (result < 0) throw NativeCallFailure(_getLastError());
  }

  Future<void> pauseVm(String name) async {
    _assertLoaded();
    final result = _bridge.callNameReturnsInt(_bridge.pauseVmNative, name);
    if (result < 0) throw NativeCallFailure(_getLastError());
  }

  Future<void> resumeVm(String name) async {
    _assertLoaded();
    final result = _bridge.callNameReturnsInt(_bridge.resumeVmNative, name);
    if (result < 0) throw NativeCallFailure(_getLastError());
  }

  String getDefaultDiskPath(String vmName) {
    _assertLoaded();
    return _bridge.callNameReturnsString(_bridge.getDefaultDiskPathNative, vmName);
  }

  Future<void> createDisk(String path, int sizeGb) async {
    _assertLoaded();
    final pathPtr = path.toNativeUtf8();
    final result = _bridge.createDiskNative(pathPtr, sizeGb);
    calloc.free(pathPtr);
    if (result < 0) {
      throw NativeCallFailure(_getLastError());
    }
  }

  // ── Create / Delete ────────────────────────────────────────────────────────

  Future<void> createVm(String xmlDesc) async {
    _assertLoaded();
    final ptr = xmlDesc.toNativeUtf8();
    final result = _bridge.createVmNative(ptr);
    calloc.free(ptr);
    if (result < 0) throw NativeCallFailure(_getLastError());
  }

  Future<void> deleteVm(String name) async {
    _assertLoaded();
    final result = _bridge.callNameReturnsInt(_bridge.deleteVmNative, name);
    if (result < 0) throw NativeCallFailure(_getLastError());
  }

  Future<void> openVmDisplay(String name) async {
    _assertLoaded();
    final result = _bridge.callNameReturnsInt(_bridge.openVmDisplayNative, name);
    if (result < 0) throw NativeCallFailure(_getLastError());
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  Future<VmStatsModel> getVmStats(String name) async {
    _assertLoaded();
    final json = _bridge.callNameReturnsString(_bridge.getVmStatsNative, name);
    if (json.contains('"error"')) throw NativeCallFailure(json);
    return VmStatsModel.parse(name, json);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _getLastError() =>
      _bridge.callReturnsString(_bridge.getLastErrorNative);
}
