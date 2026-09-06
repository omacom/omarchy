import Quickshell
import "lock"

// A separate configuration keeps the session lock alive across shell restarts.
// Share the UI and theme modules, but never load the shell's plugin registry.
ShellRoot {
  Service { }
}
