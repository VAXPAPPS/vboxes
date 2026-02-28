class VmConsts {
  /// Path to the compiled shared library.
  /// Build it with: cd ffi && cmake -B build && cmake --build build
  static const libLocalPath  = 'libqemu_bridge.so';
  static const libSystemPath = '/usr/local/lib/libqemu_bridge.so';

  // VM defaults
  static const defaultVcpus = 2;
  static const defaultRamMb = 2048;  // 2 GB
  static const minRamMb     = 256;
  static const maxRamMb     = 65536; // 64 GB
  static const maxVcpus     = 16;

  // Stats polling interval
  static const statsIntervalSeconds = 2;

  // History points for charts
  static const chartHistoryPoints = 30;
}
