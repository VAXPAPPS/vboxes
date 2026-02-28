import 'package:equatable/equatable.dart';

abstract class CreateVmState extends Equatable {
  const CreateVmState();
  @override List<Object?> get props => [];
}

class CreateVmInitial extends CreateVmState {
  final String name;
  final int vcpus;
  final int ramMb;
  final int diskSizeGb;
  final String isoPath;
  final String osType;

  // Validation errors
  final String? nameError;

  const CreateVmInitial({
    this.name = '',
    this.vcpus = 2,
    this.ramMb = 2048,
    this.diskSizeGb = 20,
    this.isoPath = '',
    this.osType = 'Linux',
    this.nameError,
  });

  bool get isValid =>
      name.isNotEmpty && nameError == null;

  CreateVmInitial copyWith({
    String? name,
    int? vcpus,
    int? ramMb,
    int? diskSizeGb,
    String? isoPath,
    String? osType,
    String? nameError,
    bool clearNameError = false,
  }) {
    return CreateVmInitial(
      name: name ?? this.name,
      vcpus: vcpus ?? this.vcpus,
      ramMb: ramMb ?? this.ramMb,
      diskSizeGb: diskSizeGb ?? this.diskSizeGb,
      isoPath: isoPath ?? this.isoPath,
      osType: osType ?? this.osType,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
    );
  }

  @override
  List<Object?> get props => [name, vcpus, ramMb, diskSizeGb, isoPath, osType, nameError];
}

class CreateVmSubmitting extends CreateVmState {
  const CreateVmSubmitting();
}

class CreateVmSuccess extends CreateVmState {
  final String vmName;
  const CreateVmSuccess(this.vmName);
  @override List<Object?> get props => [vmName];
}

class CreateVmFailure extends CreateVmState {
  final String message;
  const CreateVmFailure(this.message);
  @override List<Object?> get props => [message];
}
