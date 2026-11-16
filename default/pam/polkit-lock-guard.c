#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <linux/sched.h>
#include <poll.h>
#include <pwd.h>
#include <security/pam_ext.h>
#include <security/pam_modules.h>
#include <security/pam_modutil.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <syslog.h>
#include <unistd.h>

#ifndef OMARCHY_POLKIT_GUARD
#define OMARCHY_POLKIT_GUARD "/usr/lib/omarchy/polkit-lock-guard"
#endif
#define GUARD_DATA "omarchy-polkit-lock-guard"

struct guard { pid_t child; int channel; int pidfd; uid_t identity; };

static void cleanup(pam_handle_t *pamh, void *data, int status) {
  struct guard *guard = data;
  int child_status;
  (void)pamh; (void)status;
  close(guard->channel);
  /* Legacy callers can inherit SIGCHLD=SIG_IGN and auto-reap children. Pin
   * the guardian even then; never signal a potentially reused numeric PID. */
  if (guard->pidfd >= 0) {
    syscall(SYS_pidfd_send_signal, guard->pidfd, SIGTERM, NULL, 0);
    close(guard->pidfd);
  }
  while (waitpid(guard->child, &child_status, 0) == -1 && errno == EINTR) {}
  free(guard);
}

static int receive_state(struct guard *guard) {
  struct pollfd request = {.fd = guard->channel, .events = POLLIN};
  char state;
  int result;
  do { result = poll(&request, 1, 3000); } while (result == -1 && errno == EINTR);
  if (result <= 0 || recv(guard->channel, &state, 1, 0) != 1)
    return PAM_AUTHINFO_UNAVAIL;
  if (state == 'U') return PAM_SUCCESS;
  return state == 'L' ? PAM_PERM_DENIED : PAM_AUTHINFO_UNAVAIL;
}

/* The authenticating administrator is not necessarily the agent's user.
 * Socket-activated helpers carry the agent's kernel credentials on stdin;
 * older setuid helpers retain the agent's real UID. PAM_USER and the desktop
 * environment are not authoritative for choosing whose compositor to check. */
