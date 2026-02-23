#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-11"

echo "=========================================="
echo " Episode 11: Commercial UNIX Legacy on Linux"
echo "=========================================="
echo ""
echo "Working directory: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo ">>> Installing required tools..."
# ============================================================
apt-get update -qq && apt-get install -y -qq \
    bpfcc-tools \
    bpftrace \
    linux-tools-common \
    procps \
    stress-ng \
    sysstat \
    strace \
    > /dev/null 2>&1
echo "Installed: bpfcc-tools, bpftrace, stress-ng, sysstat, strace"

# ============================================================
echo ""
echo ">>> Exercise 1: Dynamic tracing with bpftrace (DTrace legacy)"
echo "    DTrace: dtrace -n 'syscall:::entry { @[execname] = count(); }'"
echo "    bpftrace equivalent:"
# ============================================================

cat > ex1_syscall_count.bt << 'BTSCRIPT'
#!/usr/bin/env bpftrace
// Count system calls per process name
// DTrace equivalent: dtrace -n 'syscall:::entry { @[execname] = count(); }'
tracepoint:raw_syscalls:sys_enter {
    @[comm] = count();
}
BTSCRIPT
chmod +x ex1_syscall_count.bt

cat > ex1_file_open.bt << 'BTSCRIPT'
#!/usr/bin/env bpftrace
// Trace file opens
// DTrace equivalent: dtrace -n 'syscall::open:entry { printf("%s %s", execname, copyinstr(arg0)); }'
tracepoint:syscalls:sys_enter_openat {
    printf("%s opened: %s\n", comm, str(args.filename));
}
BTSCRIPT
chmod +x ex1_file_open.bt

echo "Created: ex1_syscall_count.bt, ex1_file_open.bt"
echo ""
echo "Run with:"
echo "  bpftrace ex1_syscall_count.bt    # Ctrl+C to stop and see results"
echo "  bpftrace ex1_file_open.bt        # Ctrl+C to stop"

# ============================================================
echo ""
echo ">>> Exercise 2: I/O size histogram (DTrace aggregation legacy)"
echo "    DTrace: dtrace -n 'io:::start { @size = quantize(args[0]->b_bcount); }'"
echo "    bpftrace equivalent:"
# ============================================================

cat > ex2_io_histogram.bt << 'BTSCRIPT'
#!/usr/bin/env bpftrace
// I/O size histogram using power-of-2 buckets (same as DTrace quantize)
// DTrace equivalent: dtrace -n 'io:::start { @size = quantize(args[0]->b_bcount); }'
tracepoint:block:block_rq_issue {
    @io_size = hist(args.bytes);
}
BTSCRIPT
chmod +x ex2_io_histogram.bt

cat > ex2_generate_io.sh << 'SCRIPT'
#!/bin/bash
set -euo pipefail
echo "Generating I/O workload..."
dd if=/dev/zero of=/tmp/testfile bs=4K count=1000 2>/dev/null
sync
dd if=/tmp/testfile of=/dev/null bs=4K 2>/dev/null
rm -f /tmp/testfile
echo "I/O workload complete."
SCRIPT
chmod +x ex2_generate_io.sh

echo "Created: ex2_io_histogram.bt, ex2_generate_io.sh"
echo ""
echo "Run with:"
echo "  bpftrace ex2_io_histogram.bt &"
echo "  bash ex2_generate_io.sh"
echo "  kill %1   # Stop bpftrace to see histogram"

# ============================================================
echo ""
echo ">>> Exercise 3: Process lifecycle tracking"
# ============================================================

cat > ex3_process_lifecycle.bt << 'BTSCRIPT'
#!/usr/bin/env bpftrace
// Track process fork and exec events
tracepoint:sched:sched_process_exec {
    printf("exec: pid=%d comm=%s\n", pid, comm);
}

tracepoint:sched:sched_process_fork {
    printf("fork: parent=%d child=%d\n", args.parent_pid, args.child_pid);
}
BTSCRIPT
chmod +x ex3_process_lifecycle.bt

echo "Created: ex3_process_lifecycle.bt"
echo ""
echo "Run with:"
echo "  bpftrace ex3_process_lifecycle.bt &"
echo "  for i in \$(seq 1 5); do echo \"iteration \$i\" > /dev/null; done"
echo "  kill %1"

# ============================================================
echo ""
echo ">>> Exercise 4: DTrace vs bpftrace syntax comparison"
# ============================================================

cat > ex4_comparison.txt << 'TABLE'
======================================================================
 DTrace (Solaris) vs bpftrace (Linux) Syntax Comparison
======================================================================

 DTrace                          | bpftrace
---------------------------------|---------------------------------------
 syscall:::entry                 | tracepoint:raw_syscalls:sys_enter
 { @[execname] = count(); }      | { @[comm] = count(); }
---------------------------------|---------------------------------------
 syscall::read:entry             | tracepoint:syscalls:sys_enter_read
 { @bytes = quantize(arg2); }    | { @bytes = hist(args.count); }
---------------------------------|---------------------------------------
 pid$target:::entry              | uprobe:/path/to/binary:function
 { @[probefunc] = count(); }     | { @[func] = count(); }
---------------------------------|---------------------------------------
 profile:::tick-1sec             | interval:s:1
 { ... }                         | { ... }
---------------------------------|---------------------------------------
 fbt::vm_fault:entry             | kprobe:handle_mm_fault
 { ... }                         | { ... }
---------------------------------|---------------------------------------

Key Differences:
 - Language: DTrace uses D (C-like), bpftrace uses AWK/C hybrid
 - Safety: DTrace has kernel-level guarantees, bpftrace uses eBPF verifier
 - Probes: DTrace ~40,000, bpftrace 100,000+ (tracepoints + kprobe/uprobe)
 - Availability: DTrace on Solaris/macOS/FreeBSD, bpftrace on Linux 4.9+
======================================================================
TABLE

echo "Created: ex4_comparison.txt"
echo ""
echo "View with: cat ex4_comparison.txt"

# ============================================================
echo ""
echo "=========================================="
echo " Setup complete!"
echo "=========================================="
echo ""
echo "All exercise files are in: ${WORKDIR}"
echo ""
echo "Quick start:"
echo "  cd ${WORKDIR}"
echo "  bpftrace ex1_syscall_count.bt   # Trace syscalls (Ctrl+C to stop)"
echo ""
echo "Note: bpftrace requires root privileges."
echo "      Run inside: docker run -it --rm --privileged ubuntu:24.04 bash"
