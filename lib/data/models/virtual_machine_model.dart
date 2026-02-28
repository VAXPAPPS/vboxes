import 'dart:convert';
import '../../domain/entities/virtual_machine.dart';
import '../../domain/entities/vm_status.dart';

class VirtualMachineModel extends VirtualMachine {
  const VirtualMachineModel({
    required super.id,
    required super.name,
    required super.status,
    required super.vcpus,
    required super.ramKib,
    super.osType,
    super.xmlDesc,
  });

  factory VirtualMachineModel.fromJson(Map<String, dynamic> json) {
    return VirtualMachineModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      status: VmStatus.fromString(json['status'] as String? ?? 'unknown'),
      vcpus: (json['vcpus'] as num?)?.toInt() ?? 1,
      ramKib: (json['ramKib'] as num?)?.toInt() ?? 0,
      osType: _extractOsType(json['xml'] as String?),
      xmlDesc: json['xml'] as String?,
    );
  }

  /// Parse OS type from libvirt XML (e.g. "hvm" → "Linux KVM").
  static String _extractOsType(String? xml) {
    if (xml == null) return 'Unknown';
    if (xml.contains('win')) return 'Windows';
    if (xml.contains('ubuntu') || xml.contains('debian')) return 'Ubuntu/Debian';
    if (xml.contains('fedora') || xml.contains('rhel')) return 'Fedora/RHEL';
    return 'Linux';
  }

  static List<VirtualMachineModel> listFromJson(String jsonStr) {
    final List<dynamic> decoded = jsonDecode(jsonStr) as List;
    return decoded
        .map((e) => VirtualMachineModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
