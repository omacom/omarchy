echo "Re-enroll the Limine config checksum after the boot menu migration"

# 1791898365.sh edited limine.conf without enrolling it again, so machines
# with ENABLE_ENROLL_LIMINE_CONFIG=yes stop on CHECKSUM MISMATCH at the next
# boot. That migration now enrolls the menu itself, but users who already
# completed it never run it again. limine-enroll-config finds the menu itself
# and writes its current checksum into the Limine binary, so running it again
# changes nothing. It reads the setting from /etc/default/limine alone, last
# assignment winning, and machines without it are left alone.

omarchy-cmd-present limine-enroll-config || exit 0
enroll=$(sed -nE 's/^[[:space:]]*ENABLE_ENROLL_LIMINE_CONFIG[[:space:]]*=[[:space:]]*//p' /etc/default/limine 2>/dev/null | tail -n 1) || true
[[ $enroll =~ ^\"?yes\"?$ ]] || exit 0

sudo limine-enroll-config
