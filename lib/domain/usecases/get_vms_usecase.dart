import 'package:dartz/dartz.dart';
import '../entities/virtual_machine.dart';
import '../repositories/vm_repository.dart';
import '../repositories/failures.dart';

class GetVmsUseCase {
  final VmRepository _repo;
  const GetVmsUseCase(this._repo);

  Future<Either<VmFailure, List<VirtualMachine>>> call() => _repo.getVms();
}
