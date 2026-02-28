import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../application/create_vm/create_vm_bloc.dart';
import '../../application/create_vm/create_vm_event.dart';
import '../../application/create_vm/create_vm_state.dart';
import '../../core/venom_layout.dart';
import '../../core/theme/vaxp_theme.dart';

class CreateVmPage extends StatelessWidget {
  final VoidCallback onCreated;
  const CreateVmPage({super.key, required this.onCreated});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateVmBloc, CreateVmState>(
      listener: (context, state) {
        if (state is CreateVmSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم إنشاء "${state.vmName}" بنجاح'),
              backgroundColor: const Color(0xFF34C759).withOpacity(0.9),
            ),
          );
          onCreated();
          Navigator.of(context).pop();
        }
        if (state is CreateVmFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: const Color(0xFFFF5F57).withOpacity(0.9),
            ),
          );
        }
      },
      child: VenomScaffold(
        title: 'آلة افتراضية جديدة',
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: VaxpGlass(
              blur: 20,
              opacity: 0.18,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: SizedBox(
                  width: 520,
                  child: _CreateForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateForm extends StatefulWidget {
  @override
  State<_CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<_CreateForm> {
  final _nameCtrl    = TextEditingController();
  final _isoCtrl     = TextEditingController();

  static const _osOptions = ['Linux', 'Ubuntu/Debian', 'Fedora/RHEL', 'Windows', 'Other'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _isoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateVmBloc, CreateVmState>(
      builder: (context, state) {
        final form = state is CreateVmInitial ? state : null;
        final isSubmitting = state is CreateVmSubmitting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'إنشاء آلة افتراضية',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'تعمل على QEMU/KVM عبر libvirt',
              style: TextStyle(fontSize: 13, color: Colors.white54),
            ),
            const SizedBox(height: 28),

            // Name
            _FieldLabel('اسم الآلة'),
            _GlassField(
              controller: _nameCtrl,
              hint: 'مثال: VAXP-OS',
              error: form?.nameError,
              onChanged: (v) => context.read<CreateVmBloc>().add(UpdateVmName(v)),
            ),
            const SizedBox(height: 16),

            // OS
            _FieldLabel('نظام التشغيل'),
            _OsDropdown(
              value: form?.osType ?? 'Linux',
              options: _osOptions,
              onChanged: (v) => context.read<CreateVmBloc>().add(UpdateOsType(v)),
            ),
            const SizedBox(height: 16),

            // CPU & RAM row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('عدد المعالجات (vCPU)'),
                      _StepperField(
                        value: form?.vcpus ?? 2,
                        min: 1,
                        max: 16,
                        onChanged: (v) => context.read<CreateVmBloc>().add(UpdateVcpus(v)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('الذاكرة (MB)'),
                      _StepperField(
                        value: form?.ramMb ?? 2048,
                        min: 256,
                        max: 65536,
                        step: 256,
                        onChanged: (v) => context.read<CreateVmBloc>().add(UpdateRamMb(v)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Disk size
            _FieldLabel('حجم القرص الافتراضي (GB)'),
            _SliderField(
              value: (form?.diskSizeGb ?? 20).toDouble(),
              min: 5,
              max: 500,
              onChanged: (v) => context.read<CreateVmBloc>().add(UpdateDiskSizeGb(v.toInt())),
            ),
            const SizedBox(height: 16),

            // ISO path
            _FieldLabel('مسار ملف التثبيت ISO (اختياري)'),
            _FilePickerField(
              controller: _isoCtrl,
              hint: '/home/user/vaxp-os.iso',
              allowedExtensions: const ['iso'],
              onChanged: (v) => context.read<CreateVmBloc>().add(UpdateIsoPath(v)),
            ),
            const SizedBox(height: 28),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 48,
              child: _SubmitButton(
                enabled: form?.isValid == true && !isSubmitting,
                isLoading: isSubmitting,
                onTap: () => context.read<CreateVmBloc>().add(const SubmitCreateVm()),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
  );
}

class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? error;
  final ValueChanged<String> onChanged;

  const _GlassField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        errorText: error,
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5E5CE6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5F57)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _OsDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _OsDropdown({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: const Color(0xFF1C1C2E),
        underline: const SizedBox.shrink(),
        style: const TextStyle(color: Colors.white),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const _StepperField({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          _StepBtn(icon: Icons.remove, onTap: value > min ? () => onChanged(value - step) : null),
          Expanded(
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: value < max ? () => onChanged(value + step) : null),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 44,
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: onTap != null ? Colors.white70 : Colors.white24),
    ),
  );
}

class _SubmitButton extends StatefulWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;
  const _SubmitButton({required this.enabled, required this.isLoading, required this.onTap});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.enabled
                  ? (_hovered ? [const Color(0xFF7B79FF), const Color(0xFF5E5CE6)] : [const Color(0xFF5E5CE6), const Color(0xFF3D3BAA)])
                  : [Colors.white12, Colors.white10],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.enabled && _hovered
                ? [BoxShadow(color: const Color(0xFF5E5CE6).withOpacity(0.5), blurRadius: 16)]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('إنشاء الآلة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _FilePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? error;
  final ValueChanged<String> onChanged;
  final List<String>? allowedExtensions;

  const _FilePickerField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    // ignore: unused_element_parameter
    this.error,
    this.allowedExtensions,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        errorText: error,
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5E5CE6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5F57)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: IconButton(
            icon: const Icon(Icons.folder_open_rounded, color: Colors.white54),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: allowedExtensions != null ? FileType.custom : FileType.any,
                allowedExtensions: allowedExtensions,
              );
              if (result != null && result.files.single.path != null) {
                controller.text = result.files.single.path!;
                onChanged(controller.text);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Text(
            '${value.toInt()} GB',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF5E5CE6),
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                overlayColor: const Color(0xFF5E5CE6).withOpacity(0.2),
                trackHeight: 4.0,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min) ~/ 5, // steps of 5GB
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

