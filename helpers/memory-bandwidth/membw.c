#define _GNU_SOURCE

#include <errno.h>
#include <sched.h>
#include <signal.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/prctl.h>
#include <sys/utsname.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define BUFFER_BYTES ((size_t)1 << 28)
#define PASS_COUNT 128
#define BYTES_TOUCHED ((uint64_t)BUFFER_BYTES * PASS_COUNT)

struct worker_result {
  uint64_t bytes;
  uint64_t elapsed_ns;
  uint64_t sum;
  int status;
  char err[160];
};

struct shared {
  atomic_uint arrived;
  atomic_uint go;
  atomic_uint failed;
  struct worker_result results[CPU_SETSIZE];
};

static uint64_t *buffer;
static struct shared *shared;
static int cpu_list[CPU_SETSIZE];
static int ncpu;

/* Live children, read from the signal handler. */
static volatile sig_atomic_t child_pids[CPU_SETSIZE];
static volatile sig_atomic_t child_count;
static pid_t parent_pid;

/* Spin hint while the barrier flag is clear. PAUSE on x86. YIELD on ARM,
   with a compiler barrier so the atomic load in the waiter stays in the loop. */
static void cpu_relax(void) {
#if defined(__x86_64__) || defined(__i386__)
  __asm__ __volatile__("pause");
#elif defined(__aarch64__)
  __asm__ __volatile__("yield" ::: "memory");
#endif
}

static void kill_live_children(void) {
  int n = (int)child_count;
  for (int i = 0; i < n; i++) {
    pid_t pid = (pid_t)child_pids[i];
    if (pid > 0) kill(pid, SIGKILL);
  }
}

static void wait_live_children(void) {
  int n = (int)child_count;
  for (int i = 0; i < n; i++) {
    pid_t pid = (pid_t)child_pids[i];
    if (pid > 0) {
      waitpid(pid, NULL, 0);
      child_pids[i] = 0;
    }
  }
  child_count = 0;
}

static void on_signal(int sig) {
  if (getpid() != parent_pid) _exit(128 + sig);
  kill_live_children();
  wait_live_children();
  _exit(128 + sig);
}

static void die(const char *what) {
  fprintf(stderr, "%s: %s\n", what, strerror(errno));
  exit(1);
}

static void install_signals(void) {
  struct sigaction sa;
  memset(&sa, 0, sizeof sa);
  sa.sa_handler = on_signal;
  if (sigaction(SIGINT, &sa, NULL) != 0) die("sigaction");
  if (sigaction(SIGTERM, &sa, NULL) != 0) die("sigaction");
}

static void read_model(char *out, size_t outlen) {
  out[0] = '\0';
  FILE *fp = fopen("/proc/cpuinfo", "r");
  if (fp) {
    char line[512];
    while (fgets(line, sizeof line, fp)) {
      if (strncmp(line, "model name", 10) != 0) continue;
      char *value = strchr(line, ':');
      if (!value) continue;
      value++;
      while (*value == ' ' || *value == '\t') value++;
      size_t len = strlen(value);
      while (len > 0 && (value[len - 1] == '\n' || value[len - 1] == '\r'))
        value[--len] = '\0';
      if (len == 0) continue;
      snprintf(out, outlen, "%s", value);
      break;
    }
    fclose(fp);
  }
  if (out[0] == '\0') {
    struct utsname uts;
    if (uname(&uts) == 0)
      snprintf(out, outlen, "%s", uts.machine);
    else
      snprintf(out, outlen, "unknown");
  }
}

static void read_affinity(void) {
  cpu_set_t mask;
  if (sched_getaffinity(0, sizeof mask, &mask) != 0) die("sched_getaffinity");

  int counted = CPU_COUNT(&mask);
  ncpu = 0;
  for (int cpu = 0; cpu < CPU_SETSIZE; cpu++) {
    if (!CPU_ISSET(cpu, &mask)) continue;
    cpu_list[ncpu++] = cpu;
  }
  if (ncpu <= 0 || ncpu != counted) {
    fprintf(stderr, "sched_getaffinity: empty or unreadable mask\n");
    exit(1);
  }
}

static int rung_counts(int *out) {
  int n = 0;
  for (int count = 1; count <= ncpu; count *= 2) {
    out[n++] = count;
    if (count > ncpu / 2) break;
  }
  if (out[n - 1] != ncpu) out[n++] = ncpu;
  return n;
}

/* MAP_SHARED: a static flag would be copied on write and never released. */
static void barrier_wait(unsigned count) {
  unsigned ticket = atomic_fetch_add(&shared->arrived, 1) + 1;
  if (ticket == count)
    atomic_store(&shared->go, 1);
  else {
    while (atomic_load(&shared->go) == 0) cpu_relax();
  }
}

