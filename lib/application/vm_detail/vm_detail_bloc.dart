import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/watch_vm_stats_usecase.dart';
import '../../domain/usecases/get_vms_usecase.dart';
import '../../domain/entities/vm_stats.dart';
import 'vm_detail_event.dart';
import 'vm_detail_state.dart';

class VmDetailBloc extends Bloc<VmDetailEvent, VmDetailState> {
  final GetVmsUseCase _getVms;
  final WatchVmStatsUseCase _watchStats;
  StreamSubscription<dynamic>? _statsSub;

  static const int _maxHistoryPoints = 30;

  VmDetailBloc({
    required GetVmsUseCase getVms,
    required WatchVmStatsUseCase watchStats,
  })  : _getVms = getVms,
        _watchStats = watchStats,
        super(const VmDetailInitial()) {
    on<LoadVmDetail>(_onLoad);
    on<StopWatchingStats>(_onStopWatching);
    on<_StatsReceived>(_onStatsReceived);
  }

  void _onStatsReceived(_StatsReceived event, Emitter<VmDetailState> emit) {
    final current = state;
    if (current is VmDetailLoaded) {
      emit(VmDetailLoaded(
        vm: current.vm,
        latestStats: event.stats,
        statsHistory: event.history,
      ));
    }
  }

  Future<void> _onLoad(LoadVmDetail event, Emitter<VmDetailState> emit) async {
    emit(const VmDetailLoading());

    // Cancel previous subscription
    await _statsSub?.cancel();

    // Load VM info
    final result = await _getVms();
    result.fold(
      (f)   => emit(VmDetailError(f.message)),
      (vms) {
        final vm = vms.where((v) => v.name == event.name).firstOrNull;
        if (vm == null) {
          emit(VmDetailError('VM "${event.name}" not found'));
          return;
        }
        final loaded = VmDetailLoaded(vm: vm);
        emit(loaded);

        // Start stats polling only if VM is running
        if (vm.status.isRunning) {
          _statsSub = _watchStats(event.name).listen((statsResult) {
            if (isClosed) return;
            statsResult.fold(
              (_) {}, // ignore stats errors silently
              (stats) {
                final current = state;
                if (current is VmDetailLoaded) {
                  final history = [...current.statsHistory, stats];
                  final trimmed = history.length > _maxHistoryPoints
                      ? history.sublist(history.length - _maxHistoryPoints)
                      : history;
                  add(_StatsReceived(stats, trimmed));
                }
              },
            );
          });
        }
      },
    );
  }

  Future<void> _onStopWatching(
    StopWatchingStats event,
    Emitter<VmDetailState> emit,
  ) async {
    await _statsSub?.cancel();
    _statsSub = null;
  }

  @override
  Future<void> close() async {
    await _statsSub?.cancel();
    return super.close();
  }
}

// Internal event for stats stream updates
class _StatsReceived extends VmDetailEvent {
  final VmStats stats;
  final List<VmStats> history;
  const _StatsReceived(this.stats, this.history);
}
