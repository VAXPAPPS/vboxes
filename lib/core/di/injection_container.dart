import 'package:get_it/get_it.dart';
import '../../infrastructure/ffi/libqemu_bridge.dart';
import '../../data/datasources/qemu_ffi_datasource.dart';
import '../../data/repositories/vm_repository_impl.dart';
import '../../domain/repositories/vm_repository.dart';
import '../../domain/usecases/get_vms_usecase.dart';
import '../../domain/usecases/vm_lifecycle_usecases.dart';
import '../../domain/usecases/vm_management_usecases.dart';
import '../../domain/usecases/watch_vm_stats_usecase.dart';
import '../../application/vm_list/vm_list_bloc.dart';
import '../../application/vm_detail/vm_detail_bloc.dart';
import '../../application/create_vm/create_vm_bloc.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // ── Infrastructure ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<LibQemuBridge>(() => LibQemuBridge());
  sl.registerLazySingleton<QemuFfiDataSource>(
    () => QemuFfiDataSource(sl<LibQemuBridge>()),
  );

  // ── Repository ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<VmRepository>(
    () => VmRepositoryImpl(sl<QemuFfiDataSource>()),
  );

  // ── Use Cases ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetVmsUseCase(sl<VmRepository>()));
  sl.registerLazySingleton(() => StartVmUseCase(sl<VmRepository>()));
  sl.registerLazySingleton(() => StopVmUseCase(sl<VmRepository>()));
  sl.registerLazySingleton(() => ForceStopVmUseCase(sl<VmRepository>()));
  sl.registerLazySingleton(() => PauseVmUseCase(sl<VmRepository>()));
  sl.registerLazySingleton(() => ResumeVmUseCase(sl<VmRepository>()));
  sl.registerLazySingleton(() => CreateVmUseCase(sl<VmRepository>()));
  sl.registerLazySingleton(() => DeleteVmUseCase(sl<VmRepository>()));
  sl.registerLazySingleton(() => WatchVmStatsUseCase(sl<VmRepository>()));

  // ── BLoCs (factory = new instance per page) ─────────────────────────────────
  sl.registerFactory(
    () => VmListBloc(
      getVms:      sl<GetVmsUseCase>(),
      startVm:     sl<StartVmUseCase>(),
      stopVm:      sl<StopVmUseCase>(),
      forceStopVm: sl<ForceStopVmUseCase>(),
      pauseVm:     sl<PauseVmUseCase>(),
      resumeVm:    sl<ResumeVmUseCase>(),
      deleteVm:    sl<DeleteVmUseCase>(),
    ),
  );

  sl.registerFactory(
    () => VmDetailBloc(
      getVms:     sl<GetVmsUseCase>(),
      watchStats: sl<WatchVmStatsUseCase>(),
    ),
  );

  sl.registerFactory(
    () => CreateVmBloc(createVm: sl<CreateVmUseCase>()),
  );
}