static uint64_t stream_read(void) {
  size_t nwords = BUFFER_BYTES / sizeof(uint64_t);
  uint64_t sum = 0;
  for (int pass = 0; pass < PASS_COUNT; pass++) {
    volatile uint64_t *iter = buffer;
    volatile uint64_t *end = buffer + nwords;
    while (iter < end) {
      sum += *iter;
      iter++;
    }
  }
  return sum;
}

static uint64_t elapsed_ns(const struct timespec *t0, const struct timespec *t1) {
  time_t sec = t1->tv_sec - t0->tv_sec;
  long nsec = t1->tv_nsec - t0->tv_nsec;
  if (nsec < 0) {
    sec--;
    nsec += 1000000000L;
  }
  if (sec < 0) return 0;
  return (uint64_t)sec * 1000000000ULL + (uint64_t)nsec;
}

static void worker_fail(int index, const char *msg) {
  snprintf(shared->results[index].err, sizeof shared->results[index].err, "%s",
           msg);
  shared->results[index].status = 1;
}

static int worker(int index, int count) {
  cpu_set_t set;
  CPU_ZERO(&set);
  CPU_SET(cpu_list[index], &set);
  if (sched_setaffinity(0, sizeof set, &set) != 0) {
    int err = errno;
    char msg[160];
    snprintf(msg, sizeof msg, "sched_setaffinity cpu %d: %s", cpu_list[index],
             strerror(err));
    worker_fail(index, msg);
    atomic_store(&shared->failed, 1);
    /* Still arrive, or the other workers spin forever. */
    barrier_wait((unsigned)count);
    return 1;
  }

  /* Start together so the per-process samples overlap on one bus. */
  barrier_wait((unsigned)count);
  if (atomic_load(&shared->failed)) return 1;

  struct timespec t0, t1;
  if (clock_gettime(CLOCK_MONOTONIC, &t0) != 0) {
    int err = errno;
    char msg[160];
    snprintf(msg, sizeof msg, "clock_gettime: %s", strerror(err));
    worker_fail(index, msg);
    return 1;
  }

  uint64_t sum = stream_read();

  if (clock_gettime(CLOCK_MONOTONIC, &t1) != 0) {
    int err = errno;
    char msg[160];
    snprintf(msg, sizeof msg, "clock_gettime: %s", strerror(err));
    worker_fail(index, msg);
    return 1;
  }

  /* Publish the sum. A zero sum means the loads were deleted or never ran. */
  shared->results[index].sum = sum;
  if (sum == 0) {
    worker_fail(index, "checksum is zero; loads were not performed");
    return 1;
  }

  uint64_t ns = elapsed_ns(&t0, &t1);
  shared->results[index].elapsed_ns = ns;
  shared->results[index].bytes = BYTES_TOUCHED;
  if (ns == 0 || shared->results[index].bytes == 0) {
    worker_fail(index, "elapsed time is zero");
    return 1;
  }
  shared->results[index].status = 0;
  return 0;
}

static void reset_shared(int count) {
  atomic_store(&shared->arrived, 0);
  atomic_store(&shared->go, 0);
  atomic_store(&shared->failed, 0);
  for (int i = 0; i < count; i++) {
    shared->results[i].bytes = 0;
    shared->results[i].elapsed_ns = 0;
    shared->results[i].sum = 0;
    shared->results[i].status = 1;
    shared->results[i].err[0] = '\0';
  }
}

static void block_term(sigset_t *old) {
  sigset_t block;
  sigemptyset(&block);
  sigaddset(&block, SIGINT);
  sigaddset(&block, SIGTERM);
  if (sigprocmask(SIG_BLOCK, &block, old) != 0) die("sigprocmask");
}

static void report_failures(int count, const int *saw, const int *status) {
  for (int i = 0; i < count; i++) {
    if (shared->results[i].err[0]) {
      fprintf(stderr, "worker %d: %s\n", i, shared->results[i].err);
      continue;
    }
    if (!saw[i]) {
      fprintf(stderr, "worker %d: failed\n", i);
      continue;
    }
    if (WIFEXITED(status[i]) && WEXITSTATUS(status[i]) == 0) continue;
    if (WIFSIGNALED(status[i]))
      fprintf(stderr, "worker %d: killed by signal %d\n", i, WTERMSIG(status[i]));
    else if (WIFEXITED(status[i]) && !atomic_load(&shared->failed))
      fprintf(stderr, "worker %d: exited with status %d\n", i,
              WEXITSTATUS(status[i]));
    else if (!WIFEXITED(status[i]))
      fprintf(stderr, "worker %d: failed\n", i);
  }
}

