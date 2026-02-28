import 'package:equatable/equatable.dart';
import '../../domain/entities/virtual_machine.dart';

abstract class VmListState extends Equatable {
  const VmListState();
  @override List<Object?> get props => [];
}

class VmListInitial extends VmListState {
  const VmListInitial();
}

class VmListLoading extends VmListState {
  const VmListLoading();
}

class VmListLoaded extends VmListState {
  final List<VirtualMachine> vms;
  final String? actionPendingFor; // name of VM with pending action
  final String? lastError;

  const VmListLoaded({
    required this.vms,
    this.actionPendingFor,
    this.lastError,
  });

  VmListLoaded copyWith({
    List<VirtualMachine>? vms,
    String? actionPendingFor,
    String? lastError,
    bool clearPending = false,
    bool clearError = false,
  }) {
    return VmListLoaded(
      vms: vms ?? this.vms,
      actionPendingFor: clearPending ? null : (actionPendingFor ?? this.actionPendingFor),
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }

  @override
  List<Object?> get props => [vms, actionPendingFor, lastError];
}

class VmListError extends VmListState {
  final String message;
  const VmListError(this.message);
  @override List<Object?> get props => [message];
}