static int get_guard(pam_handle_t *pamh, struct guard **result) {
  const void *service = NULL, *saved = NULL;
  struct ucred peer;
  struct stat input;
  socklen_t length = sizeof(peer);
  uid_t uid = getuid();
  const char *username;
  struct passwd *identity;
  pid_t parent = getpid(), child;
  int channels[2], status;
  char uid_text[32], identity_text[32];
  struct guard *guard;

  *result = NULL;
  if (geteuid() != 0 || pam_get_item(pamh, PAM_SERVICE, &service) != PAM_SUCCESS ||
      service == NULL || strcmp(service, "polkit-1") != 0)
    return PAM_PERM_DENIED;
  if (uid == 0) {
    if (getsockopt(STDIN_FILENO, SOL_SOCKET, SO_PEERCRED, &peer, &length) != 0 ||
        length != sizeof(peer) || peer.pid <= 0)
      return PAM_AUTHINFO_UNAVAIL;
    uid = peer.uid;
  }
  if (uid == 0) return PAM_SUCCESS;
  if (pam_get_user(pamh, &username, NULL) != PAM_SUCCESS || username == NULL ||
      (identity = pam_modutil_getpwnam(pamh, username)) == NULL)
    return PAM_USER_UNKNOWN;
  if (pam_get_data(pamh, GUARD_DATA, &saved) == PAM_SUCCESS && saved != NULL) {
    *result = (struct guard *)saved;
    /* Do not reuse an authentication conversation for a changed identity. */
    return (*result)->identity == identity->pw_uid ? PAM_SUCCESS : PAM_PERM_DENIED;
  }
  if (fstat(STDIN_FILENO, &input) != 0 || (!S_ISSOCK(input.st_mode) && !S_ISFIFO(input.st_mode)))
    return PAM_AUTHINFO_UNAVAIL;
  snprintf(uid_text, sizeof(uid_text), "%lu", (unsigned long)uid);
  snprintf(identity_text, sizeof(identity_text), "%lu", (unsigned long)identity->pw_uid);
  guard = calloc(1, sizeof(*guard));
  if (guard == NULL) return PAM_BUF_ERR;
  guard->identity = identity->pw_uid;
  if (socketpair(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0, channels) != 0) {
    free(guard);
    return PAM_SYSTEM_ERR;
  }
  /* Acquire the pidfd atomically: SIGCHLD=SIG_IGN may otherwise reap a
   * fast-exiting child before a separate pidfd_open can pin its identity. */
  struct clone_args clone = {
    .flags = CLONE_PIDFD,
    .pidfd = (uintptr_t)&guard->pidfd,
    .exit_signal = SIGCHLD,
  };
  child = syscall(SYS_clone3, &clone, sizeof(clone));
  /* systemd RestrictNamespaces deliberately returns ENOSYS for clone3;
   * legacy clone exposes its flags to that filter and supports CLONE_PIDFD
   * too. Unused TLS/child-tid arguments are zero on both supported ABIs. */
  if (child == -1 && errno == ENOSYS)
    child = syscall(SYS_clone, (unsigned long)(CLONE_PIDFD | SIGCHLD),
                    NULL, &guard->pidfd, NULL, 0);
  if (child == 0) {
    char *const args[] = {"/usr/bin/python3", "-I", OMARCHY_POLKIT_GUARD, uid_text, identity_text, NULL};
    char *const environment[] = {"PATH=/usr/bin:/bin", "LANG=C.UTF-8", NULL};
    /* Preserve the agent connection only to observe hangup, without reading
     * credentials. This also catches helpers started after cancellation. */
    int agent = fcntl(STDIN_FILENO, F_DUPFD_CLOEXEC, 10);
    sigset_t signals;
    struct sigaction action = {.sa_handler = SIG_DFL};
    sigemptyset(&signals);
    sigemptyset(&action.sa_mask);
    close(channels[0]);
    if (sigprocmask(SIG_SETMASK, &signals, NULL) != 0 ||
        sigaction(SIGTERM, &action, NULL) != 0 ||
        setresuid(0, 0, 0) != 0 || prctl(PR_SET_PDEATHSIG, SIGTERM) != 0 ||
        getppid() != parent || dup2(channels[1], STDIN_FILENO) < 0 ||
        dup2(channels[1], STDOUT_FILENO) < 0 || agent < 0 || dup2(agent, 3) < 0)
      _exit(2);
    if (close_range(4, ~0U, 0) != 0) _exit(2);
    execve(args[0], args, environment);
    _exit(2);
  }
  close(channels[1]);
  if (child == -1) {
    close(channels[0]);
    free(guard);
    return PAM_SYSTEM_ERR;
  }
  guard->child = child;
  guard->channel = channels[0];
  status = receive_state(guard);
  if (status == PAM_SUCCESS)
    status = pam_set_data(pamh, GUARD_DATA, guard, cleanup);
  if (status != PAM_SUCCESS) {
    cleanup(pamh, guard, status);
    return status;
  }
  *result = guard;
  return PAM_SUCCESS;
}

static int check_lock(pam_handle_t *pamh) {
  struct guard *guard;
  int status = get_guard(pamh, &guard);
  if (status == PAM_SUCCESS && guard != NULL) {
    if (send(guard->channel, "Q", 1, MSG_NOSIGNAL) != 1)
      status = PAM_AUTHINFO_UNAVAIL;
    else
      status = receive_state(guard);
  }
  if (status != PAM_SUCCESS)
    pam_syslog(pamh, LOG_NOTICE, "Polkit authentication blocked: desktop locked or lock state unavailable");
  return status;
}

PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc, const char **argv) {
  (void)flags;
  if (argc == 1 && strcmp(argv[0], "password") == 0) {
    const void *saved = NULL;
    /* A failed presence factor may fall back to an explicit password. Stop
     * watching before that conversation; password auth has no shared reader. */
    if (pam_get_data(pamh, GUARD_DATA, &saved) == PAM_SUCCESS)
      return pam_set_data(pamh, GUARD_DATA, NULL, NULL);
    return PAM_SUCCESS;
  }
  if (argc != 0) return PAM_SERVICE_ERR;
  return check_lock(pamh);
}

PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags, int argc, const char **argv) {
  const void *saved = NULL;
  (void)flags; (void)argc; (void)argv;
  /* A sufficient presence factor keeps its guardian. Password fallback clears
   * it explicitly, so terminal-only passwords remain usable while locked. */
  if (pam_get_data(pamh, GUARD_DATA, &saved) != PAM_SUCCESS || saved == NULL)
    return PAM_SUCCESS;
  return check_lock(pamh);
}

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
  (void)pamh; (void)flags; (void)argc; (void)argv;
  return PAM_SUCCESS;
}
