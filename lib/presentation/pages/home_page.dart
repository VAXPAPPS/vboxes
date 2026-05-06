import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/vm_list/vm_list_bloc.dart';
import '../../application/vm_list/vm_list_event.dart';
import '../../application/vm_list/vm_list_state.dart';
import '../../application/create_vm/create_vm_bloc.dart';
import '../../core/di/injection_container.dart';
import '../../core/venom_layout.dart';
import '../../domain/entities/virtual_machine.dart';
import '../../domain/entities/vm_status.dart';
import '../widgets/vm_card.dart';
import 'create_vm_page.dart';
import 'vm_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VmListBloc>()..add(const LoadVms()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();
  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  VmStatus? _filter; // null = all

  @override
  Widget build(BuildContext context) {
    return VenomScaffold(
      title: 'VM Manager',
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────────────
          _Sidebar(
            selectedFilter: _filter,
            onFilterChanged: (f) => setState(() => _filter = f),
            onRefresh: () => context.read<VmListBloc>().add(const RefreshVms()),
            onCreateTap: () => _openCreate(context),
          ),

          // ── Main Content ─────────────────────────────────────────────────
          Expanded(child: _VmGrid(filter: _filter)),
        ],
      ),
    );
  }

  void _openCreate(BuildContext context) {
    final bloc = context.read<VmListBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<CreateVmBloc>(),
          child: CreateVmPage(onCreated: () => bloc.add(const LoadVms())),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final VmStatus? selectedFilter;
  final ValueChanged<VmStatus?> onFilterChanged;
  final VoidCallback onRefresh;
  final VoidCallback onCreateTap;

  const _Sidebar({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onRefresh,
    required this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 0, 0, 0),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Create button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _SidebarCreateButton(onTap: onCreateTap),
          ),

          const SizedBox(height: 20),
          _SidebarLabel('VIRTUAL MACHINES'),

          _FilterTile(
            label: 'All',
            icon: Icons.grid_view_rounded,
            selected: selectedFilter == null,
            onTap: () => onFilterChanged(null),
          ),
          _FilterTile(
            label: 'Running',
            icon: Icons.play_circle_outline_rounded,
            dotColor: const Color(0xFF34C759),
            selected: selectedFilter == VmStatus.running,
            onTap: () => onFilterChanged(VmStatus.running),
          ),
          _FilterTile(
            label: 'Stopped',
            icon: Icons.stop_circle_outlined,
            dotColor: Colors.white38,
            selected: selectedFilter == VmStatus.stopped,
            onTap: () => onFilterChanged(VmStatus.stopped),
          ),
          _FilterTile(
            label: 'Paused',
            icon: Icons.pause_circle_outline_rounded,
            dotColor: const Color(0xFFFFBD2E),
            selected: selectedFilter == VmStatus.paused,
            onTap: () => onFilterChanged(VmStatus.paused),
          ),

          const Spacer(),

          // Refresh button
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: onRefresh,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 16,
                      color: Colors.white54,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Refresh',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SidebarCreateButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SidebarCreateButton({required this.onTap});

  @override
  State<_SidebarCreateButton> createState() => _SidebarCreateButtonState();
}

class _SidebarCreateButtonState extends State<_SidebarCreateButton> {
  bool _hovered = false;
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [const Color(0xFF5E5CE6), const Color(0xFF3D3BAA)]
                  : [const Color(0xFF3D3BAA), const Color(0xFF2A2880)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF5E5CE6).withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 18, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'New VM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarLabel extends StatelessWidget {
  final String text;
  const _SidebarLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 16, bottom: 6, top: 2),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.white30,
        letterSpacing: 1,
      ),
    ),
  );
}

class _FilterTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? dotColor;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : Colors.white54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected ? Colors.white : Colors.white60,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (dotColor != null) ...[
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VM Grid
// ─────────────────────────────────────────────────────────────────────────────
class _VmGrid extends StatelessWidget {
  final VmStatus? filter;
  const _VmGrid({this.filter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VmListBloc, VmListState>(
      builder: (context, state) {
        if (state is VmListLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF5E5CE6)),
            ),
          );
        }

        if (state is VmListError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context.read<VmListBloc>().add(const LoadVms()),
          );
        }

        if (state is VmListLoaded) {
          final vms = filter == null
              ? state.vms
              : state.vms.where((v) => v.status == filter).toList();

          if (vms.isEmpty) {
            return _EmptyView(filter: filter);
          }

          return Column(
            children: [
              if (state.lastError != null)
                _ErrorBanner(message: state.lastError!),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.05,
                        ),
                    itemCount: vms.length,
                    itemBuilder: (context, i) {
                      final vm = vms[i];
                      return VmCard(
                        vm: vm,
                        isPending: state.actionPendingFor == vm.name,
                        onTap: () => _openDetail(context, vm),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _openDetail(BuildContext context, VirtualMachine vm) {
    final vmListBloc = context.read<VmListBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: vmListBloc,
          child: VmDetailPage(vmName: vm.name),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Color(0xFFFF5F57),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VmStatus? filter;
  const _EmptyView({this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filter == null
                ? Icons.computer_outlined
                : Icons.filter_list_off_rounded,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            filter == null
                ? 'No virtual machines\nPress "+ New VM" to get started'
                : 'No machines match this status',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFF5F57).withValues(alpha: 0.15),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: Color(0xFFFF5F57),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFF5F57), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
