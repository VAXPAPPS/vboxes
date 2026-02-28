import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/vm_create_params.dart';
import '../../domain/usecases/vm_management_usecases.dart';
import 'create_vm_event.dart';
import 'create_vm_state.dart';

class CreateVmBloc extends Bloc<CreateVmEvent, CreateVmState> {
  final CreateVmUseCase _createVm;

  CreateVmBloc({required CreateVmUseCase createVm})
      : _createVm = createVm,
        super(const CreateVmInitial()) {
    on<UpdateVmName>(_onName);
    on<UpdateVcpus>(_onVcpus);
    on<UpdateRamMb>(_onRam);
    on<UpdateDiskSizeGb>(_onDiskSize);
    on<UpdateIsoPath>(_onIso);
    on<UpdateOsType>(_onOs);
    on<SubmitCreateVm>(_onSubmit);
    on<ResetCreateForm>(_onReset);
  }

  void _onName(UpdateVmName e, Emitter<CreateVmState> emit) {
    final cur = _form;
    if (cur == null) return;
    final error = e.value.trim().isEmpty ? 'اسم الآلة مطلوب' : null;
    emit(cur.copyWith(name: e.value.trim(), nameError: error, clearNameError: error == null));
  }

  void _onVcpus(UpdateVcpus e, Emitter<CreateVmState> emit) {
    final cur = _form;
    if (cur == null) return;
    emit(cur.copyWith(vcpus: e.value.clamp(1, 16)));
  }

  void _onRam(UpdateRamMb e, Emitter<CreateVmState> emit) {
    final cur = _form;
    if (cur == null) return;
    emit(cur.copyWith(ramMb: e.value.clamp(256, 65536)));
  }

  void _onDiskSize(UpdateDiskSizeGb e, Emitter<CreateVmState> emit) {
    final cur = _form;
    if (cur == null) return;
    emit(cur.copyWith(diskSizeGb: e.value.clamp(5, 1000)));
  }

  void _onIso(UpdateIsoPath e, Emitter<CreateVmState> emit) {
    final cur = _form;
    if (cur == null) return;
    emit(cur.copyWith(isoPath: e.value.trim()));
  }

  void _onOs(UpdateOsType e, Emitter<CreateVmState> emit) {
    final cur = _form;
    if (cur == null) return;
    emit(cur.copyWith(osType: e.value));
  }

  Future<void> _onSubmit(SubmitCreateVm e, Emitter<CreateVmState> emit) async {
    final cur = _form;
    if (cur == null || !cur.isValid) return;

    emit(const CreateVmSubmitting());

    final params = VmCreateParams(
      name: cur.name,
      vcpus: cur.vcpus,
      ramMb: cur.ramMb,
      diskSizeGb: cur.diskSizeGb,
      isoPath: cur.isoPath,
    );

    final result = await _createVm(params);
    result.fold(
      (f) => emit(CreateVmFailure(f.message)),
      (_) => emit(CreateVmSuccess(cur.name)),
    );
  }

  void _onReset(ResetCreateForm e, Emitter<CreateVmState> emit) {
    emit(const CreateVmInitial());
  }

  CreateVmInitial? get _form {
    final s = state;
    return s is CreateVmInitial ? s : null;
  }
}
