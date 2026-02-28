/**
 * VAXP VM Manager — QEMU/KVM Bridge (C++)
 * Uses libvirt for maximum compatibility (same as  ).
 * Compiled to: libqemu_bridge.so
 */

#include <libvirt/libvirt.h>
#include <libvirt/virterror.h>
#include <cstring>
#include <cstdlib>
#include <string>
#include <sstream>

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

static virConnectPtr g_conn = nullptr;

/// Return a heap-allocated copy of a string.  Dart must call free_string().
static char* heap_str(const std::string& s) {
  char* result = static_cast<char*>(malloc(s.size() + 1));
  if (result) std::memcpy(result, s.c_str(), s.size() + 1);
  return result;
}

/// Quote a string for embedding inside JSON (minimal escaping).
static std::string json_str(const char* raw) {
  if (!raw) return "null";
  std::string out = "\"";
  for (const char* p = raw; *p; ++p) {
    switch (*p) {
      case '"':  out += "\\\""; break;
      case '\\': out += "\\\\"; break;
      case '\n': out += "\\n";  break;
      default:   out += *p;
    }
  }
  return out + "\"";
}

/// Open (or reuse) a libvirt connection.
static virConnectPtr get_conn() {
  if (!g_conn || virConnectIsAlive(g_conn) != 1) {
    if (g_conn) virConnectClose(g_conn);
    g_conn = virConnectOpen("qemu:///system");
  }
  return g_conn;
}

