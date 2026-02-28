import 'package:equatable/equatable.dart';

abstract class VmListEvent extends Equatable {
  const VmListEvent();
  @override
  List<Object?> get props => [];
}

class LoadVms extends VmListEvent {
  const LoadVms();
}

class RefreshVms extends VmListEvent {
  const RefreshVms();
}

class StartVm extends VmListEvent {
  final String name;
  const StartVm(this.name);
  @override List<Object?> get props => [name];
}

class StopVm extends VmListEvent {
  final String name;
  const StopVm(this.name);
  @override List<Object?> get props => [name];
}

class ForceStopVm extends VmListEvent {
  final String name;
  const ForceStopVm(this.name);
  @override List<Object?> get props => [name];
}

class PauseVm extends VmListEvent {
  final String name;
  const PauseVm(this.name);
  @override List<Object?> get props => [name];
}

class ResumeVm extends VmListEvent {
  final String name;
  const ResumeVm(this.name);
  @override List<Object?> get props => [name];
}

class DeleteVm extends VmListEvent {
  final String name;
  const DeleteVm(this.name);
  @override List<Object?> get props => [name];
}
