// Absent on a first visit. "false" is an explicit Light or Dark choice.
if (localStorage.getItem("system-theme-mode") == null) {
  localStorage.setItem("system-theme-mode", "true");
  location.reload();
}
