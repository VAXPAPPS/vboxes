import 'package:equatable/equatable.dart';
import 'vm_status.dart';

class VirtualMachine extends Equatable {
  final String id;       // UUID from libvirt
  final String name;
  final VmStatus status;
  final int vcpus;
  final int ramKib;      // KiB (as reported by libvirt)
  final String osType;
  final String? xmlDesc; // raw libvirt XML (cached for edits)

  const VirtualMachine({
    required this.id,
    required this.name,
    required this.status,
    required this.vcpus,
    required this.ramKib,
    this.osType = 'Linux',
    this.xmlDesc,
  });

  int get ramMb => ramKib ~/ 1024;
  int get ramGb => ramMb ~/ 1024;

  VirtualMachine copyWith({
    String? id,
    String? name,
    VmStatus? status,
    int? vcpus,
    int? ramKib,
    String? osType,
    String? xmlDesc,
  }) {
    return VirtualMachine(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      vcpus: vcpus ?? this.vcpus,
      ramKib: ramKib ?? this.ramKib,
      osType: osType ?? this.osType,
      xmlDesc: xmlDesc ?? this.xmlDesc,
    );
  }

  @override
  List<Object?> get props => [id, name, status, vcpus, ramKib, osType];
}
