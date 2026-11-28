echo "Keep Papers and xdg-user-dirs through orphan cleanup"

# 1794351944 and 1794393156 install these with omarchy-pkg-add, which leaves a
# package that is already there marked as a dependency. Where xdg-user-dirs had
# arrived with Nautilus, the same update's orphan cleanup removed it right after
# the Nautilus migration, and Papers stays only while an optional dependency
# holds it. Both are base packages, so install what is missing and mark both
# explicit, as a fresh install has them.
omarchy-pkg-add papers xdg-user-dirs

mapfile -t dependency_packages < <(pacman -Qqd papers xdg-user-dirs 2>/dev/null)

if (( ${#dependency_packages[@]} )); then
  sudo pacman -D --asexplicit "${dependency_packages[@]}"
fi
