import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../domain/entities/virtual_machine.dart';
import '../../domain/entities/vm_stats.dart';
import '../../domain/repositories/vm_repository.dart';
import '../../domain/repositories/failures.dart';
import '../datasources/qemu_ffi_datasource.dart';

class VmRepositoryImpl implements VmRepository {
  final QemuFfiDataSource _ds;
  VmRepositoryImpl(this._ds);

  @override
  Future<Either<VmFailure, List<VirtualMachine>>> getVms() async {
    try {
      final vms = await _ds.getVms();
      return Right(vms);
    } on VmFailure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(NativeCallFailure(e.toString()));
    }
  }

  @override
  Future<Either<VmFailure, Unit>> startVm(String name) =>
      _wrapCall(() => _ds.startVm(name));

  @override
  Future<Either<VmFailure, Unit>> stopVm(String name) =>
      _wrapCall(() => _ds.stopVm(name));

  @override
  Future<Either<VmFailure, Unit>> forceStopVm(String name) =>
      _wrapCall(() => _ds.forceStopVm(name));

  @override
  Future<Either<VmFailure, Unit>> pauseVm(String name) =>
      _wrapCall(() => _ds.pauseVm(name));

  @override
  Future<Either<VmFailure, Unit>> resumeVm(String name) =>
      _wrapCall(() => _ds.resumeVm(name));

  @override
  String getDefaultDiskPath(String vmName) {
    try {
      return _ds.getDefaultDiskPath(vmName);
    } catch (e) {
      return '/tmp/$vmName.qcow2';
    }
  }

  @override
  Future<Either<VmFailure, Unit>> createDisk(String path, int sizeGb) =>
      _wrapCall(() => _ds.createDisk(path, sizeGb));

  @override
  Future<Either<VmFailure, Unit>> createVm(String xmlDesc) =>
      _wrapCall(() => _ds.createVm(xmlDesc));

  @override
  Future<Either<VmFailure, Unit>> deleteVm(String name) =>
      _wrapCall(() => _ds.deleteVm(name));

  @override
  Future<Either<VmFailure, Unit>> openVmDisplay(String name) =>
      _wrapCall(() => _ds.openVmDisplay(name));

  @override
  Stream<Either<VmFailure, VmStats>> watchVmStats(
    String name, {
    Duration interval = const Duration(seconds: 2),
  }) async* {
    while (true) {
      try {
        final stats = await _ds.getVmStats(name);
        yield Right(stats);
      } on VmFailure catch (f) {
        yield Left(f);
      } catch (e) {
        yield Left(NativeCallFailure(e.toString()));
      }
      await Future<void>.delayed(interval);
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<Either<VmFailure, Unit>> _wrapCall(
    Future<void> Function() fn,
  ) async {
    try {
      await fn();
      return const Right(unit);
    } on VmFailure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(NativeCallFailure(e.toString()));
    }
  }
}
