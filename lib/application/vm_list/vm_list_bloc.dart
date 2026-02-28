import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_vms_usecase.dart';
import '../../domain/usecases/vm_lifecycle_usecases.dart';
import '../../domain/usecases/vm_management_usecases.dart';
import 'vm_list_event.dart';
import 'vm_list_state.dart';

class VmListBloc extends Bloc<VmListEvent, VmListState> {
  final GetVmsUseCase _getVms;
  final StartVmUseCase _startVm;
  final StopVmUseCase _stopVm;
  final ForceStopVmUseCase _forceStopVm;
  final PauseVmUseCase _pauseVm;
  final ResumeVmUseCase _resumeVm;
  final DeleteVmUseCase _deleteVm;

  VmListBloc({
    required GetVmsUseCase getVms,
    required StartVmUseCase startVm,
    required StopVmUseCase stopVm,
    required ForceStopVmUseCase forceStopVm,
    required PauseVmUseCase pauseVm,
    required ResumeVmUseCase resumeVm,
    required DeleteVmUseCase deleteVm,
  })  : _getVms = getVms,
        _startVm = startVm,
        _stopVm = stopVm,
        _forceStopVm = forceStopVm,
        _pauseVm = pauseVm,
        _resumeVm = resumeVm,
        _deleteVm = deleteVm,
        super(const VmListInitial()) {
    on<LoadVms>(_onLoad);
    on<RefreshVms>(_onRefresh);
    on<StartVm>(_onStart);
    on<StopVm>(_onStop);
    on<ForceStopVm>(_onForceStop);
    on<PauseVm>(_onPause);
    on<ResumeVm>(_onResume);
    on<DeleteVm>(_onDelete);
  }

  Future<void> _onLoad(LoadVms event, Emitter<VmListState> emit) async {
    emit(const VmListLoading());
    final result = await _getVms();
    result.fold(
      (failure) => emit(VmListError(failure.message)),
      (vms)     => emit(VmListLoaded(vms: vms)),
    );
  }

  Future<void> _onRefresh(RefreshVms event, Emitter<VmListState> emit) async {
    // Don't show full loading — keep existing list visible
    final current = state;
    final result = await _getVms();
    result.fold(
      (f) {
        if (current is VmListLoaded) {
          emit(current.copyWith(lastError: f.message));
        } else {
          emit(VmListError(f.message));
        }
      },
      (vms) => emit(VmListLoaded(vms: vms)),
    );
  }

  Future<void> _onStart(StartVm event, Emitter<VmListState> emit) async {
    await _performAction(event.name, emit, () => _startVm(event.name));
  }

  Future<void> _onStop(StopVm event, Emitter<VmListState> emit) async {
    await _performAction(event.name, emit, () => _stopVm(event.name));
  }

  Future<void> _onForceStop(ForceStopVm event, Emitter<VmListState> emit) async {
    await _performAction(event.name, emit, () => _forceStopVm(event.name));
  }

  Future<void> _onPause(PauseVm event, Emitter<VmListState> emit) async {
    await _performAction(event.name, emit, () => _pauseVm(event.name));
  }

  Future<void> _onResume(ResumeVm event, Emitter<VmListState> emit) async {
    await _performAction(event.name, emit, () => _resumeVm(event.name));
  }

  Future<void> _onDelete(DeleteVm event, Emitter<VmListState> emit) async {
    await _performAction(event.name, emit, () => _deleteVm(event.name));
  }

  /// Generic helper: sets pending indicator, calls action, refreshes list.
  Future<void> _performAction(
    String vmName,
    Emitter<VmListState> emit,
    Future<dynamic> Function() action,
  ) async {
    final current = state;
    if (current is VmListLoaded) {
      emit(current.copyWith(actionPendingFor: vmName, clearError: true));
    }

    final result = await action();

    // Refresh the list after action
    final refreshResult = await _getVms();
    refreshResult.fold(
      (f) {
        if (current is VmListLoaded) {
          emit(current.copyWith(clearPending: true, lastError: f.message));
        }
      },
      (vms) {
        final err = result?.isLeft() == true
            ? (result).fold((f) => f.message, (_) => null)
            : null;
        emit(VmListLoaded(vms: vms, lastError: err));
      },
    );
  }
}
