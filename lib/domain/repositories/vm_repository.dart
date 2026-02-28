import 'package:dartz/dartz.dart';
import '../entities/virtual_machine.dart';
import '../entities/vm_stats.dart';
import 'failures.dart';

abstract class VmRepository {
  Future<Either<VmFailure, List<VirtualMachine>>> getVms();

  Future<Either<VmFailure, Unit>> startVm(String name);
  Future<Either<VmFailure, Unit>> stopVm(String name);
  Future<Either<VmFailure, Unit>> forceStopVm(String name);
  Future<Either<VmFailure, Unit>> pauseVm(String name);
  Future<Either<VmFailure, Unit>> resumeVm(String name);

  String getDefaultDiskPath(String vmName);
  Future<Either<VmFailure, Unit>> createDisk(String path, int sizeGb);

  Future<Either<VmFailure, Unit>> createVm(String xmlDesc);
  Future<Either<VmFailure, Unit>> deleteVm(String name);
  Future<Either<VmFailure, Unit>> openVmDisplay(String name);

  /// Polling-based stats stream. Emits every [interval].
  Stream<Either<VmFailure, VmStats>> watchVmStats(
    String name, {
    Duration interval = const Duration(seconds: 2),
  });
}
