echo "Add O and C to QEMU binfmt registrations so sudo works in emulated Docker cross-arch builds"

omarchy-apply-binfmt --check || sudo omarchy-apply-binfmt
