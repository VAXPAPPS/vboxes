import 'package:equatable/equatable.dart';

class VmCreateParams extends Equatable {
  final String name;
  final int vcpus;
  final int ramMb;
  final int diskSizeGb;
  final String isoPath;
  final String osType;
  final String architecture;

  const VmCreateParams({
    required this.name,
    required this.vcpus,
    required this.ramMb,
    required this.diskSizeGb,
    this.isoPath = '',
    this.osType = 'hvm',
    this.architecture = 'x86_64',
  });

  /// Generate a libvirt-compatible XML descriptor for this VM.
  String toLibvirtXml(String generatedDiskPath) {
    final ramKib = ramMb * 1024;
    return '''
<domain type='kvm'>
  <name>$name</name>
  <memory unit='KiB'>$ramKib</memory>
  <currentMemory unit='KiB'>$ramKib</currentMemory>
  <vcpu placement='static'>$vcpus</vcpu>
  <os>
    <type arch='$architecture' machine='pc-i440fx-2.9'>$osType</type>
    <boot dev='hd'/>
    ${isoPath.isNotEmpty ? "<boot dev='cdrom'/>" : ''}
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu mode='host-model' check='partial'/>
  <clock offset='utc'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
  </clock>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='$generatedDiskPath'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    ${isoPath.isNotEmpty ? """
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='$isoPath'/>
      <target dev='sdb' bus='sata'/>
      <readonly/>
    </disk>""" : ''}
    <interface type='network'>
      <source network='default'/>
      <model type='virtio'/>
    </interface>
    <graphics type='spice' autoport='yes'>
      <listen type='address'/>
      <image compression='off'/>
    </graphics>
    <video>
      <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1' primary='yes'/>
    </video>
    <channel type='spicevmc'>
      <target type='virtio' name='com.redhat.spice.0'/>
    </channel>
    <memballoon model='virtio'/>
    <rng model='virtio'>
      <backend model='random'>/dev/urandom</backend>
    </rng>
  </devices>
  <seclabel type='none'/>
</domain>''';
  }

  @override
  List<Object?> get props => [name, vcpus, ramMb, diskSizeGb, isoPath, osType];
}
