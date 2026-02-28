import 'package:equatable/equatable.dart';

abstract class VmDetailEvent extends Equatable {
  const VmDetailEvent();
  @override List<Object?> get props => [];
}

class LoadVmDetail extends VmDetailEvent {
  final String name;
  const LoadVmDetail(this.name);
  @override List<Object?> get props => [name];
}

class StopWatchingStats extends VmDetailEvent {
  const StopWatchingStats();
}