/// Map virDomainState → string name.
static const char* state_name(int state) {
  switch (state) {
    case VIR_DOMAIN_RUNNING:    return "running";
    case VIR_DOMAIN_PAUSED:     return "paused";
    case VIR_DOMAIN_SHUTDOWN:
    case VIR_DOMAIN_SHUTOFF:    return "stopped";
    case VIR_DOMAIN_CRASHED:    return "crashed";
    default:                    return "unknown";
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Public API  (extern "C" so Dart FFI can resolve symbols)
// ─────────────────────────────────────────────────────────────────────────────

extern "C" {

/**
 * list_vms()
 * Returns a JSON array of all domains (VMs), both active and inactive.
 * Example:
 * [{"id":"...","name":"...","status":"running","uuid":"...","xml":"..."},...]
 */
char* list_vms() {
  virConnectPtr conn = get_conn();
  if (!conn) return heap_str("{\"error\":\"Cannot connect to QEMU\"}");

  // Collect all domains: active + defined (inactive)
  virDomainPtr* active_domains = nullptr;
  int num_active = virConnectListAllDomains(conn, &active_domains,
                                             VIR_CONNECT_LIST_DOMAINS_ACTIVE |
                                             VIR_CONNECT_LIST_DOMAINS_INACTIVE);

  std::ostringstream json;
  json << "[";

  for (int i = 0; i < num_active; ++i) {
    virDomainPtr dom = active_domains[i];

    const char* name = virDomainGetName(dom);

    // State
    int state = 0, reason = 0;
    virDomainGetState(dom, &state, &reason, 0);

    // UUID
    char uuid_buf[VIR_UUID_STRING_BUFLEN];
    virDomainGetUUIDString(dom, uuid_buf);

    // Get XML descriptor for extra info
    char* xml_raw = virDomainGetXMLDesc(dom, 0);
    std::string xml_json = xml_raw ? json_str(xml_raw) : "null";
    if (xml_raw) free(xml_raw);

    // vCPU count
    int vcpus = virDomainGetVcpusFlags(dom, VIR_DOMAIN_VCPU_CURRENT);

    // Max memory (in KiB)
    unsigned long max_mem = virDomainGetMaxMemory(dom);

    if (i > 0) json << ",";
    json << "{"
         << "\"id\":"     << json_str(uuid_buf)      << ","
         << "\"name\":"   << json_str(name)           << ","
         << "\"status\":" << json_str(state_name(state)) << ","
         << "\"vcpus\":"  << vcpus                    << ","
         << "\"ramKib\":" << max_mem                  << ","
         << "\"xml\":"    << xml_json
         << "}";

    virDomainFree(dom);
  }

  json << "]";
  if (active_domains) free(active_domains);

  return heap_str(json.str());
}

/**
 * start_vm(name)
 * Starts (boots) a VM by name.
 * Returns 0 on success, -1 on error.
 */
int start_vm(const char* name) {
  virConnectPtr conn = get_conn();
  if (!conn) return -1;

  virDomainPtr dom = virDomainLookupByName(conn, name);
  if (!dom) return -1;

  int result = virDomainCreate(dom);
  virDomainFree(dom);
  return result;
}

/**
 * stop_vm(name)
 * Stops a VM (destroy = force power off, works reliably).
 */
int stop_vm(const char* name) {
  virConnectPtr conn = get_conn();
  if (!conn) return -1;

  virDomainPtr dom = virDomainLookupByName(conn, name);
  if (!dom) return -1;

  int result = virDomainDestroy(dom);
  virDomainFree(dom);
  return result;
}

/**
 * force_stop_vm(name)
 * Force-destroys a VM (like pulling the power plug).
 */
int force_stop_vm(const char* name) {
  virConnectPtr conn = get_conn();
  if (!conn) return -1;

  virDomainPtr dom = virDomainLookupByName(conn, name);
  if (!dom) return -1;

  int result = virDomainDestroy(dom);
  virDomainFree(dom);
  return result;
}

/**
 * pause_vm(name)
 * Suspends (pauses) a running VM.
 */
int pause_vm(const char* name) {
  virConnectPtr conn = get_conn();
  if (!conn) return -1;

  virDomainPtr dom = virDomainLookupByName(conn, name);
  if (!dom) return -1;

  int result = virDomainSuspend(dom);
  virDomainFree(dom);
  return result;
}

/**
 * resume_vm(name)
 * Resumes a paused VM.
 */
int resume_vm(const char* name) {
  virConnectPtr conn = get_conn();
  if (!conn) return -1;

  virDomainPtr dom = virDomainLookupByName(conn, name);
  if (!dom) return -1;

  int result = virDomainResume(dom);
  virDomainFree(dom);
  return result;
}

/**
 * get_default_disk_path(name)
 * Returns the default qcow2 disk path for a VM.
 */
char* get_default_disk_path(const char* vm_name) {
  // Use the standard libvirt images directory — libvirt-qemu user has access here
  std::string dir = "/var/lib/libvirt/images";
  std::string path = dir + "/" + std::string(vm_name) + ".qcow2";
  return heap_str(path);
}

/**
 * create_disk(path, size_gb)
 * Creates a qcow2 disk via libvirt storage pool API (runs as libvirt daemon, no permission issues).
 */
int create_disk(const char* path, int size_gb) {
  virConnectPtr conn = get_conn();
  if (!conn) return -1;

  // Use the default storage pool
  virStoragePoolPtr pool = virStoragePoolLookupByName(conn, "default");
  if (!pool) {
    // If no 'default' pool, try to define one pointing to /var/lib/libvirt/images
    const char* pool_xml =
      "<pool type='dir'>"
      "  <name>default</name>"
      "  <target><path>/var/lib/libvirt/images</path></target>"
      "</pool>";
    pool = virStoragePoolDefineXML(conn, pool_xml, 0);
    if (pool) {
      virStoragePoolCreate(pool, 0);
      virStoragePoolSetAutostart(pool, 1);
    }
  }
  if (!pool) return -1;

  // Ensure pool is active
  if (!virStoragePoolIsActive(pool)) {
    virStoragePoolCreate(pool, 0);
  }

  // Extract just the filename from the full path
  std::string full_path(path);
  std::string filename = full_path;
  size_t last_slash = full_path.rfind('/');
  if (last_slash != std::string::npos) {
    filename = full_path.substr(last_slash + 1);
  }

  unsigned long long size_bytes = (unsigned long long)size_gb * 1024ULL * 1024ULL * 1024ULL;

  std::ostringstream vol_xml;
  vol_xml << "<volume type='file'>"
          << "  <name>" << filename << "</name>"
          << "  <capacity unit='bytes'>" << size_bytes << "</capacity>"
          << "  <target>"
          << "    <format type='qcow2'/>"
          << "  </target>"
          << "</volume>";

  virStorageVolPtr vol = virStorageVolCreateXML(pool, vol_xml.str().c_str(), 0);
  virStoragePoolFree(pool);

  if (!vol) return -1;
  virStorageVolFree(vol);
  return 0;
}

/**
 * create_vm(xml_desc)
 * Defines AND starts a new VM from an XML descriptor.
 * Returns 0 on success, -1 on error.
 */
int create_vm(const char* xml_desc) {
  virConnectPtr conn = get_conn();
  if (!conn) return -1;

  // Define persistently
  virDomainPtr dom = virDomainDefineXML(conn, xml_desc);
  if (!dom) return -1;

  // Start it
  int result = virDomainCreate(dom);
  virDomainFree(dom);
  return result;
}

/**
 * delete_vm(name)
 * Undefines (removes) a VM definition. Disk image is NOT deleted.
 */
int delete_vm(const char* name) {
  virConnectPtr conn = get_conn();
  if (!conn) return -1;

  virDomainPtr dom = virDomainLookupByName(conn, name);
  if (!dom) return -1;

  // Force stop if running
  int state = 0, reason = 0;
  virDomainGetState(dom, &state, &reason, 0);
  if (state == VIR_DOMAIN_RUNNING) {
    virDomainDestroy(dom);
  }

  int result = virDomainUndefine(dom);
  virDomainFree(dom);
  return result;
}

/**
 * get_vm_stats(name)
 * Returns real-time stats as JSON: CPU %, memory used/total.
 */
char* get_vm_stats(const char* name) {
  virConnectPtr conn = get_conn();
  if (!conn) return heap_str("{\"error\":\"no connection\"}");

  virDomainPtr dom = virDomainLookupByName(conn, name);
  if (!dom) return heap_str("{\"error\":\"domain not found\"}");

  // Memory stats
  virDomainMemoryStatStruct mem_stats[VIR_DOMAIN_MEMORY_STAT_NR];
  int nr = virDomainMemoryStats(dom, mem_stats, VIR_DOMAIN_MEMORY_STAT_NR, 0);

  unsigned long long mem_total = 0;
  unsigned long long mem_unused = 0;

  for (int i = 0; i < nr; ++i) {
    if (mem_stats[i].tag == VIR_DOMAIN_MEMORY_STAT_ACTUAL_BALLOON)
      mem_total = mem_stats[i].val;
    if (mem_stats[i].tag == VIR_DOMAIN_MEMORY_STAT_UNUSED)
      mem_unused = mem_stats[i].val;
  }

  unsigned long long mem_used = (mem_total > mem_unused) ? (mem_total - mem_unused) : 0;

  // CPU stats (2 samples, 100ms apart — libvirt needs 2 readings for %)
  virDomainInfo info;
  virDomainGetInfo(dom, &info);
  unsigned long long cpu_time = info.cpuTime; // nanoseconds

  virDomainFree(dom);

  std::ostringstream json;
  json << "{"
       << "\"cpuTimeNs\":"  << cpu_time   << ","
       << "\"memTotalKib\":" << mem_total << ","
       << "\"memUsedKib\":"  << mem_used
       << "}";

  return heap_str(json.str());
}

/**
 * get_last_error()
 * Returns the last libvirt error message.
 */
char* get_last_error() {
  virErrorPtr err = virGetLastError();
  if (!err || !err->message) return heap_str("No error");
  return heap_str(err->message);
}

/**
 * open_vm_display(name)
 * Opens the VM's SPICE display using remote-viewer.
 * Returns 0 on success, -1 on error.
 */
int open_vm_display(const char* name) {
  virConnectPtr conn = get_conn();
  if (!conn) return -1;

  virDomainPtr dom = virDomainLookupByName(conn, name);
  if (!dom) return -1;

  char* xml = virDomainGetXMLDesc(dom, 0);
  virDomainFree(dom);
  if (!xml) return -1;

  // Parse SPICE port from XML: <graphics type='spice' port='5900' ...>
  std::string xml_str(xml);
  free(xml);

  // Find spice graphics port
  size_t spice_pos = xml_str.find("type='spice'");
  if (spice_pos == std::string::npos) {
    spice_pos = xml_str.find("type=\"spice\"");
  }
  if (spice_pos == std::string::npos) return -1;

  size_t port_pos = xml_str.find("port='", spice_pos);
  if (port_pos == std::string::npos) {
    port_pos = xml_str.find("port=\"", spice_pos);
  }
  if (port_pos == std::string::npos) return -1;

  port_pos += 6; // skip past "port='"
  size_t port_end = xml_str.find_first_of("'\"", port_pos);
  if (port_end == std::string::npos) return -1;

  std::string port = xml_str.substr(port_pos, port_end - port_pos);

  // Launch remote-viewer in background
  std::string cmd = "remote-viewer spice://127.0.0.1:" + port + " --title='" + std::string(name) + "' &";
  return system(cmd.c_str());
}

/**
 * free_string(ptr)
 * Must be called from Dart to release memory returned by C++ functions.
 */
void free_string(char* ptr) {
  if (ptr) free(ptr);
}

} // extern "C"
