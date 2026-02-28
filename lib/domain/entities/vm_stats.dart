import 'package:equatable/equatable.dart';

class VmStats extends Equatable {
  final String vmName;
  final int cpuTimeNs;      // Nanoseconds — must be diffed over time for %
  final int memTotalKib;
  final int memUsedKib;
  final DateTime timestamp;

  const VmStats({
    required this.vmName,
    required this.cpuTimeNs,
    required this.memTotalKib,
    required this.memUsedKib,
    required this.timestamp,
  });

  double get memUsedPercent =>
      memTotalKib > 0 ? (memUsedKib / memTotalKib) * 100 : 0.0;

  int get memUsedMb => memUsedKib ~/ 1024;
  int get memTotalMb => memTotalKib ~/ 1024;

  @override
  List<Object?> get props => [vmName, cpuTimeNs, memTotalKib, memUsedKib, timestamp];
}
