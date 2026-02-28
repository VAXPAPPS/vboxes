import 'package:dartz/dartz.dart';
import '../repositories/vm_repository.dart';
import '../repositories/failures.dart';

class StartVmUseCase {
  final VmRepository _repo;
  const StartVmUseCase(this._repo);

  Future<Either<VmFailure, Unit>> call(String name) => _repo.startVm(name);
}

class StopVmUseCase {
  final VmRepository _repo;
  const StopVmUseCase(this._repo);

  Future<Either<VmFailure, Unit>> call(String name) => _repo.stopVm(name);
}

class ForceStopVmUseCase {
  final VmRepository _repo;
  const ForceStopVmUseCase(this._repo);

  Future<Either<VmFailure, Unit>> call(String name) => _repo.forceStopVm(name);
}

class PauseVmUseCase {
  final VmRepository _repo;
  const PauseVmUseCase(this._repo);

  Future<Either<VmFailure, Unit>> call(String name) => _repo.pauseVm(name);
}

class ResumeVmUseCase {
  final VmRepository _repo;
  const ResumeVmUseCase(this._repo);

  Future<Either<VmFailure, Unit>> call(String name) => _repo.resumeVm(name);
}
