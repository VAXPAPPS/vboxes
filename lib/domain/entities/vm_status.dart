enum VmStatus {
  running,
  stopped,
  paused,
  crashed,
  unknown;

  static VmStatus fromString(String raw) {
    return VmStatus.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => VmStatus.unknown,
    );
  }

  bool get isRunning  => this == VmStatus.running;
  bool get isStopped  => this == VmStatus.stopped;
  bool get isPaused   => this == VmStatus.paused;
  bool get canStart   => this == VmStatus.stopped || this == VmStatus.crashed;
  bool get canStop    => this == VmStatus.running;
  bool get canPause   => this == VmStatus.running;
  bool get canResume  => this == VmStatus.paused;
}
