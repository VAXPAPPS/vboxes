import 'package:dartz/dartz.dart';
import '../entities/vm_create_params.dart';
import '../repositories/vm_repository.dart';
import '../repositories/failures.dart';

class CreateVmUseCase {
  final VmRepository _repo;
  const CreateVmUseCase(this._repo);

  Future<Either<VmFailure, Unit>> call(VmCreateParams params) async {
    final diskPath = _repo.getDefaultDiskPath(params.name);
    
    final diskRes = await _repo.createDisk(diskPath, params.diskSizeGb);
    if (diskRes.isLeft()) return diskRes;

    final xmlDesc = params.toLibvirtXml(diskPath);
    return _repo.createVm(xmlDesc);
  }
}

class DeleteVmUseCase {
  final VmRepository _repo;
  const DeleteVmUseCase(this._repo);

  Future<Either<VmFailure, Unit>> call(String name) => _repo.deleteVm(name);
}
