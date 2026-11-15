#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <security/pam_ext.h>
#include <security/pam_modules.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <syslog.h>
#include <unistd.h>

#ifndef OMARCHY_POLKIT_GUARD
#define OMARCHY_POLKIT_GUARD "/usr/lib/omarchy/polkit-lock-guard"
#endif
#define GUARD_DATA "omarchy-polkit-lock-guard"

struct guard { pid_t child; int channel; };

static void cleanup(pam_handle_t *pamh, void *data, int status) {
  struct guard *guard = data;
  int child_status;
  (void)pamh; (void)status;
  close(guard->channel);
  /* An unreaped child cannot have its PID reused. */
  kill(guard->child, SIGTERM);
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
  pid_t parent = getpid(), child;
  int channels[2], status;
  char uid_text[32];
  struct guard *guard;

  *result = NULL;
  if (geteuid() != 0 || pam_get_item(pamh, PAM_SERVICE, &service) != PAM_SUCCESS ||
      service == NULL || strcmp(service, "polkit-1") != 0)
    return PAM_PERM_DENIED;
  if (pam_get_data(pamh, GUARD_DATA, &saved) == PAM_SUCCESS) {
    *result = (struct guard *)saved;
    return PAM_SUCCESS;
  }
  if (uid == 0) {
    if (getsockopt(STDIN_FILENO, SOL_SOCKET, SO_PEERCRED, &peer, &length) != 0 ||
        length != sizeof(peer) || peer.pid <= 0)
      return PAM_AUTHINFO_UNAVAIL;
    uid = peer.uid;
  }
  if (uid == 0) return PAM_SUCCESS;
  if (fstat(STDIN_FILENO, &input) != 0 || (!S_ISSOCK(input.st_mode) && !S_ISFIFO(input.st_mode)))
    return PAM_AUTHINFO_UNAVAIL;
  snprintf(uid_text, sizeof(uid_text), "%lu", (unsigned long)uid);
  guard = calloc(1, sizeof(*guard));
  if (guard == NULL) return PAM_BUF_ERR;
  if (socketpair(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0, channels) != 0) {
    free(guard);
    return PAM_SYSTEM_ERR;
  }
  child = fork();
  if (child == 0) {
    char *const args[] = {"/usr/bin/python3", "-I", OMARCHY_POLKIT_GUARD, uid_text, NULL};
    char *const environment[] = {"PATH=/usr/bin:/bin", "LANG=C.UTF-8", NULL};
    /* Preserve the agent connection only to observe hangup, without reading
     * credentials. This also catches helpers started after cancellation. */
    int agent = fcntl(STDIN_FILENO, F_DUPFD_CLOEXEC, 10);
    close(channels[0]);
    if (setresuid(0, 0, 0) != 0 || prctl(PR_SET_PDEATHSIG, SIGTERM) != 0 ||
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
  (void)flags; (void)argc; (void)argv;
  return check_lock(pamh);
}

PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags, int argc, const char **argv) {
  (void)flags; (void)argc; (void)argv;
  return check_lock(pamh);
}

PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc, const char **argv) {
  (void)pamh; (void)flags; (void)argc; (void)argv;
  return PAM_SUCCESS;
}
