import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/vm_detail/vm_detail_bloc.dart';
import '../../application/vm_detail/vm_detail_event.dart';
import '../../application/vm_detail/vm_detail_state.dart';
import '../../application/vm_list/vm_list_bloc.dart';
import '../../application/vm_list/vm_list_event.dart';
import '../../core/di/injection_container.dart';
import '../../domain/repositories/vm_repository.dart';
import '../../core/venom_layout.dart';
import '../../core/theme/vaxp_theme.dart';
import '../../domain/entities/vm_stats.dart';
import '../widgets/resource_chart.dart';

class VmDetailPage extends StatelessWidget {
  final String vmName;
  const VmDetailPage({super.key, required this.vmName});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<VmDetailBloc>()..add(LoadVmDetail(vmName)),
        ),
      ],
      child: _DetailView(vmName: vmName),
    );
  }
}

class _DetailView extends StatelessWidget {
  final String vmName;
  const _DetailView({required this.vmName});

  @override
  Widget build(BuildContext context) {
    return VenomScaffold(
      title: vmName,
      body: BlocBuilder<VmDetailBloc, VmDetailState>(
        builder: (context, state) {
          if (state is VmDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF5E5CE6)),
              ),
            );
          }

          if (state is VmDetailError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: Colors.white70)),
            );
          }

          if (state is VmDetailLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header card ─────────────────────────────────────────
                  _HeaderCard(state: state),
                  const SizedBox(height: 20),

                  // ── Stats charts ────────────────────────────────────────
                  if (state.vm.status.isRunning) ...[
                    _StatsSection(state: state),
                    const SizedBox(height: 20),
                  ],

                  // ── Info grid ───────────────────────────────────────────
                  _InfoGrid(state: state),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final VmDetailLoaded state;
  const _HeaderCard({required this.state});

  Color get _statusColor {
    switch (state.vm.status) {
      case _ when state.vm.status.isRunning: return const Color(0xFF34C759);
      case _ when state.vm.status.isPaused:  return const Color(0xFFFFBD2E);
      default:                               return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmListBloc = context.read<VmListBloc>();
    return VaxpGlass(
      blur: 18,
      opacity: 0.15,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.computer_rounded, size: 28, color: _statusColor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.vm.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.vm.status.name,
                        style: TextStyle(color: _statusColor, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Quick actions
            Row(
              children: [
                if (state.vm.status.isRunning)
                  _QuickAction(
                    icon: Icons.desktop_windows_rounded,
                    label: 'عرض الشاشة',
                    color: const Color(0xFF5E5CE6),
                    onTap: () async {
                      final repo = sl<VmRepository>();
                      await repo.openVmDisplay(state.vm.name);
                    },
                  ),
                if (state.vm.status.canStart)
                  _QuickAction(
                    icon: Icons.play_arrow_rounded,
                    label: 'تشغيل',
                    color: const Color(0xFF34C759),
                    onTap: () async {
                      final repo = sl<VmRepository>();
                      await repo.startVm(state.vm.name);
                      if (context.mounted) {
                        context.read<VmDetailBloc>().add(LoadVmDetail(state.vm.name));
                        vmListBloc.add(const RefreshVms());
                      }
                    },
                  ),
                if (state.vm.status.canStop)
                  _QuickAction(
                    icon: Icons.stop_rounded,
                    label: 'إيقاف',
                    color: const Color(0xFFFF5F57),
                    onTap: () async {
                      final repo = sl<VmRepository>();
                      await repo.stopVm(state.vm.name);
                      if (context.mounted) {
                        context.read<VmDetailBloc>().add(LoadVmDetail(state.vm.name));
                        vmListBloc.add(const RefreshVms());
                      }
                    },
                  ),
                if (state.vm.status.canPause)
                  _QuickAction(
                    icon: Icons.pause_rounded,
                    label: 'تعليق',
                    color: const Color(0xFFFFBD2E),
                    onTap: () async {
                      final repo = sl<VmRepository>();
                      await repo.pauseVm(state.vm.name);
                      if (context.mounted) {
                        context.read<VmDetailBloc>().add(LoadVmDetail(state.vm.name));
                        vmListBloc.add(const RefreshVms());
                      }
                    },
                  ),
                if (state.vm.status.canResume)
                  _QuickAction(
                    icon: Icons.play_arrow_rounded,
                    label: 'استئناف',
                    color: const Color(0xFFFFBD2E),
                    onTap: () async {
                      final repo = sl<VmRepository>();
                      await repo.resumeVm(state.vm.name);
                      if (context.mounted) {
                        context.read<VmDetailBloc>().add(LoadVmDetail(state.vm.name));
                        vmListBloc.add(const RefreshVms());
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8),
    child: Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    ),
  );
}

class _StatsSection extends StatelessWidget {
  final VmDetailLoaded state;
  const _StatsSection({required this.state});

  List<double> _memHistory(List<VmStats> history) =>
      history.map((s) => s.memUsedPercent).toList();

  @override
  Widget build(BuildContext context) {
    final stats = state.latestStats;
    return VaxpGlass(
      blur: 18,
      opacity: 0.12,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'موارد الآلة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ResourceChart(
              label: 'الذاكرة (RAM)',
              values: _memHistory(state.statsHistory),
              color: const Color(0xFF5E5CE6),
              currentValue: stats?.memUsedPercent ?? 0.0,
            ),
            if (stats != null) ...[
              const SizedBox(height: 6),
              Text(
                '${stats.memUsedMb} MB / ${stats.memTotalMb} MB',
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final VmDetailLoaded state;
  const _InfoGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final vm = state.vm;
    return VaxpGlass(
      blur: 18,
      opacity: 0.12,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          spacing: 32,
          runSpacing: 16,
          children: [
            _InfoItem(label: 'UUID', value: vm.id),
            _InfoItem(label: 'نظام التشغيل', value: vm.osType),
            _InfoItem(label: 'vCPU', value: '${vm.vcpus} نواة'),
            _InfoItem(label: 'ذاكرة', value: '${vm.ramMb} MB (${vm.ramGb} GB)'),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
