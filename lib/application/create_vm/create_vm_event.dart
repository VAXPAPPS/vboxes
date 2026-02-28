import 'package:equatable/equatable.dart';

abstract class CreateVmEvent extends Equatable {
  const CreateVmEvent();
  @override List<Object?> get props => [];
}

class UpdateVmName     extends CreateVmEvent {
  final String value;
  const UpdateVmName(this.value);
  @override List<Object?> get props => [value];
}

class UpdateVcpus      extends CreateVmEvent {
  final int value;
  const UpdateVcpus(this.value);
  @override List<Object?> get props => [value];
}

class UpdateRamMb      extends CreateVmEvent {
  final int value;
  const UpdateRamMb(this.value);
  @override List<Object?> get props => [value];
}

class UpdateDiskSizeGb extends CreateVmEvent {
  final int value;
  const UpdateDiskSizeGb(this.value);
  @override List<Object?> get props => [value];
}

class UpdateIsoPath    extends CreateVmEvent {
  final String value;
  const UpdateIsoPath(this.value);
  @override List<Object?> get props => [value];
}

class UpdateOsType     extends CreateVmEvent {
  final String value;
  const UpdateOsType(this.value);
  @override List<Object?> get props => [value];
}

class SubmitCreateVm   extends CreateVmEvent {
  const SubmitCreateVm();
}

class ResetCreateForm  extends CreateVmEvent {
  const ResetCreateForm();
}
