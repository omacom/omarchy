#define _GNU_SOURCE
#include <security/pam_appl.h>
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int conversation(int count, const struct pam_message **messages,
                        struct pam_response **responses, void *data) {
  (void)count; (void)messages; (void)responses; (void)data;
  return PAM_CONV_ERR;
}

int main(int argc, char **argv) {
  pam_handle_t *pamh = NULL;
  struct pam_conv conv = {.conv = conversation, .appdata_ptr = NULL};
  if ((argc != 4 && argc != 5) || geteuid() != 0) return 2;
  if (strcmp(argv[3], "wait-ignored-signals") == 0) {
    signal(SIGTERM, SIG_IGN);
    signal(SIGCHLD, SIG_IGN);
  }
  /* Match the legacy helper: initiating UID differs from PAM's admin user. */
  if (setresuid((uid_t)strtoul(argv[1], NULL, 10), 0, 0) != 0) return 2;
  int result = pam_start_confdir("polkit-1", argc == 5 ? argv[4] : "root", &conv, argv[2], &pamh);
  if (result == PAM_SUCCESS) result = pam_authenticate(pamh, 0);
  printf("AUTH %d\n", result);
  fflush(stdout);
  if (result == PAM_SUCCESS && (strcmp(argv[3], "wait") == 0 || strcmp(argv[3], "wait-ignored-signals") == 0)) {
    for (;;) pause();
  }
  if (result == PAM_SUCCESS && strcmp(argv[3], "wait-account") == 0) {
    char next;
    if (read(STDIN_FILENO, &next, 1) != 1) return 2;
  }
  if (result == PAM_SUCCESS) {
    result = pam_acct_mgmt(pamh, 0);
    printf("ACCOUNT %d\n", result);
  }
  if (pamh != NULL) pam_end(pamh, result);
  return result == PAM_SUCCESS ? 0 : 1;
}
