echo "Stop mise from globally managing Python now that the dev-env installer uses uv instead"

# omarchy-install-dev-env python used to run `mise use --global python@latest`
# alongside installing uv. A global mise Python shims `python`/`pip` ahead of
# the distro-packaged Python for every shell, which is exactly what broke
# things system-wide, so the install/remove flow no longer touches mise for
# Python at all. Existing machines that already set that global pin are left
# with the conflicting shim until this repairs it.
#
# Only the global pin is removed here, not `mise uninstall python --all`:
# that would delete interpreters a project's own .mise.toml may still pin to,
# which is a legitimate, non-conflicting use of mise. Dropping the global
# pin is enough to stop `python`/`pip` from resolving to mise outside such a
# project, and gating on the pin itself (rather than on an installed version
# existing on disk) leaves a project-only mise Python alone.
mise config get python -g >/dev/null 2>&1 || exit 0

mise rm -g python
