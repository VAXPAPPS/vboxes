import 'package:equatable/equatable.dart';
import '../../domain/entities/vm_stats.dart';
import '../../domain/entities/virtual_machine.dart';

abstract class VmDetailState extends Equatable {
  const VmDetailState();
  @override List<Object?> get props => [];
}

class VmDetailInitial extends VmDetailState {
  const VmDetailInitial();
}

class VmDetailLoading extends VmDetailState {
  const VmDetailLoading();
}

class VmDetailLoaded extends VmDetailState {
  final VirtualMachine vm;
  final List<VmStats> statsHistory; // last 30 data points
  final VmStats? latestStats;

  const VmDetailLoaded({
    required this.vm,
    this.statsHistory = const [],
    this.latestStats,
  });

  VmDetailLoaded copyWith({
    VirtualMachine? vm,
    List<VmStats>? statsHistory,
    VmStats? latestStats,
  }) {
    return VmDetailLoaded(
      vm: vm ?? this.vm,
      statsHistory: statsHistory ?? this.statsHistory,
      latestStats: latestStats ?? this.latestStats,
    );
  }

  @override
  List<Object?> get props => [vm, statsHistory, latestStats];
}

class VmDetailError extends VmDetailState {
  final String message;
  const VmDetailError(this.message);
  @override List<Object?> get props => [message];
}