static void print_rung(int count, double mbps) {
  if (mbps < 10.0)
    printf("%d %.1f\n", count, mbps);
  else
    printf("%d %.0f\n", count, mbps);
  fflush(stdout);
}

static int run_rung(int count) {
  reset_shared(count);

  sigset_t old;
  block_term(&old);
  child_count = 0;

  for (int i = 0; i < count; i++) {
    pid_t pid = fork();
    if (pid < 0) {
      fprintf(stderr, "fork: %s\n", strerror(errno));
      kill_live_children();
      wait_live_children();
      sigprocmask(SIG_SETMASK, &old, NULL);
      return -1;
    }
    if (pid == 0) {
      sigprocmask(SIG_SETMASK, &old, NULL);
      signal(SIGINT, SIG_DFL);
      signal(SIGTERM, SIG_DFL);
      /* If the parent dies first, don't keep reading. */
      (void)prctl(PR_SET_PDEATHSIG, SIGKILL);
      if (getppid() != parent_pid) _exit(1);
      _exit(worker(i, count) == 0 ? 0 : 1);
    }
    child_pids[i] = (sig_atomic_t)pid;
    child_count = i + 1;
  }

  if (sigprocmask(SIG_SETMASK, &old, NULL) != 0) {
    fprintf(stderr, "sigprocmask: %s\n", strerror(errno));
    kill_live_children();
    wait_live_children();
    return -1;
  }

  int saw[CPU_SETSIZE];
  int status[CPU_SETSIZE];
  memset(saw, 0, sizeof saw);
  int bad = 0;
  int left = count;

  while (left > 0) {
    int st = 0;
    pid_t pid = waitpid(-1, &st, 0);
    if (pid < 0) {
      if (errno == EINTR) continue;
      fprintf(stderr, "waitpid: %s\n", strerror(errno));
      bad = 1;
      break;
    }
    int idx = -1;
    for (int i = 0; i < count; i++) {
      if ((pid_t)child_pids[i] == pid) {
        idx = i;
        break;
      }
    }
    if (idx < 0) {
      fprintf(stderr, "waitpid: unexpected child %d\n", (int)pid);
      bad = 1;
      break;
    }
    child_pids[idx] = 0;
    saw[idx] = 1;
    status[idx] = st;
    left--;
    if (!WIFEXITED(st) || WEXITSTATUS(st) != 0) {
      bad = 1;
      kill_live_children();
    }
  }

  if (bad) {
    kill_live_children();
    wait_live_children();
    report_failures(count, saw, status);
    return -1;
  }
  child_count = 0;

  double mbps = 0.0;
  for (int i = 0; i < count; i++) {
    struct worker_result *r = &shared->results[i];
    if (r->status != 0 || r->sum == 0 || r->bytes == 0 || r->elapsed_ns == 0) {
      if (r->err[0])
        fprintf(stderr, "worker %d: %s\n", i, r->err);
      else
        fprintf(stderr, "worker %d: invalid measurement\n", i);
      return -1;
    }
    mbps += (double)r->bytes * 1000.0 / (double)r->elapsed_ns;
  }
  print_rung(count, mbps);
  return 0;
}

int main(void) {
  parent_pid = getpid();
  install_signals();
  read_affinity();

  char model[256];
  read_model(model, sizeof model);

  shared = mmap(NULL, sizeof *shared, PROT_READ | PROT_WRITE,
                MAP_SHARED | MAP_ANONYMOUS, -1, 0);
  if (shared == MAP_FAILED) die("mmap");
  atomic_init(&shared->arrived, 0);
  atomic_init(&shared->go, 0);
  atomic_init(&shared->failed, 0);

  /* Filled before any fork. Children only read, so copy-on-write stays shared. */
  buffer = mmap(NULL, BUFFER_BYTES, PROT_READ | PROT_WRITE,
                MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  if (buffer == MAP_FAILED) die("mmap");
  size_t nwords = BUFFER_BYTES / sizeof(uint64_t);
  for (size_t i = 0; i < nwords; i++) buffer[i] = 1;

  printf("cpu %s\n", model);
  printf("cores %d\n", ncpu);
  fflush(stdout);

  int counts[sizeof(int) * 8];
  int nrungs = rung_counts(counts);
  for (int i = 0; i < nrungs; i++) {
    if (run_rung(counts[i]) != 0) return 1;
  }
  return 0;
}
