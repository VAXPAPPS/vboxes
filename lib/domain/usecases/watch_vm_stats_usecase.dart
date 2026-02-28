import '../entities/vm_stats.dart';
import '../repositories/vm_repository.dart';
import '../repositories/failures.dart';
import 'package:dartz/dartz.dart';

class WatchVmStatsUseCase {
  final VmRepository _repo;
  const WatchVmStatsUseCase(this._repo);

  Stream<Either<VmFailure, VmStats>> call(
    String name, {
    Duration interval = const Duration(seconds: 2),
  }) =>
      _repo.watchVmStats(name, interval: interval);
}
