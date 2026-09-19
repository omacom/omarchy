echo "Disable Limine mouse input so pointer movement cannot cancel autoboot"

limine_conf=/boot/limine.conf

sudo /usr/bin/bash -euo pipefail -c '
source /usr/lib/limine/limine-mutex

mutex_lock
trap mutex_unlock EXIT

limine_conf=$1
[[ -f $limine_conf ]] || exit 0
awk "
  /^[[:space:]]*\// { exit }
  tolower(\$0) ~ /^[[:space:]]*mouse:/ { found = 1; exit }
  END { exit !found }
" "$limine_conf" && exit 0
sed -i "1i mouse: no" "$limine_conf"
' _ "$limine_conf"
