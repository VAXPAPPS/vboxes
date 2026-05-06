import 'package:flutter/material.dart';
import '../../domain/entities/virtual_machine.dart';
import '../../domain/entities/vm_status.dart';
import '../../core/theme/vaxp_theme.dart';
import '../../application/vm_list/vm_list_bloc.dart';
import '../../application/vm_list/vm_list_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VmCard extends StatefulWidget {
  final VirtualMachine vm;
  final bool isPending;
  final VoidCallback onTap;

  const VmCard({
    super.key,
    required this.vm,
    required this.onTap,
    this.isPending = false,
  });

  @override
  State<VmCard> createState() => _VmCardState();
}

class _VmCardState extends State<VmCard> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.vm.status) {
      case VmStatus.running:
        return const Color(0xFF34C759);
      case VmStatus.paused:
        return const Color(0xFFFFBD2E);
      case VmStatus.crashed:
        return const Color(0xFFFF5F57);
      default:
        return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..scaleByDouble(
              _hovered ? 1.02 : 1.0,
              _hovered ? 1.02 : 1.0,
              1.0,
              1.0,
            ),
          child: VaxpGlass(
            blur: _hovered ? 22 : 16,
            opacity: _hovered ? 0.2 : 0.12,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ──────────────────────────────────────────────
                  Row(
                    children: [
                      // Status dot with pulse for running
                      if (widget.vm.status == VmStatus.running)
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, __) => Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(
                                alpha: _pulse.value,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _statusColor.withValues(
                                    alpha: 0.5 * _pulse.value,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.vm.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.isPending)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white54),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── OS Badge ────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.vm.osType,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Specs row ───────────────────────────────────────────────
                  Row(
                    children: [
                      _SpecChip(
                        icon: Icons.memory,
                        label: '${widget.vm.vcpus} vCPU',
                      ),
                      const SizedBox(width: 8),
                      _SpecChip(
                        icon: Icons.storage,
                        label: '${widget.vm.ramMb} MB',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Action buttons ──────────────────────────────────────────
                  _ActionBar(vm: widget.vm, isPending: widget.isPending),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white54),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  final VirtualMachine vm;
  final bool isPending;
  const _ActionBar({required this.vm, required this.isPending});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VmListBloc>();

    return Row(
      children: [
        if (vm.status.canStart)
          _ActionButton(
            icon: Icons.play_arrow_rounded,
            color: const Color(0xFF34C759),
            tooltip: 'Start',
            enabled: !isPending,
            onTap: () => bloc.add(StartVm(vm.name)),
          ),
        if (vm.status.canStop) ...[
          _ActionButton(
            icon: Icons.stop_rounded,
            color: const Color(0xFFFF5F57),
            tooltip: 'Stop',
            enabled: !isPending,
            onTap: () => bloc.add(StopVm(vm.name)),
          ),
          _ActionButton(
            icon: Icons.pause_rounded,
            color: const Color(0xFFFFBD2E),
            tooltip: 'Pause',
            enabled: !isPending,
            onTap: () => bloc.add(PauseVm(vm.name)),
          ),
        ],
        if (vm.status.canResume)
          _ActionButton(
            icon: Icons.play_arrow_rounded,
            color: const Color(0xFFFFBD2E),
            tooltip: 'Resume',
            enabled: !isPending,
            onTap: () => bloc.add(ResumeVm(vm.name)),
          ),
        const Spacer(),
        _ActionButton(
          icon: Icons.delete_outline_rounded,
          color: Colors.white38,
          tooltip: 'Delete',
          enabled: !isPending,
          onTap: () => _showDeleteDialog(context, bloc),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, VmListBloc bloc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromARGB(230, 20, 20, 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete ${vm.name}?',
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Only the VM definition will be deleted. Disk files will not be removed.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(DeleteVm(vm.name));
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF5F57)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: enabled
                ? color.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: enabled ? color : Colors.white24),
        ),
      ),
    );
  }
}
