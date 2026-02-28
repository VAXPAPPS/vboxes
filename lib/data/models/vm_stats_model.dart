import 'dart:convert';
import '../../domain/entities/vm_stats.dart';

class VmStatsModel extends VmStats {
  const VmStatsModel({
    required super.vmName,
    required super.cpuTimeNs,
    required super.memTotalKib,
    required super.memUsedKib,
    required super.timestamp,
  });

  factory VmStatsModel.fromJson(String vmName, Map<String, dynamic> json) {
    return VmStatsModel(
      vmName: vmName,
      cpuTimeNs: (json['cpuTimeNs'] as num?)?.toInt() ?? 0,
      memTotalKib: (json['memTotalKib'] as num?)?.toInt() ?? 0,
      memUsedKib: (json['memUsedKib'] as num?)?.toInt() ?? 0,
      timestamp: DateTime.now(),
    );
  }

  static VmStatsModel parse(String vmName, String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return VmStatsModel.fromJson(vmName, map);
  }
}
